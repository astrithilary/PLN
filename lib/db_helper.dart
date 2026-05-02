import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// Mock Database untuk Web
class MockDatabase {
  final Map<String, List<Map<String, dynamic>>> _tables = {};

  Future<int> insert(String table, Map<String, dynamic> values) async {
    if (!_tables.containsKey(table)) {
      _tables[table] = [];
    }
    int id = 1;
    if (_tables[table]!.isNotEmpty) {
      id = (_tables[table]!.last['id'] as int? ?? 0) + 1;
    }
    values['id'] = id;
    _tables[table]!.add(values);
    return id;
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    if (!_tables.containsKey(table)) {
      return [];
    }

    List<Map<String, dynamic>> results = List.from(_tables[table]!);

    if (where != null && whereArgs != null) {
      results = results.where((row) {
        if (where.contains('status_sinkron = ?')) {
          return row['status_sinkron'] == whereArgs[0];
        }
        return true;
      }).toList();
    }

    return results;
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    if (!_tables.containsKey(table)) {
      return 0;
    }

    int count = 0;
    if (where != null && whereArgs != null) {
      for (var i = 0; i < _tables[table]!.length; i++) {
        if (where.contains('status_sinkron = ?') && whereArgs.isNotEmpty) {
          if (_tables[table]![i]['status_sinkron'] == whereArgs[0]) {
            _tables[table]![i].addAll(values);
            count++;
          }
        } else if (where.contains('id = ?') && whereArgs.isNotEmpty) {
          if (_tables[table]![i]['id'] == whereArgs[0]) {
            _tables[table]![i].addAll(values);
            count++;
          }
        }
      }
    }
    return count;
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    if (!_tables.containsKey(table)) {
      return 0;
    }

    int count = 0;
    if (where != null && whereArgs != null) {
      _tables[table]!.removeWhere((row) {
        if (where.contains('id = ?') && whereArgs.isNotEmpty) {
          if (row['id'] == whereArgs[0]) {
            count++;
            return true;
          }
        }
        return false;
      });
    }
    return count;
  }
}

class DbHelper {
  static const _databaseName = 'pln_survey.db';
  static const _databaseVersion = 3;
  static const tablePelanggan = 'pelanggan';
  static const tableUser = 'user_profile';

  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();

  static Database? _database;
  static MockDatabase? _mockDatabase;

  Future<Database> get database async {
    if (kIsWeb) {
      _mockDatabase ??= MockDatabase();
      return _createMockDatabaseWrapper(_mockDatabase!);
    } else {
      if (_database != null) return _database!;
      _database = await _initDatabase();
      return _database!;
    }
  }

