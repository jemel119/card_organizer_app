import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/card.dart';

class CardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// CREATE
  Future<int> insertCard(PlayingCard card) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert('cards', card.toMap());
    } catch (e) {
      throw Exception("Failed to insert card: $e");
    }
  }

  /// READ - Get all cards
  Future<List<PlayingCard>> getAllCards() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'cards',
        orderBy: 'card_name ASC',
      );

      return maps.map((map) => PlayingCard.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Failed to fetch cards: $e");
    }
  }

  /// READ - Get cards by folder
  Future<List<PlayingCard>> getCardsByFolderId(int folderId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'cards',
        where: 'folder_id = ?',
        whereArgs: [folderId],
        orderBy: 'card_name ASC',
      );

      return maps.map((map) => PlayingCard.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Failed to fetch cards: $e");
    }
  }

  /// READ - Get card by ID
  Future<PlayingCard?> getCardById(int id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'cards',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return PlayingCard.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception("Failed to fetch card: $e");
    }
  }

  /// UPDATE
  Future<int> updateCard(PlayingCard card) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        'cards',
        card.toMap(),
        where: 'id = ?',
        whereArgs: [card.id],
      );
    } catch (e) {
      throw Exception("Failed to update card: $e");
    }
  }

  /// DELETE
  Future<int> deleteCard(int id) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        'cards',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Failed to delete card: $e");
    }
  }

  /// COUNT by folder
  Future<int> getCardCountByFolder(int folderId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM cards WHERE folder_id = ?',
      [folderId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// MOVE card to another folder
  Future<int> moveCardToFolder(int cardId, int newFolderId) async {
    final db = await _dbHelper.database;

    return await db.update(
      'cards',
      {'folder_id': newFolderId},
      where: 'id = ?',
      whereArgs: [cardId],
    );
  }
}