import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../store/app_store.dart';
import '../srs/scheduler.dart';

class SessionEditScreen extends StatefulWidget {
  final AppStore store;

  const SessionEditScreen({super.key, required this.store});

  @override
  State<SessionEditScreen> createState() => _SessionEditScreenState();
}

class _SessionEditScreenState extends State<SessionEditScreen> {
  int _subjectId = 1;
  int _durationMinutes = 90; // 1 soat 30 daqiqa standart
  int _rating = 4;
  final String _kind = 'read';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 0);

  final TextEditingController _noteController = TextEditingController(
    text: "Burp Suite bilan tanishish",
  );

  @override
  void initState() {
    super.initState();
    if (widget.store.subjects.isNotEmpty) {
      _subjectId = widget.store.subjects.first.id;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatDurationText(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) {
      return '$h soat $m daqiqa';
    } else if (h > 0) {
      return '$h soat';
    }
    return '$m daqiqa';
  }

  void _save() async {
    final sessionDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final startAt = sessionDateTime.millisecondsSinceEpoch;
    final netSeconds = _durationMinutes * 60;
    final endAt = startAt + (netSeconds * 1000);
    final dayKey = SrsScheduler.getDayKey(sessionDateTime);

    final baseData = {
      'subject_id': _subjectId,
      'start_at': startAt,
      'end_at': endAt,
      'net_seconds': netSeconds,
      'pause_seconds': 0,
      'distraction_count': 0,
      'mode': 'manual',
      'day_key': dayKey,
      'confirmed': 1,
      'intention': null,
    };

    await widget.store.saveCompletedSession(
      baseData: baseData,
      rating: _rating,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      kind: _kind,
      intentionDone: 1,
      quickCardsText: [],
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessiya muvaffaqiyatli saqlandi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = 'Bugun, ${_selectedDate.day}-sen';
    final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
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
                  Expanded(
                    child: Center(
                      child: Text(
                        "Sessiya qo'shish",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // Fan tanlash
                  Text('Fan', style: AppTheme.sansLabel(fontSize: 12, color: AppTheme.grey)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.blueBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shield_outlined, size: 20, color: Color(0xFF3E5FCC)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _subjectId,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.grey),
                              items: widget.store.subjects.where((s) => s.status == 'active').map((s) {
                                return DropdownMenuItem<int>(
                                  value: s.id,
                                  child: Text(
                                    s.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.ink,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _subjectId = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Sana va Boshlanish
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sana', style: AppTheme.sansLabel(fontSize: 12, color: AppTheme.grey)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2025),
                                  lastDate: DateTime(2030),
                                );
                                if (d != null) setState(() => _selectedDate = d);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFFD97706)),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        dateStr,
                                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.ink),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.grey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Boshlanish', style: AppTheme.sansLabel(fontSize: 12, color: AppTheme.grey)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final t = await showTimePicker(
                                  context: context,
                                  initialTime: _selectedTime,
                                );
                                if (t != null) setState(() => _selectedTime = t);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppTheme.mintBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.accent),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        timeStr,
                                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.ink),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.grey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Davomiyligi
                  Text('Davomiyligi', style: AppTheme.sansLabel(fontSize: 12, color: AppTheme.grey)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Text(
                      _formatDurationText(_durationMinutes),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF15253F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4 ta tezkor davomiylik tugmalari
                  Row(
                    children: [
                      _buildDurationChip(30, '30 daq'),
                      const SizedBox(width: 8),
                      _buildDurationChip(60, '1 soat'),
                      const SizedBox(width: 8),
                      _buildDurationChip(90, '1,5 soat'),
                      const SizedBox(width: 8),
                      _buildDurationChip(120, '2 soat'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Diqqat bahosi (1 dan 5 gacha)
                  Text('Diqqat bahosi', style: AppTheme.sansLabel(fontSize: 12, color: AppTheme.grey)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EBE6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: List.generate(5, (index) {
                        final val = index + 1;
                        final isSelected = _rating == val;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _rating = val),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
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
                                  '$val',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? AppTheme.ink : AppTheme.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nima o'rgandingiz?
                  Text("Nima o'rgandingiz?", style: AppTheme.sansLabel(fontSize: 12, color: AppTheme.grey)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: TextField(
                      controller: _noteController,
                      maxLines: 4,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.ink),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        hintText: 'Burp Suite bilan tanishish',
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),

            // Saqlash tugmasi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Saqlash',
                    style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationChip(int minutes, String label) {
    final isSelected = _durationMinutes == minutes;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _durationMinutes = minutes),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.accent : AppTheme.cardBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppTheme.accent : AppTheme.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
