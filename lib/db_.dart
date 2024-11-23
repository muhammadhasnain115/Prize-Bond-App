import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'bond_database.db');
    print("Database path: $path");

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE bonds(id INTEGER PRIMARY KEY, bondNumber TEXT, price TEXT)",
        );
        await db.execute(
          "CREATE TABLE settings(id INTEGER PRIMARY KEY, loginFlag INTEGER, username TEXT, email TEXT)",
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.transaction((txn) async {
          if (oldVersion < 2) {
            print("Upgrading database to version 2");
            await txn.execute(
              "CREATE TABLE IF NOT EXISTS settings(id INTEGER PRIMARY KEY, loginFlag INTEGER)",
            );
          }
          if (oldVersion < 3) {
            print("Upgrading database to version 3");
            await txn.execute(
              "ALTER TABLE settings ADD COLUMN username TEXT",
            );
            await txn.execute(
              "ALTER TABLE settings ADD COLUMN email TEXT",
            );
          }
        });
      },
    );
  }

  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'bond_database.db');
    File dbFile = File(path);
    if (await dbFile.exists()) {
      await dbFile.delete();
      print("Database deleted");
    }
  }

  Future<int> insertBond(String bondNumber, String price) async {
    final db = await database;
    var res = await db.insert('bonds', {'bondNumber': bondNumber, 'price': price});
    print("Bond inserted: $res");
    return res;
  }

  Future<List<Map<String, dynamic>>> getBonds() async {
    final db = await database;
    var res = await db.query('bonds');
    print("Bonds fetched: $res");
    return res;
  }

  Future<bool> bondExists(String bondNumber) async {
    final db = await database;
    var res = await db.query('bonds', where: 'bondNumber = ?', whereArgs: [bondNumber]);
    print("Bond exists: ${res.isNotEmpty}");
    return res.isNotEmpty;
  }

  Future<void> updateBondPrice(String bondNumber, String newPrice) async {
    final db = await database;
    await db.update(
      'bonds',
      {'price': newPrice},
      where: 'bondNumber = ?',
      whereArgs: [bondNumber],
    );
    print("Bond updated: $bondNumber to $newPrice");
  }

  Future<String?> getBondPrice(String bondNumber) async {
    final db = await database;
    var res = await db.query(
      'bonds',
      columns: ['price'],
      where: 'bondNumber = ?',
      whereArgs: [bondNumber],
    );
    if (res.isNotEmpty) {
      return res.first['price'] as String?;
    }
    return null;
  }

  Future<void> deleteBond(String bondNumber) async {
    final db = await database;
    await db.delete('bonds', where: 'bondNumber = ?', whereArgs: [bondNumber]);
    print("Bond deleted: $bondNumber");
  }

  Future<void> deleteAllBonds() async {
    final db = await database;
    await db.delete('bonds');
    print("All bonds deleted");
  }

  Future<bool> getLoginFlag() async {
    final db = await database;
    var res = await db.query('settings', where: 'id = ?', whereArgs: [1]);
    if (res.isNotEmpty) {
      return res.first['loginFlag'] == 1;
    }
    return false;
  }

  Future<void> setLoginFlag(bool value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'id': 1, 'loginFlag': value ? 1 : 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Login flag set to: $value");
  }

  Future<String?> getUsername() async {
    final db = await database;
    var res = await db.query('settings', where: 'id = ?', whereArgs: [1], columns: ['username']);
    if (res.isNotEmpty) {
      return res.first['username'] as String?;
    }
    return null;
  }

  Future<void> setUsername(String username) async {
    final db = await database;
    await db.update(
      'settings',
      {'username': username},
      where: 'id = ?',
      whereArgs: [1],
    );
    print("Username set to: $username");
  }

  Future<String?> getEmail() async {
    final db = await database;
    var res = await db.query('settings', where: 'id = ?', whereArgs: [1], columns: ['email']);
    if (res.isNotEmpty) {
      return res.first['email'] as String?;
    }
    return null;
  }

  Future<void> setEmail(String email) async {
    final db = await database;
    await db.update(
      'settings',
      {'email': email},
      where: 'id = ?',
      whereArgs: [1],
    );
    print("Email set to: $email");
  }
}

