import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/folder.dart';

class FolderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// CREATE
  Future<int> insertFolder(Folder folder) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert('folders', folder.toMap());
    } catch (e) {
      throw Exception("Failed to insert folder: $e");
    }
  }

  /// READ - Get all folders
  Future<List<Folder>> getAllFolders() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'folders',
        orderBy: 'timestamp DESC',
      );

      return maps.map((map) => Folder.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Failed to fetch folders: $e");
    }
  }

  /// READ - Get folder by ID
  Future<Folder?> getFolderById(int id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'folders',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Folder.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception("Failed to fetch folder: $e");
    }
  }

  /// UPDATE
  Future<int> updateFolder(Folder folder) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        'folders',
        folder.toMap(),
        where: 'id = ?',
        whereArgs: [folder.id],
      );
    } catch (e) {
      throw Exception("Failed to update folder: $e");
    }
  }

  /// DELETE (CASCADE handled by DB)
  Future<int> deleteFolder(int id) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        'folders',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Failed to delete folder: $e");
    }
  }

  /// COUNT
  Future<int> getFolderCount() async {
    final db = await _dbHelper.database;
    final result =
        await db.rawQuery('SELECT COUNT(*) FROM folders');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}