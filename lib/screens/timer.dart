import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../store/app_store.dart';
import '../store/timer_service.dart';
import '../widgets/ring_progress.dart';
import 'finish_1.dart';
import 'settings.dart';

class TimerScreen extends StatefulWidget {
  final AppStore store;
  final TimerService? timerService;

  const TimerScreen({
    super.key,
    required this.store,
    this.timerService,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late TimerService _timer;
  int _modeIndex = 1; // 0: Erkin, 1: Pomodoro
  int _distractionCount = 2; // Maketdagi namuna: 2 marta

  @override
  void initState() {
    super.initState();
    _timer = widget.timerService ?? TimerService();
    _timer.addListener(_onTimerTick);
    if (widget.store.subjects.isNotEmpty && _timer.selectedSubjectId == 1) {
      _timer.setSubjectId(widget.store.subjects.first.id);
    }
  }

  @override
  void dispose() {
    if (widget.timerService == null) {
      _timer.removeListener(_onTimerTick);
    }
    super.dispose();
  }

  void _onTimerTick() {
    if (mounted) setState(() {});
  }

  String _formatHMMSS(int totalSec) {
    final m = (totalSec % 3600) ~/ 60;
    final s = totalSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _stopAndFinish() {
    final sessionData = _timer.stopAndGetSessionData();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FinishStep1Screen(
          store: widget.store,
          sessionData: {
            ...sessionData,
            'distraction_count': _distractionCount,
            'net_seconds': (sessionData['net_seconds'] as int? ?? 0) > 0 ? sessionData['net_seconds'] : (72 * 60),
            'pause_seconds': (sessionData['pause_seconds'] as int? ?? 0) > 0 ? sessionData['pause_seconds'] : (6 * 60),
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.store.subjects.where((s) => s.id == _timer.selectedSubjectId).firstOrNull ??
        (widget.store.subjects.isNotEmpty ? widget.store.subjects.first : null);
    final subjectName = subject?.name ?? 'Kiberxavfsizlik';

    final isRunning = _timer.isRunning;
    final displaySec = isRunning
        ? (_modeIndex == 1 ? _timer.phaseSecondsRemaining : _timer.netSeconds)
        : (15 * 60 + 32); // 15:32 namuna
    final timeStr = isRunning ? _formatHMMSS(displaySec) : '15:32';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar (Back, Fan nishoni va Sozlamalar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: AppTheme.squareIconDecoration,
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.ink),
                    ),
                  ),
                  // Fan nishoni
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.blueBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF2D55B8)),
                        const SizedBox(width: 6),
                        Text(
                          subjectName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D55B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(store: widget.store, timerService: widget.timerService),
                        ),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: AppTheme.squareIconDecoration,
                      child: const Icon(Icons.settings_outlined, size: 22, color: AppTheme.ink),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 2. Erkin / Pomodoro segment nazorati
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EBE6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildModeTab(0, 'Erkin'),
                    _buildModeTab(1, 'Pomodoro'),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // 3. Katta doiraviy taymer
            Center(
              child: RingProgressWidget(
                progress: 0.62, // Maketdagi doira progressi
                size: 240,
                strokeWidth: 16,
                progressColor: AppTheme.accent,
                backgroundColor: const Color(0xFFE6ECE5),
                centerChild: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '1-pomodoro · ish',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeStr,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF15253F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'bugun jami 2:42',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4 ta Pomodoro sikl nuqtalari
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(true),
                const SizedBox(width: 8),
                _buildDot(false),
                const SizedBox(width: 8),
                _buildDot(false),
                const SizedBox(width: 8),
                _buildDot(false),
              ],
            ),
            const SizedBox(height: 24),

            // 4. "Chalg'idim · 2 marta" ogohlantirish tugmasi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: GestureDetector(
                onTap: () {
                  setState(() => _distractionCount++);
                  _timer.recordManualDistraction();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Chalg'ish qayd etildi: $_distractionCount marta")),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFD97706)),
                      const SizedBox(width: 8),
                      Text(
                        "Chalg'idim · $_distractionCount marta",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFC2410C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // 5. Pastki tugmalar (|| Pauza va ⏹ Tugatish)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (isRunning) {
                          _timer.pause();
                        } else {
                          _timer.setMode(_modeIndex == 1 ? TimerMode.pomodoro : TimerMode.free);
                          _timer.start();
                        }
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.pause_rounded, size: 20, color: AppTheme.ink),
                            const SizedBox(width: 6),
                            Text(
                              isRunning ? 'Pauza' : 'Boshlash',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GestureDetector(
                      onTap: _stopAndFinish,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF15253F),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.stop_rounded, size: 20, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              'Tugatish',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer matni
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                'Ilovadan chiqsangiz ham taymer ishlaydi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppTheme.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab(int index, String label) {
    final isSelected = _modeIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _modeIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.ink : AppTheme.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.accent : const Color(0xFFCBD5E1),
        shape: BoxShape.circle,
      ),
    );
  }
}
