import 'package:test/test.dart';
import 'package:chalgima/srs/scheduler.dart';
import 'package:chalgima/models/card.dart';

void main() {
  group('SrsScheduler - 5.1 Kun chegarasi (04:00)', () {
    test('Soat 01:30 da kechagi kun kaliti qaytariladi', () {
      final night = DateTime(2026, 9, 27, 1, 30);
      final key = SrsScheduler.getDayKey(night);
      expect(key, '2026-09-26');
    });

    test('Soat 04:01 da bugungi kun kaliti qaytariladi', () {
      final morning = DateTime(2026, 9, 27, 4, 1);
      final key = SrsScheduler.getDayKey(morning);
      expect(key, '2026-09-27');
    });
  });

  group('SrsScheduler - 5.4 Esladim va Unutdim', () {
    final sampleCard = FlashCard(
      id: 1,
      subjectId: 1,
      type: 'qa',
      question: 'Savol',
      answer: 'Javob',
      stage: 1,
      intervalDays: 1,
      nextDue: '2026-09-27',
      correctCount: 1,
      wrongCount: 0,
      streakCorrect: 1,
      status: 'active',
      difficult: false,
      createdAt: 1000,
    );

    test('Esladim: stage 1 dan 2 ga oshadi, interval 3 kun boʻladi', () {
      final res = SrsScheduler.processRemembered(sampleCard, '2026-09-27');
      expect(res['stage'], 2);
      expect(res['interval_days'], 3);
      expect(res['next_due'], '2026-09-30');
      expect(res['correct_count'], 2);
      expect(res['streak_correct'], 2);
    });

    test('Unutdim: stage 1 ga qaytadi (0 ga emas), ertaga takrorlanadi', () {
      final res = SrsScheduler.processForgot(sampleCard, '2026-09-27');
      expect(res['stage'], 1);
      expect(res['interval_days'], 1);
      expect(res['next_due'], '2026-09-28');
      expect(res['wrong_count'], 1);
      expect(res['streak_correct'], 0);
    });

    test('Vaziyat kartochkasi sekinroq unutiladi (uzunroq intervallar)', () {
      final scenarioCard = FlashCard(
        id: 2,
        subjectId: 1,
        type: 'scenario',
        question: 'Vaziyat',
        answer: 'Sabab',
        stage: 0,
        intervalDays: 0,
        nextDue: '2026-09-27',
        correctCount: 0,
        wrongCount: 0,
        streakCorrect: 0,
        status: 'active',
        difficult: false,
        createdAt: 1000,
      );

      final res = SrsScheduler.processRemembered(scenarioCard, '2026-09-27');
      expect(res['stage'], 1);
      expect(res['interval_days'], 3); // 3 kun
      expect(res['next_due'], '2026-09-30');
    });
  });

  group('SrsScheduler - 5.7 Focus Score', () {
    test('Baholash toʻliq va chalgʻishsiz boʻlsa 100 beradi', () {
      final res = SrsScheduler.calculateFocusScore(
        rating: 5,
        distractionCount: 0,
        pauseSeconds: 0,
        netSeconds: 1500,
      );
      expect(res.score, 100);
      expect(res.isEstimated, false);
    });

    test('Baho berilmaganda rating = 3 deb hisoblanadi va taxminiy belgilanadi', () {
      final res = SrsScheduler.calculateFocusScore(
        rating: null,
        distractionCount: 0,
        pauseSeconds: 0,
        netSeconds: 1500,
      );
      expect(res.score, 60);
      expect(res.isEstimated, true);
    });

    test('Chalgʻish va pauza jazolari toʻgʻri hisoblanadi va 0-100 dan chiqmaydi', () {
      final res = SrsScheduler.calculateFocusScore(
        rating: 2, // 40
        distractionCount: 5, // -30
        pauseSeconds: 1000,
        netSeconds: 200, // pauseRatio ~83% => -17
      );
      expect(res.score, 0); // clamp 0
    });
  });

  group('SrsScheduler - 5.4 buildTodayQueue va Interleaving', () {
    test('Fanlar ketma-ket kelmasligi uchun aralashtiriladi', () {
      final cards = [
        FlashCard(
          id: 1, subjectId: 1, type: 'qa', question: 'Q1', answer: 'A1',
          stage: 1, intervalDays: 1, nextDue: '2026-09-27', correctCount: 0,
          wrongCount: 0, streakCorrect: 0, status: 'active', difficult: false, createdAt: 1,
        ),
        FlashCard(
          id: 2, subjectId: 1, type: 'qa', question: 'Q2', answer: 'A2',
          stage: 1, intervalDays: 1, nextDue: '2026-09-27', correctCount: 0,
          wrongCount: 0, streakCorrect: 0, status: 'active', difficult: false, createdAt: 2,
        ),
        FlashCard(
          id: 3, subjectId: 2, type: 'qa', question: 'Q3', answer: 'A3',
          stage: 1, intervalDays: 1, nextDue: '2026-09-27', correctCount: 0,
          wrongCount: 0, streakCorrect: 0, status: 'active', difficult: false, createdAt: 3,
        ),
      ];

      final queue = SrsScheduler.buildTodayQueue(cards: cards, todayKey: '2026-09-27');
      expect(queue.length, 3);
      // Fanlar navbati: 1 -> 2 -> 1
      expect(queue[0].subjectId, 1);
      expect(queue[1].subjectId, 2);
      expect(queue[2].subjectId, 1);
    });
  });
}
