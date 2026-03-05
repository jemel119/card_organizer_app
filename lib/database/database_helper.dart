import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_organizer.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        // IMPORTANT: must enable foreign keys in SQLite
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Folders table
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Cards table with FK + CASCADE
    await db.execute('''
      CREATE TABLE cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT,
        folder_id INTEGER NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES folders (id)
          ON DELETE CASCADE
      )
    ''');

    // Prepopulate folders + cards
    await _prepopulateFolders(db);
    await _prepopulateCards(db);
  }

  Future<void> _prepopulateFolders(Database db) async {
    final now = DateTime.now().toIso8601String();
    final suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];

    for (final suit in suits) {
      await db.insert('folders', {
        'folder_name': suit,
        'timestamp': now,
      });
    }
  }

  Future<void> _prepopulateCards(Database db) async {
    // Assumes folders inserted in this order and got ids 1..4
    final suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
    final ranks = [
      'Ace', '2', '3', '4', '5', '6', '7',
      '8', '9', '10', 'Jack', 'Queen', 'King'
    ];

    for (int i = 0; i < suits.length; i++) {
      final suit = suits[i];
      final folderId = i + 1;

      for (final rank in ranks) {
        // Example naming strategy for assets:
        // assets/cards/hearts_ace.png, spades_10.png, diamonds_queen.png, etc.
        final safeSuit = suit.toLowerCase();
        final safeRank = rank.toLowerCase().replaceAll(' ', '_');

        await db.insert('cards', {
          'card_name': rank,
          'suit': suit,
          'image_url': 'assets/cards/${safeSuit}_$safeRank.png',
          'folder_id': folderId,
        });
      }
    }
  }

  /// OPTIONAL but helpful for debugging
  Future<void> printDatabaseContents() async {
    final db = await database;

    final folders = await db.query('folders');
    // ignore: avoid_print
    print('=== FOLDERS (${folders.length}) ===');
    for (final f in folders) {
      // ignore: avoid_print
      print(f);
    }

    final cards = await db.query('cards');
    // ignore: avoid_print
    print('=== CARDS (${cards.length}) ===');
    for (final c in cards.take(20)) {
      // ignore: avoid_print
      print(c);
    }
    // ignore: avoid_print
    print('... (showing first 20 cards)');
  }
}