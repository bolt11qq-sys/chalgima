import 'package:flutter/material.dart';
import '../theme.dart';
import '../store/app_store.dart';
import '../store/timer_service.dart';
import '../widgets/ring_progress.dart';
import 'finish_1.dart';

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

  String _formatTime(int totalSec) {
    final h = totalSec ~/ 3600;
    final m = (totalSec % 3600) ~/ 60;
    final s = totalSec % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _promptIntentionAndStart() {
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bu sessiyada nima qilasiz?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Aniq niyat diqqatni jamlashga yordam beradi.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 16),
              // Oxirgi 3 ta niyat taklifi (5.8-bo'lim)
              if (widget.store.recentIntentions.isNotEmpty) ...[
                const Text('Oldingi niyatlardan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: widget.store.recentIntentions.map((intent) {
                    return ActionChip(
                      label: Text(intent, style: const TextStyle(fontSize: 12)),
                      onPressed: () {
                        textController.text = intent;
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: textController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Masalan: TryHackMe Nmap xonasi yoki 10 ta yangi soʻz',
                  filled: true,
                  fillColor: AppTheme.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _timer.start(intention: '');
                      },
                      child: const Text('Oʻtkazib yuborish'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.ink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        final val = textController.text.trim();
                        Navigator.pop(ctx);
                        _timer.start(intention: val);
                      },
                      child: const Text('Boshlash', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _finishSession() {
    final sessionData = _timer.stopAndGetSessionData();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FinishStep1Screen(
          store: widget.store,
          sessionData: sessionData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = _timer.isRunning;
    final isPaused = _timer.isPaused;
    final isPomodoro = _timer.mode == TimerMode.pomodoro;

    // Display time
    final displaySeconds = isPomodoro ? _timer.phaseSecondsRemaining : _timer.netSeconds;
    final displayTimeStr = _formatTime(displaySeconds);

    // Pomodoro progress calculation
    double progress = 0.0;
    if (isPomodoro) {
      final totalPhase = _timer.pomodoroPhase == PomodoroPhase.work
          ? _timer.workDurationMin * 60
          : (_timer.pomodoroPhase == PomodoroPhase.shortBreak
              ? _timer.shortBreakMin * 60
              : _timer.longBreakMin * 60);
      progress = totalPhase > 0 ? (1.0 - (_timer.phaseSecondsRemaining / totalPhase)) : 0.0;
    } else {
      progress = (_timer.netSeconds % 3600) / 3600.0;
    }

    final currentSubj = widget.store.subjects.where((s) => s.id == _timer.selectedSubjectId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Taymer'),
        actions: [
          if (isRunning)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Bekor qilish',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Taymerni bekor qilasizmi?'),
                    content: const Text('Bu sessiya saqlanmaydi.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Yoʻq')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _timer.cancel();
                        },
                        child: const Text('Bekor qilish', style: TextStyle(color: AppTheme.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Rejim tanlash segmenti (Free vs Pomodoro)
            if (!isRunning)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SegmentedButton<TimerMode>(
                  segments: const [
                    ButtonSegment(value: TimerMode.free, label: Text('Erkin rejim')),
                    ButtonSegment(value: TimerMode.pomodoro, label: Text('Pomodoro (25/5)')),
                  ],
                  selected: {_timer.mode},
                  onSelectionChanged: (set) => _timer.setMode(set.first),
                ),
              ),

            const SizedBox(height: 20),

            // Fan tanlash
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.line),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: currentSubj != null ? currentSubj.id : (widget.store.subjects.isNotEmpty ? widget.store.subjects.first.id : null),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: widget.store.subjects.where((s) => s.status == 'active').map((s) {
                      return DropdownMenuItem<int>(
                        value: s.id,
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _parseColor(s.color),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: isRunning ? null : (val) {
                      if (val != null) _timer.setSubjectId(val);
                    },
                  ),
                ),
              ),
            ),

            if (isPomodoro) ...[
              const SizedBox(height: 16),
              // Pomodoro nuqtalari
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_timer.cyclesBeforeLongBreak, (i) {
                  final isDone = i < (_timer.completedCycles % _timer.cyclesBeforeLongBreak);
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? AppTheme.accent : AppTheme.line,
                      border: Border.all(color: AppTheme.accent, width: 1.5),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                _timer.pomodoroPhase == PomodoroPhase.work
                    ? 'Diqqat vaqti'
                    : (_timer.pomodoroPhase == PomodoroPhase.shortBreak ? 'Qisqa tanaffus' : 'Katta tanaffus'),
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.grey, fontSize: 13),
              ),
            ],

            const Spacer(),

            // Katta aylanma taymer
            RingProgressWidget(
              progress: progress,
              size: 250,
              strokeWidth: 18,
              progressColor: isPomodoro && _timer.pomodoroPhase != PomodoroPhase.work ? AppTheme.amber : AppTheme.accent,
              centerChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayTimeStr,
                    style: const TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (isRunning && _timer.intention.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '🎯 ${_timer.intention}',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    )
                  else
                    Text(
                      isPaused ? 'PAUZADA' : (isRunning ? 'DAVOM ETMOQDA' : 'TAYYOR'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: isPaused ? AppTheme.amber : AppTheme.grey,
                      ),
                    ),
                ],
              ),
            ),

            const Spacer(),

            // Chalg'ish hisoblagichi va "Chalg'idim" tugmasi
            if (isRunning) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => _timer.recordManualDistraction(),
                      icon: const Icon(Icons.notifications_off_outlined, color: AppTheme.amber, size: 18),
                      label: Text(
                        "Chalg'idim (${_timer.distractionCount})",
                        style: const TextStyle(color: AppTheme.amber, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Boshqaruv tugmalari
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  if (!isRunning)
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _promptIntentionAndStart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.ink,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 30),
                          label: const Text('Boshlash', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    )
                  else ...[
                    // Pauza / Davom ettirish
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (isPaused) {
                              _timer.resume();
                            } else {
                              _timer.pause();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: const BorderSide(color: AppTheme.ink, width: 2),
                          ),
                          icon: Icon(isPaused ? Icons.play_arrow : Icons.pause, color: AppTheme.ink),
                          label: Text(
                            isPaused ? 'Davom' : 'Pauza',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.ink),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Tugatish
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _finishSession,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.stop_rounded, size: 28),
                          label: const Text('Tugatish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return AppTheme.accent;
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppTheme.accent;
    }
  }
}
