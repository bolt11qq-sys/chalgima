import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../store/app_store.dart';
import '../models/card.dart';
import '../srs/scheduler.dart';

class CardEditScreen extends StatefulWidget {
  final AppStore store;
  final FlashCard? cardToEdit;

  const CardEditScreen({
    super.key,
    required this.store,
    this.cardToEdit,
  });

  @override
  State<CardEditScreen> createState() => _CardEditScreenState();
}

class _CardEditScreenState extends State<CardEditScreen> {
  final _formKey = GlobalKey<FormState>();
  int _tabIndex = 0; // 0: Savol - javob, 1: Bo'sh joy
  late int _subjectId;
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late TextEditingController _hintController;

  @override
  void initState() {
    super.initState();
    final c = widget.cardToEdit;
    _subjectId = c?.subjectId ?? (widget.store.subjects.isNotEmpty ? widget.store.subjects.first.id : 1);
    _questionController = TextEditingController(
      text: c?.question ?? "Nmap'da SYN skanerlash bayrog'i qaysi?",
    );
    _answerController = TextEditingController(text: c?.answer ?? "-sS");
    _hintController = TextEditingController(
      text: c?.hint ?? "Yarim ochiq skanerlash, logga tushmaydi",
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final today = SrsScheduler.getDayKey();
    final now = DateTime.now().millisecondsSinceEpoch;

    final card = FlashCard(
      id: widget.cardToEdit?.id ?? 0,
      subjectId: _subjectId,
      sessionId: widget.cardToEdit?.sessionId,
      type: _tabIndex == 1 ? 'cloze' : 'qa',
      question: _questionController.text.trim(),
      answer: _answerController.text.trim(),
      hint: _hintController.text.trim().isNotEmpty ? _hintController.text.trim() : null,
      stage: widget.cardToEdit?.stage ?? 0,
      intervalDays: widget.cardToEdit?.intervalDays ?? 0,
      nextDue: widget.cardToEdit?.nextDue ?? today,
      lastSeen: widget.cardToEdit?.lastSeen,
      correctCount: widget.cardToEdit?.correctCount ?? 0,
      wrongCount: widget.cardToEdit?.wrongCount ?? 0,
      streakCorrect: widget.cardToEdit?.streakCorrect ?? 0,
      status: 'active',
      difficult: widget.cardToEdit?.difficult ?? false,
      createdAt: widget.cardToEdit?.createdAt ?? now,
    );

    await widget.store.saveCard(card: card);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.cardToEdit != null ? 'Kartochka yangilandi!' : 'Yangi kartochka qoʻshildi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Form(
          key: _formKey,
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
                          widget.cardToEdit != null ? 'Kartochkani tahrirlash' : 'Yangi kartochka',
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
                    // Segmented control (Savol - javob va Bo'sh joy)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EBE6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          _buildTypeTab(0, 'Savol - javob'),
                          _buildTypeTab(1, "Bo'sh joy"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Fan
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

                    // Savol
                    Text('Savol', style: AppTheme.sansLabel(fontSize: 12, color: AppTheme.grey)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: TextFormField(
                        controller: _questionController,
                        maxLines: 3,
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.ink, height: 1.4),
                        decoration: const InputDecoration(
                          hintText: "Nmap'da SYN skanerlash bayrog'i qaysi?",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Savol kiriting' : null,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Javob
                    Text('Javob', style: AppTheme.sansLabel(fontSize: 12, color: AppTheme.grey)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: TextFormField(
                        controller: _answerController,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                        decoration: const InputDecoration(
                          hintText: "-sS",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Javob kiriting' : null,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Izoh (ixtiyoriy)
                    Text('Izoh (ixtiyoriy)', style: AppTheme.sansLabel(fontSize: 12, color: AppTheme.grey)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: TextFormField(
                        controller: _hintController,
                        maxLines: 3,
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.ink, height: 1.4),
                        decoration: const InputDecoration(
                          hintText: "Yarim ochiq skanerlash, logga tushmaydi",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Ma'lumot kartasi (Soat ikonka va jadval)
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
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFFD97706)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Birinchi takrorlash ertaga, keyin 3, 7, 21 va 60 kundan so'ng.",
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
      ),
    );
  }

  Widget _buildTypeTab(int index, String label) {
    final isSelected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
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
}
