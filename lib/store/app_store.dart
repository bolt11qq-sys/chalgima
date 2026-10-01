import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../db/database.dart';
import '../models/subject.dart';
import '../models/session.dart';
import '../models/card.dart';
import '../models/review.dart';
import '../models/path.dart';
import '../srs/scheduler.dart';

class AppStore extends ChangeNotifier {
  List<Subject> subjects = [];
  List<FlashCard> cards = [];
  List<StudySession> sessions = [];
  List<LearningPath> paths = [];
  Map<String, dynamic> todayStats = {};
  List<DayStat> recentDayStats = [];
  List<String> recentIntentions = [];

  int currentStreak = 0;
  bool isLoaded = false;

  // Sozlamalar (standart qiymatlar)
  int dailyGoalMinutes = 90;
  int srsDailyLimit = 20;
  int srsNewLimit = 10;
  int srsScenarioLimit = 3;
  bool dndEnabled = false;

  Future<void> init() async {
    await reloadAll();
  }

  Future<void> reloadAll() async {
    final db = await AppDatabase.instance;
    final today = SrsScheduler.getDayKey();

    // 1. Fanlar
    final sMaps = await db.query('subjects', orderBy: 'sort_order ASC');
    subjects = sMaps.map((m) => Subject.fromMap(m)).toList();

    // 2. Kartochkalar
    final cMaps = await db.query('cards', orderBy: 'id DESC');
    final List<FlashCard> loadedCards = [];
    for (final m in cMaps) {
      List<ScenarioOption>? opts;
      if (m['type'] == 'scenario') {
        final optMaps = await db.query(
          'scenario_options',
          where: 'card_id = ?',
          whereArgs: [m['id']],
          orderBy: 'sort_order ASC',
        );
        opts = optMaps.map((om) => ScenarioOption.fromMap(om)).toList();
      }
      loadedCards.add(FlashCard.fromMap(m, opts));
    }
    cards = loadedCards;

    // 3. Sessiyalar
    final sessMaps = await db.query('sessions', orderBy: 'start_at DESC', limit: 100);
    sessions = sessMaps.map((m) => StudySession.fromMap(m)).toList();

    // Oxirgi niyatlar
    recentIntentions = sessions
        .where((s) => s.intention != null && s.intention!.trim().isNotEmpty)
        .map((s) => s.intention!.trim())
        .toSet()
        .take(3)
        .toList();

    // 4. O'quv yo'llari (Paths)
    final pathMaps = await db.query('paths', orderBy: 'created_at DESC');
    final List<LearningPath> loadedPaths = [];
    for (final pm in pathMaps) {
      final itemMaps = await db.query(
        'path_items',
        where: 'path_id = ?',
        whereArgs: [pm['id']],
        orderBy: 'sort_order ASC',
      );
      final items = itemMaps.map((im) => PathItem.fromMap(im)).toList();
      loadedPaths.add(LearningPath.fromMap(pm, items));
    }
    paths = loadedPaths;

    // 5. Bugungi statistika
    final statMaps = await db.query('day_stats', where: 'day_key = ?', whereArgs: [today]);
    if (statMaps.isNotEmpty) {
      todayStats = Map<String, dynamic>.from(statMaps.first);
    } else {
      todayStats = {
        'day_key': today,
        'total_seconds': 0,
        'goal_seconds': dailyGoalMinutes * 60,
        'sessions_count': 0,
        'reviews_done': 0,
        'reviews_correct': 0,
        'goal_met': 0,
        'avg_focus': 0,
      };
    }

    // Oxirgi kunlar statistikasi
    final allStats = await db.query('day_stats', orderBy: 'day_key DESC', limit: 30);
    recentDayStats = allStats.map((m) => DayStat.fromMap(m)).toList();

    _calculateStreak(today);

    isLoaded = true;
    notifyListeners();
  }

