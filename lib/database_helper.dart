import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<void> deleteDatabaseFile() async {
    String path = join(await getDatabasesPath(), 'topics.db');
    if (await File(path).exists()) {
      await File(path).delete();
      print("Database deleted successfully.");
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'topics.db');
    print(await getDatabasesPath());

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE topics(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)',
        );
        await db.execute(
          'CREATE TABLE flashcards('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'topic_id INTEGER, '
          'question TEXT, '
          'answer TEXT, '
          'repetition INTEGER DEFAULT 0,'
          'interval INTEGER DEFAULT 1,'
          'easeFactor REAL DEFAULT 2.5,'
          'nextReviewDate INTEGER DEFAULT 0,'
          'FOREIGN KEY(topic_id) REFERENCES topics(id) ON DELETE CASCADE)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE flashcards ADD COLUMN repetition INTEGER DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE flashcards ADD COLUMN interval INTEGER DEFAULT 1',
          );
          await db.execute(
            'ALTER TABLE flashcards ADD COLUMN easeFactor REAL DEFAULT 2.5',
          );
          await db.execute(
              'ALTER TABLE flashcards ADD COLUMN nextReviewDate INTEGER DEFAULT 0');
        }
      },
    );
  }

  Future<void> insertTopic(String name) async {
    final db = await database;

    await db.insert(
      'topics',
      {'name': name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getTopics() async {
    final db = await database;
    return await db.query('topics');
  }

  Future<void> deleteTopic(int id) async {
    final db = await database;
    await db.delete(
      'topics',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertFlashcard(
      int topicId, String question, String answer) async {
    final db = await database;

    await db.insert(
      'flashcards',
      {
        'topic_id': topicId,
        'question': question,
        'answer': answer,
        'repetition': 0,
        'interval': 1,
        'easeFactor': 2.5,
        'nextReviewDate': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteFlashcard(int id) async {
    final db = await database;
    await db.delete(
      'flashcards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getFlashcards(int topicId) async {
    final db = await database;
    return await db.query(
      'flashcards',
      where: 'topic_id = ?',
      whereArgs: [topicId],
    );
  }

  Future<int> getFlashcardsCount(int topicId) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM flashcards WHERE topic_id = ?', [topicId]));
    return count ?? 0;
  }

  Future<void> updateFlashcard(int id, int repetition, int interval,
      double easeFactor, int nextReviewDate) async {
    final db = await database;

    await db.update(
      'flashcards',
      {
        'repetition': repetition,
        'interval': interval,
        'easeFactor': easeFactor,
        'nextReviewDate': nextReviewDate,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // SM-2 algorithm implementation
  Future<void> applySM2(int flashcardId, int quality) async {
    final db = await database;
    final flashcard = (await db.query(
      'flashcards',
      where: 'id = ?',
      whereArgs: [flashcardId],
    ))
        .first;

    int repetition = flashcard['repetition'] as int;
    int interval = flashcard['interval'] as int;
    double easeFactor = flashcard['easeFactor'] as double;
    int nextReviewDate = flashcard['nextReviewDate'] as int;

    int currentDate = DateTime.now().millisecondsSinceEpoch;

    if (currentDate >= nextReviewDate) {
      if (quality < 3) {
        repetition = 0;
        interval = 1;
      } else {
        if (repetition == 0) {
          interval = 1;
        } else if (repetition == 1) {
          interval = 6;
        } else {
          interval = (interval * easeFactor).round();
        }
        repetition += 1;
      }

      easeFactor += 0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02);
      if (easeFactor < 1.3) easeFactor = 1.3;

      nextReviewDate = currentDate + interval * 24 * 60 * 60 * 1000;

      await updateFlashcard(
          flashcardId, repetition, interval, easeFactor, nextReviewDate);
    }
  }
}