  Database _createMockDatabaseWrapper(MockDatabase mock) {
    return mock as Database;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablePelanggan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        id_pelanggan TEXT,
        alamat TEXT,
        daya TEXT,
        no_hp TEXT,
        foto_path TEXT,
        latitude REAL,
        longitude REAL,
        waktu_kunjungan TEXT,
        status_sinkron INTEGER
      )
    ''');

    // Create user profile table
    await db.execute('''
      CREATE TABLE $tableUser (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        phone TEXT,
        address TEXT,
        department TEXT,
        status TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $tablePelanggan ADD COLUMN latitude REAL');
      await db.execute('ALTER TABLE $tablePelanggan ADD COLUMN longitude REAL');
      await db.execute(
        'ALTER TABLE $tablePelanggan ADD COLUMN waktu_kunjungan TEXT',
      );
    }
    if (oldVersion < 3) {
      // Create user profile table if upgrading
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableUser (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT,
          phone TEXT,
          address TEXT,
          department TEXT,
          status TEXT,
          created_at TEXT,
          updated_at TEXT
        )
      ''');
    }
  }

  Future<int> insertPelanggan(Map<String, dynamic> row) async {
    if (kIsWeb) {
      _mockDatabase ??= MockDatabase();
      return await _mockDatabase!.insert(tablePelanggan, row);
    } else {
      final db = await database;
      return await db.insert(tablePelanggan, row);
    }
  }

  Future<List<Map<String, dynamic>>> getPelanggan() async {
    if (kIsWeb) {
      _mockDatabase ??= MockDatabase();
      return await _mockDatabase!.query(tablePelanggan);
    } else {
      final db = await database;
      return await db.query(tablePelanggan);
    }
  }

  Future<List<Map<String, dynamic>>> getPelangganByStatus(
    int statusSinkron,
  ) async {
    if (kIsWeb) {
      _mockDatabase ??= MockDatabase();
      return await _mockDatabase!.query(
        tablePelanggan,
        where: 'status_sinkron = ?',
        whereArgs: [statusSinkron],
      );
    } else {
      final db = await database;
      return await db.query(
        tablePelanggan,
        where: 'status_sinkron = ?',
        whereArgs: [statusSinkron],
      );
    }
  }

  Future<int> setAllPendingSynced() async {
    if (kIsWeb) {
      _mockDatabase ??= MockDatabase();
      return await _mockDatabase!.update(
        tablePelanggan,
        {'status_sinkron': 1},
        where: 'status_sinkron = ?',
        whereArgs: [0],
      );
    } else {
      final db = await database;
      return await db.update(
        tablePelanggan,
        {'status_sinkron': 1},
        where: 'status_sinkron = ?',
        whereArgs: [0],
      );
    }
  }

  Future<int> updatePelanggan(int id, Map<String, dynamic> row) async {
    if (kIsWeb) {
      _mockDatabase ??= MockDatabase();
      final data = await _mockDatabase!.query(tablePelanggan);
      for (var item in data) {
        if (item['id'] == id) {
          item.addAll(row);
          return 1;
        }
      }
      return 0;
    } else {
      final db = await database;
      return await db.update(
        tablePelanggan,
        row,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // Update hanya status_sinkron
  Future<int> updatePelangganStatus(int id, int statusSinkron) async {
    if (kIsWeb) {
      _mockDatabase ??= MockDatabase();
      final data = await _mockDatabase!.query(tablePelanggan);
      for (var item in data) {
        if (item['id'] == id) {
          item['status_sinkron'] = statusSinkron;
          return 1;
        }
      }
      return 0;
    } else {
      final db = await database;
      return await db.update(
        tablePelanggan,
        {'status_sinkron': statusSinkron},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<int> deletePelanggan(int id) async {
    if (kIsWeb) {
      _mockDatabase ??= MockDatabase();
      return await _mockDatabase!.delete(
        tablePelanggan,
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      final db = await database;
      return await db.delete(tablePelanggan, where: 'id = ?', whereArgs: [id]);
    }
  }

  // ===== User Profile CRUD Methods =====

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (kIsWeb) {
      _mockDatabase ??= MockDatabase();
      final result = await _mockDatabase!.query(tableUser);
      return result.isNotEmpty ? result.first : null;
    } else {
      final db = await database;
      final result = await db.query(tableUser, limit: 1);
      return result.isNotEmpty ? result.first : null;
    }
  }

  // Insert or update user profile
  Future<int> saveUserProfile(Map<String, dynamic> profileData) async {
    final now = DateTime.now().toIso8601String();
    
    if (kIsWeb) {
      _mockDatabase ??= MockDatabase();
      final existing = await _mockDatabase!.query(tableUser);
      
      if (existing.isNotEmpty) {
        // Update existing profile
        profileData['updated_at'] = now;
        for (var item in existing) {
          item.addAll(profileData);
        }
        return existing.first['id'] as int;
      } else {
        // Insert new profile
        profileData['created_at'] = now;
        profileData['updated_at'] = now;
        return await _mockDatabase!.insert(tableUser, profileData);
      }
    } else {
      final db = await database;
      final existing = await db.query(tableUser, limit: 1);
      
      profileData['updated_at'] = now;
      
      if (existing.isNotEmpty) {
        // Update existing profile
        await db.update(
          tableUser,
          profileData,
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
        return existing.first['id'] as int;
      } else {
        // Insert new profile
        profileData['created_at'] = now;
        return await db.insert(tableUser, profileData);
      }
    }
  }

  // Delete user profile
  Future<int> deleteUserProfile() async {
    if (kIsWeb) {
      _mockDatabase ??= MockDatabase();
      final existing = await _mockDatabase!.query(tableUser);
      if (existing.isNotEmpty) {
        return await _mockDatabase!.delete(
          tableUser,
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
      }
      return 0;
    } else {
      final db = await database;
      return await db.delete(tableUser);
    }
  }
}