  // 5.3 Streak hisoblash (day_stats bo'yicha)
  void _calculateStreak(String todayKey) {
    if (recentDayStats.isEmpty) {
      currentStreak = 0;
      return;
    }

    int streak = 0;
    String checkKey = todayKey;

    // Bugungi kun maqsadning yarmiga yetgan bo'lsa streakka qo'shiladi
    final todaySec = (todayStats['total_seconds'] as num?)?.toInt() ?? 0;
    final todayGoal = (todayStats['goal_seconds'] as num?)?.toInt() ?? (dailyGoalMinutes * 60);
    final todayCounted = todaySec >= (todayGoal / 2);

    if (todayCounted) {
      streak++;
      checkKey = SrsScheduler.addDaysToKey(checkKey, -1);
    } else {
      // Bugun hali o'qilmagan bo'lsa ham kechagi kundan tekshirish davom etadi
      checkKey = SrsScheduler.addDaysToKey(checkKey, -1);
    }

    int graceDaysUsed = 0; // Oyiga 1 ta dam olish kuni imtiyozi

    for (int i = 0; i < 60; i++) {
      final stat = recentDayStats.where((s) => s.dayKey == checkKey).firstOrNull;
      if (stat != null && stat.totalSeconds >= (stat.goalSeconds / 2)) {
        streak++;
      } else {
        if (graceDaysUsed < 1) {
          graceDaysUsed++;
          // Dam olish kuni streakni uzmaydi
        } else {
          break;
        }
      }
      checkKey = SrsScheduler.addDaysToKey(checkKey, -1);
    }

    currentStreak = streak;
  }

  // Bugungi SRS navbati
  List<FlashCard> getTodayQueue() {
    final todayKey = SrsScheduler.getDayKey();
    return SrsScheduler.buildTodayQueue(
      cards: cards,
      todayKey: todayKey,
      dailyLimit: srsDailyLimit,
      newLimit: srsNewLimit,
      scenarioLimit: srsScenarioLimit,
    );
  }

  // Qiyin kartochkalar mashqi uchun (5.11 bo'lim)
  List<FlashCard> getDifficultCards() {
    return cards.where((c) => c.status == 'active' && c.difficult).toList();
  }

