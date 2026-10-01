import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'seed.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'chalgima.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
        await SeedData.seed(db);
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    // 1. subjects
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        weekly_goal_min INTEGER NOT NULL DEFAULT 300,
        daily_goal_min INTEGER NOT NULL DEFAULT 45,
        note TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'active',
        total_seconds INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      );
    ''');

    // 2. sessions
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        start_at INTEGER NOT NULL,
        end_at INTEGER NOT NULL,
        net_seconds INTEGER NOT NULL,
        pause_seconds INTEGER NOT NULL DEFAULT 0,
        distraction_count INTEGER NOT NULL DEFAULT 0,
        mode TEXT NOT NULL,
        rating INTEGER,
        note TEXT,
        day_key TEXT NOT NULL,
        confirmed INTEGER NOT NULL DEFAULT 1,
        intention TEXT,
        intention_done INTEGER,
        kind TEXT NOT NULL DEFAULT 'read',
        focus_score INTEGER NOT NULL DEFAULT 50,
        cards_created INTEGER NOT NULL DEFAULT 0
      );
    ''');

    // 3. cards
    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        session_id INTEGER,
        type TEXT NOT NULL,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        hint TEXT,
        stage INTEGER NOT NULL DEFAULT 0,
        interval_days INTEGER NOT NULL DEFAULT 0,
        next_due TEXT NOT NULL,
        last_seen INTEGER,
        correct_count INTEGER NOT NULL DEFAULT 0,
        wrong_count INTEGER NOT NULL DEFAULT 0,
        streak_correct INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'active',
        difficult INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      );
    ''');

    // 4. scenario_options
    await db.execute('''
      CREATE TABLE scenario_options (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        is_correct INTEGER NOT NULL,
        feedback TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0
      );
    ''');

    // 5. reviews
    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_id INTEGER NOT NULL,
        at INTEGER NOT NULL,
        result INTEGER NOT NULL,
        stage_before INTEGER NOT NULL,
        stage_after INTEGER NOT NULL
      );
    ''');

    // 6. day_stats
    await db.execute('''
      CREATE TABLE day_stats (
        day_key TEXT PRIMARY KEY,
        total_seconds INTEGER NOT NULL DEFAULT 0,
        goal_seconds INTEGER NOT NULL DEFAULT 5400,
        sessions_count INTEGER NOT NULL DEFAULT 0,
        reviews_done INTEGER NOT NULL DEFAULT 0,
        reviews_correct INTEGER NOT NULL DEFAULT 0,
        goal_met INTEGER NOT NULL DEFAULT 0,
        avg_focus INTEGER NOT NULL DEFAULT 0,
        sleep_hours REAL,
        mood INTEGER,
        exercise INTEGER,
        screen_minutes INTEGER
      );
    ''');

    // 7. card_links (yengil knowledge graph)
    await db.execute('''
      CREATE TABLE card_links (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        from_card_id INTEGER NOT NULL,
        to_card_id INTEGER NOT NULL,
        relation TEXT NOT NULL,
        created_at INTEGER NOT NULL
      );
    ''');

    // 8. paths & path_items
    await db.execute('''
      CREATE TABLE paths (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        subject_id INTEGER NOT NULL,
        note TEXT,
        created_at INTEGER NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE path_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        note TEXT,
        status TEXT NOT NULL DEFAULT 'todo',
        sort_order INTEGER NOT NULL DEFAULT 0,
        done_at INTEGER
      );
    ''');
  }
}
