import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../store/app_store.dart';
import 'finish_2.dart';

class FinishStep1Screen extends StatefulWidget {
  final AppStore store;
  final Map<String, dynamic> sessionData;

  const FinishStep1Screen({
    super.key,
    required this.store,
    required this.sessionData,
  });

  @override
  State<FinishStep1Screen> createState() => _FinishStep1ScreenState();
}

class _FinishStep1ScreenState extends State<FinishStep1Screen> {
  late int _netSeconds;
  int? _intentionDone;

  @override
  void initState() {
    super.initState();
    _netSeconds = widget.sessionData['net_seconds'] ?? (72 * 60); // 1:12 standart
  }

  void _adjustMinutes(int deltaMin) {
    setState(() {
      _netSeconds = (_netSeconds + (deltaMin * 60)).clamp(60, 86400);
    });
  }

  String _formatHMM(int totalSec) {
    final h = totalSec ~/ 3600;
    final m = (totalSec % 3600) ~/ 60;
    return '$h:${m.toString().padLeft(2, '0')}';
  }

  String _formatSessionTimeRange() {
    final startAt = widget.sessionData['start_at'] as int?;
    final endAt = widget.sessionData['end_at'] as int?;
    if (startAt != null && endAt != null) {
      final s = DateTime.fromMillisecondsSinceEpoch(startAt);
      final e = DateTime.fromMillisecondsSinceEpoch(endAt);
      final f = DateFormat('HH:mm');
      return '${f.format(s)} dan ${f.format(e)} gacha';
    }
    return '08:10 dan 09:22 gacha';
  }

  void _saveDirectly() async {
    await widget.store.saveCompletedSession(
      baseData: {
        ...widget.sessionData,
        'net_seconds': _netSeconds,
      },
      rating: 4,
      note: null,
      kind: 'read',
      intentionDone: _intentionDone,
      quickCardsText: [],
    );

    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessiya saqlandi! Baraka toping.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.store.subjects.where((s) => s.id == widget.sessionData['subject_id']).firstOrNull;
    final subjectName = subject?.name ?? 'Kiberxavfsizlik';
    final pauseMins = ((widget.sessionData['pause_seconds'] as int? ?? 360) ~/ 60);
    final distractionCount = widget.sessionData['distraction_count'] as int? ?? 2;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar (Close va 1 / 3)
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
                      child: const Icon(Icons.close_rounded, size: 20, color: AppTheme.ink),
                    ),
                  ),
                  Text(
                    '1 / 3',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.grey,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  const SizedBox(height: 10),
                  // Markaziy katta tasdiq nishoni (Checkmark)
                  Center(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppTheme.mintBg,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.check_rounded, color: AppTheme.accent, size: 32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Sessiya tugadi',
                      style: GoogleFonts.newsreader(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      '$subjectName · ${_formatSessionTimeRange()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppTheme.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Asosiy karta: SOF VAQT va -5 / +5 tugmalari
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: AppTheme.cardDecoration,
                    child: Column(
                      children: [
                        Text(
                          'SOF VAQT',
                          style: AppTheme.sansLabel(fontSize: 11, color: AppTheme.grey),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _adjustMinutes(-5),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAECE7),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    '−5',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.ink,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                _formatHMM(_netSeconds),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF15253F),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _adjustMinutes(5),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAECE7),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    '+5',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.ink,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          "Pauza $pauseMins daq   ·   Chalg'ish $distractionCount marta",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chalg'ish haqida ogohlantirish kartasi
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFD97706)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            "O'qish paytida $distractionCount marta boshqa ilovaga o'tdingiz, jami 4 daqiqa.",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: const Color(0xFF374151),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Pastki tugmalar (Tafsilot qo'shish va Saqlash)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FinishStep2Screen(
                              store: widget.store,
                              sessionData: {
                                ...widget.sessionData,
                                'net_seconds': _netSeconds,
                              },
                              intentionDone: _intentionDone,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Center(
                          child: Text(
                            "Tafsilot qo'shish",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _saveDirectly,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Saqlash',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