  // Kartochkani takrorlash
  Future<void> reviewCard(int cardId, bool remembered) async {
    final db = await AppDatabase.instance;
    final card = cards.firstWhere((c) => c.id == cardId);
    final today = SrsScheduler.getDayKey();

    final updates = remembered
        ? SrsScheduler.processRemembered(card, today)
        : SrsScheduler.processForgot(card, today);

    await db.update('cards', updates, where: 'id = ?', whereArgs: [cardId]);

    // Tarixga yozish
    await db.insert('reviews', {
      'card_id': cardId,
      'at': DateTime.now().millisecondsSinceEpoch,
      'result': remembered ? 1 : 0,
      'stage_before': card.stage,
      'stage_after': updates['stage'],
    });

    // Bugungi day_stats ni yangilash
    final curDone = (todayStats['reviews_done'] as num?)?.toInt() ?? 0;
    final curCorr = (todayStats['reviews_correct'] as num?)?.toInt() ?? 0;

    await db.insert(
      'day_stats',
      {
        'day_key': today,
        'reviews_done': curDone + 1,
        'reviews_correct': curCorr + (remembered ? 1 : 0),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    await db.rawUpdate('''
      UPDATE day_stats 
      SET reviews_done = reviews_done + 1,
          reviews_correct = reviews_correct + ?
      WHERE day_key = ?
    ''', [remembered ? 1 : 0, today]);

    await reloadAll();
  }

  // 5.5 Sessiyani yakunlash oqimi natijasini saqlash
  Future<void> saveCompletedSession({
    required Map<String, dynamic> baseData,
    required int? rating,
    required String? note,
    required String kind,
    required int? intentionDone,
    required List<String> quickCardsText, // "savol :: javob"
  }) async {
    final db = await AppDatabase.instance;
    final today = baseData['day_key'] ?? SrsScheduler.getDayKey();

    // 5.7 Focus score hisoblash
    final focusCalc = SrsScheduler.calculateFocusScore(
      rating: rating,
      distractionCount: baseData['distraction_count'] ?? 0,
      pauseSeconds: baseData['pause_seconds'] ?? 0,
      netSeconds: baseData['net_seconds'] ?? 0,
    );

    int cardsCount = 0;

    // 1. Sessiyani saqlash
    final sessionId = await db.insert('sessions', {
      'subject_id': baseData['subject_id'],
      'start_at': baseData['start_at'],
      'end_at': baseData['end_at'],
      'net_seconds': baseData['net_seconds'],
      'pause_seconds': baseData['pause_seconds'],
      'distraction_count': baseData['distraction_count'],
      'mode': baseData['mode'],
      'rating': rating,
      'note': note,
      'day_key': today,
      'confirmed': baseData['confirmed'] ?? 1,
      'intention': baseData['intention'],
      'intention_done': intentionDone,
      'kind': kind,
      'focus_score': focusCalc.score,
      'cards_created': 0,
    });

    // 2. Tez kartochkalarni qo'shish ("savol :: javob")
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final line in quickCardsText) {
      if (line.contains('::')) {
        final parts = line.split('::');
        final q = parts[0].trim();
        final a = parts.sublist(1).join('::').trim();
        if (q.isNotEmpty && a.isNotEmpty) {
          await db.insert('cards', {
            'subject_id': baseData['subject_id'],
            'session_id': sessionId,
            'type': 'qa',
            'question': q,
            'answer': a,
            'stage': 0,
            'interval_days': 0,
            'next_due': today,
            'correct_count': 0,
            'wrong_count': 0,
            'streak_correct': 0,
            'status': 'active',
            'difficult': 0,
            'created_at': now,
          });
          cardsCount++;
        }
      }
    }

    if (cardsCount > 0) {
      await db.update('sessions', {'cards_created': cardsCount}, where: 'id = ?', whereArgs: [sessionId]);
    }

    // 3. Fanning total_seconds ni oshirish
    await db.rawUpdate('''
      UPDATE subjects 
      SET total_seconds = total_seconds + ? 
      WHERE id = ?
    ''', [baseData['net_seconds'], baseData['subject_id']]);

    // 4. Bugungi day_stats ni yangilash
    final netSec = baseData['net_seconds'] as int;
    final statRow = await db.query('day_stats', where: 'day_key = ?', whereArgs: [today]);
    final goalSec = dailyGoalMinutes * 60;

    if (statRow.isEmpty) {
      await db.insert('day_stats', {
        'day_key': today,
        'total_seconds': netSec,
        'goal_seconds': goalSec,
        'sessions_count': 1,
        'reviews_done': 0,
        'reviews_correct': 0,
        'goal_met': netSec >= goalSec ? 1 : 0,
        'avg_focus': focusCalc.score,
      });
    } else {
      final prevSec = (statRow.first['total_seconds'] as num).toInt();
      final prevFocus = (statRow.first['avg_focus'] as num).toInt();
      final prevCount = (statRow.first['sessions_count'] as num).toInt();

      final newTotalSec = prevSec + netSec;
      final newAvgFocus = ((prevFocus * prevCount) + focusCalc.score) ~/ (prevCount + 1);

      await db.update(
        'day_stats',
        {
          'total_seconds': newTotalSec,
          'sessions_count': prevCount + 1,
          'goal_met': newTotalSec >= goalSec ? 1 : 0,
          'avg_focus': newAvgFocus,
        },
        where: 'day_key = ?',
        whereArgs: [today],
      );
    }

    await reloadAll();
  }

  // Fan qo'shish / tahrirlash
  Future<void> saveSubject(Subject s) async {
    final db = await AppDatabase.instance;
    if (s.id > 0) {
      await db.update('subjects', s.toMap(), where: 'id = ?', whereArgs: [s.id]);
    } else {
      await db.insert('subjects', s.toMap());
    }
    await reloadAll();
  }

  // Kartochka qo'shish / tahrirlash
  Future<void> saveCard({
    required FlashCard card,
    List<Map<String, dynamic>>? scenarioOptions,
  }) async {
    final db = await AppDatabase.instance;
    if (card.id > 0) {
      await db.update('cards', card.toMap(), where: 'id = ?', whereArgs: [card.id]);
      if (card.type == 'scenario' && scenarioOptions != null) {
        await db.delete('scenario_options', where: 'card_id = ?', whereArgs: [card.id]);
        int order = 1;
        for (final opt in scenarioOptions) {
          await db.insert('scenario_options', {
            'card_id': card.id,
            'text': opt['text'],
            'is_correct': opt['is_correct'] == true || opt['is_correct'] == 1 ? 1 : 0,
            'feedback': opt['feedback'],
            'sort_order': order++,
          });
        }
      }
    } else {
      final cardId = await db.insert('cards', card.toMap());
      if (card.type == 'scenario' && scenarioOptions != null) {
        int order = 1;
        for (final opt in scenarioOptions) {
          await db.insert('scenario_options', {
            'card_id': cardId,
            'text': opt['text'],
            'is_correct': opt['is_correct'] == true || opt['is_correct'] == 1 ? 1 : 0,
            'feedback': opt['feedback'],
            'sort_order': order++,
          });
        }
      }
    }
    await reloadAll();
  }

  // Kartochkani o'chirish
  Future<void> deleteCard(int cardId) async {
    final db = await AppDatabase.instance;
    await db.delete('scenario_options', where: 'card_id = ?', whereArgs: [cardId]);
    await db.delete('reviews', where: 'card_id = ?', whereArgs: [cardId]);
    await db.delete('cards', where: 'id = ?', whereArgs: [cardId]);
    await reloadAll();
  }

  // Life Detective ma'lumotlarini saqlash (5.10)
  Future<void> saveLifeDetective({
    required double sleepHours,
    required int mood,
    required int exercise,
  }) async {
    final db = await AppDatabase.instance;
    final today = SrsScheduler.getDayKey();

    await db.rawUpdate('''
      UPDATE day_stats 
      SET sleep_hours = ?, mood = ?, exercise = ?
      WHERE day_key = ?
    ''', [sleepHours, mood, exercise, today]);

    await reloadAll();
  }

  // O'quv yo'li element holatini o'zgartirish
  Future<void> togglePathItem(int itemId, String newStatus) async {
    final db = await AppDatabase.instance;
    await db.update(
      'path_items',
      {
        'status': newStatus,
        'done_at': newStatus == 'done' ? DateTime.now().millisecondsSinceEpoch : null,
      },
      where: 'id = ?',
      whereArgs: [itemId],
    );
    await reloadAll();
  }

  // Zaxira nusxa: to'liq JSON eksport
  Future<String> exportBackupJson() async {
    final db = await AppDatabase.instance;
    final subj = await db.query('subjects');
    final crds = await db.query('cards');
    final scnOpts = await db.query('scenario_options');
    final sess = await db.query('sessions');
    final stats = await db.query('day_stats');

    final data = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'subjects': subj,
      'cards': crds,
      'scenario_options': scnOpts,
      'sessions': sess,
      'day_stats': stats,
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // JSON tiklash (Restore)
  Future<bool> importBackupJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final db = await AppDatabase.instance;

      await db.transaction((txn) async {
        if (data['subjects'] != null) {
          for (final row in data['subjects']) {
            await txn.insert('subjects', Map<String, dynamic>.from(row), conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
        if (data['cards'] != null) {
          for (final row in data['cards']) {
            await txn.insert('cards', Map<String, dynamic>.from(row), conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
        if (data['scenario_options'] != null) {
          for (final row in data['scenario_options']) {
            await txn.insert('scenario_options', Map<String, dynamic>.from(row), conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
        if (data['sessions'] != null) {
          for (final row in data['sessions']) {
            await txn.insert('sessions', Map<String, dynamic>.from(row), conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
        if (data['day_stats'] != null) {
          for (final row in data['day_stats']) {
            await txn.insert('day_stats', Map<String, dynamic>.from(row), conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      });

      await reloadAll();
      return true;
    } catch (e) {
      debugPrint('Restore error: $e');
      return false;
    }
  }

  // CSV import (savol, javob, fan_nomi)
  Future<int> importCsvCards(String csvContent) async {
    final db = await AppDatabase.instance;
    final lines = csvContent.split('\n');
    final today = SrsScheduler.getDayKey();
    final now = DateTime.now().millisecondsSinceEpoch;
    int imported = 0;

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split(',');
      if (parts.length >= 2) {
        final q = parts[0].trim();
        final a = parts[1].trim();

        // Dublikat tekshirish (5.12)
        final existing = await db.query('cards', where: 'question = ?', whereArgs: [q]);
        if (existing.isNotEmpty) continue;

        int subjectId = subjects.isNotEmpty ? subjects.first.id : 1;
        if (parts.length >= 3) {
          final subjName = parts[2].trim().toLowerCase();
          final matched = subjects.where((s) => s.name.toLowerCase().contains(subjName)).firstOrNull;
          if (matched != null) subjectId = matched.id;
        }

        await db.insert('cards', {
          'subject_id': subjectId,
          'type': 'qa',
          'question': q,
          'answer': a,
          'stage': 0,
          'interval_days': 0,
          'next_due': today,
          'correct_count': 0,
          'wrong_count': 0,
          'streak_correct': 0,
          'status': 'active',
          'difficult': 0,
          'created_at': now,
        });
        imported++;
      }
    }

    if (imported > 0) {
      await reloadAll();
    }
    return imported;
  }
}
