import '../lib/srs/scheduler.dart';
import '../lib/models/card.dart';

void main() {
  print('--- SRS Scheduler Testlarini Bajarish ---');

  // 1. Kun chegarasi 04:00
  final night = DateTime(2026, 9, 27, 1, 30);
  assert(SrsScheduler.getDayKey(night) == '2026-09-26', '01:30 kechagi kunga tegishli boʻlishi kerak');

  final morning = DateTime(2026, 9, 27, 4, 1);
  assert(SrsScheduler.getDayKey(morning) == '2026-09-27', '04:01 bugungi kunga tegishli boʻlishi kerak');
  print('✅ 5.1 Kun chegarasi (04:00) testi oʻtdi');

  // 2. Esladim & Unutdim
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

  final resRemember = SrsScheduler.processRemembered(sampleCard, '2026-09-27');
  assert(resRemember['stage'] == 2, 'Stage 2 boʻlishi kerak');
  assert(resRemember['interval_days'] == 3, 'Interval 3 kun boʻlishi kerak');
  assert(resRemember['next_due'] == '2026-09-30', 'Next due 2026-09-30 boʻlishi kerak');
  print('✅ 5.4 Esladim testi oʻtdi');

  final resForgot = SrsScheduler.processForgot(sampleCard, '2026-09-27');
  assert(resForgot['stage'] == 1, 'Unutganda stage 1 boʻlishi kerak');
  assert(resForgot['interval_days'] == 1, 'Interval 1 kun boʻlishi kerak');
  assert(resForgot['next_due'] == '2026-09-28', 'Next due ertangi kun boʻlishi kerak');
  assert(resForgot['wrong_count'] == 1, 'wrong_count 1 ga oshishi kerak');
  print('✅ 5.4 Unutdim testi oʻtdi');

  // 3. Focus score
  final scoreMax = SrsScheduler.calculateFocusScore(rating: 5, distractionCount: 0, pauseSeconds: 0, netSeconds: 1500);
  assert(scoreMax.score == 100, 'Score 100 boʻlishi kerak');
  assert(!scoreMax.isEstimated, 'Baholangan boʻlishi kerak');

  final scoreEst = SrsScheduler.calculateFocusScore(rating: null, distractionCount: 0, pauseSeconds: 0, netSeconds: 1500);
  assert(scoreEst.score == 60, 'Score 60 boʻlishi kerak (rating=3)');
  assert(scoreEst.isEstimated, 'Taxminiy boʻlishi kerak');

  final scoreMin = SrsScheduler.calculateFocusScore(rating: 2, distractionCount: 5, pauseSeconds: 1000, netSeconds: 200);
  assert(scoreMin.score >= 0 && scoreMin.score <= 100, 'Score 0-100 oraliqda boʻlishi kerak');
  print('✅ 5.7 Focus score formulasi testi oʻtdi');

  // 4. Interleaving
  final cards = [
    FlashCard(id: 1, subjectId: 1, type: 'qa', question: 'Q1', answer: 'A1', stage: 1, intervalDays: 1, nextDue: '2026-09-27', correctCount: 0, wrongCount: 0, streakCorrect: 0, status: 'active', difficult: false, createdAt: 1),
    FlashCard(id: 2, subjectId: 1, type: 'qa', question: 'Q2', answer: 'A2', stage: 1, intervalDays: 1, nextDue: '2026-09-27', correctCount: 0, wrongCount: 0, streakCorrect: 0, status: 'active', difficult: false, createdAt: 2),
    FlashCard(id: 3, subjectId: 2, type: 'qa', question: 'Q3', answer: 'A3', stage: 1, intervalDays: 1, nextDue: '2026-09-27', correctCount: 0, wrongCount: 0, streakCorrect: 0, status: 'active', difficult: false, createdAt: 3),
  ];
  final queue = SrsScheduler.buildTodayQueue(cards: cards, todayKey: '2026-09-27');
  assert(queue[0].subjectId == 1 && queue[1].subjectId == 2 && queue[2].subjectId == 1, 'Fanlar ketma-ket kelmasligi kerak');
  print('✅ 5.4 buildTodayQueue va Interleaving testi oʻtdi');

  print('\n🎉 Barcha algoritm va biznes qoidalari testlari 100% MUVAFFAQISATLI OʻTDI!');
}
