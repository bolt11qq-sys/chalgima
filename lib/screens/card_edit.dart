import 'package:flutter/material.dart';
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
  late String _type; // 'qa' or 'scenario'
  late int _subjectId;
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late TextEditingController _hintController;

  // Scenario options (3 ta boshlang'ich variant)
  List<Map<String, dynamic>> _scenarioOptions = [];

  @override
  void initState() {
    super.initState();
    final c = widget.cardToEdit;
    _type = c?.type ?? 'qa';
    _subjectId = c?.subjectId ?? (widget.store.subjects.isNotEmpty ? widget.store.subjects.first.id : 1);
    _questionController = TextEditingController(text: c?.question ?? '');
    _answerController = TextEditingController(text: c?.answer ?? '');
    _hintController = TextEditingController(text: c?.hint ?? '');

    if (c != null && c.options != null && c.options!.isNotEmpty) {
      _scenarioOptions = c.options!.map((o) {
        return {
          'text': TextEditingController(text: o.text),
          'is_correct': o.isCorrect,
          'feedback': TextEditingController(text: o.feedback),
        };
      }).toList();
    } else {
      _scenarioOptions = [
        {'text': TextEditingController(), 'is_correct': false, 'feedback': TextEditingController()},
        {'text': TextEditingController(), 'is_correct': true, 'feedback': TextEditingController()},
        {'text': TextEditingController(), 'is_correct': false, 'feedback': TextEditingController()},
      ];
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _hintController.dispose();
    for (final opt in _scenarioOptions) {
      (opt['text'] as TextEditingController).dispose();
      (opt['feedback'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final today = SrsScheduler.getDayKey();
    final now = DateTime.now().millisecondsSinceEpoch;

    List<Map<String, dynamic>>? optionsToSave;
    if (_type == 'scenario') {
      optionsToSave = _scenarioOptions.map((opt) {
        return {
          'text': (opt['text'] as TextEditingController).text.trim(),
          'is_correct': opt['is_correct'] as bool,
          'feedback': (opt['feedback'] as TextEditingController).text.trim(),
        };
      }).toList();
    }

    final card = FlashCard(
      id: widget.cardToEdit?.id ?? 0,
      subjectId: _subjectId,
      sessionId: widget.cardToEdit?.sessionId,
      type: _type,
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
      status: widget.cardToEdit?.status ?? 'active',
      difficult: widget.cardToEdit?.difficult ?? false,
      createdAt: widget.cardToEdit?.createdAt ?? now,
    );

    await widget.store.saveCard(card: card, scenarioOptions: optionsToSave);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.cardToEdit != null ? 'Kartochka yangilandi!' : 'Yangi kartochka yaratildi!')),
      );
    }
  }

  void _delete() async {
    if (widget.cardToEdit == null) return;
    await widget.store.deleteCard(widget.cardToEdit!.id);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kartochka oʻchirildi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cardToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Kartochkani tahrirlash' : 'Yangi kartochka'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Oʻchirilsinmi?'),
                    content: const Text('Bu kartochkani qaytarib boʻlmaydi.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Yoʻq')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _delete();
                        },
                        child: const Text('Oʻchirish', style: TextStyle(color: AppTheme.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Tur tanlash (QA / Scenario)
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'qa', label: Text('Oddiy (QA)')),
                ButtonSegment(value: 'scenario', label: Text('Vaziyat (Scenario)')),
              ],
              selected: {_type},
              onSelectionChanged: (set) => setState(() => _type = set.first),
            ),
            const SizedBox(height: 20),

            // Fan tanlash
            const Text('Fan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.line),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _subjectId,
                  isExpanded: true,
                  items: widget.store.subjects.where((s) => s.status == 'active').map((s) {
                    return DropdownMenuItem<int>(
                      value: s.id,
                      child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _subjectId = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Savol / Kontekst
            TextFormField(
              controller: _questionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: _type == 'scenario' ? 'Vaziyat konteksti (Savol)' : 'Savol',
                hintText: _type == 'scenario'
                    ? 'Masalan: Pentestda 12 ta zaiflik topdingiz, 2 soat qoldi...'
                    : 'Masalan: SYN skanerlash bayrogʻi qaysi?',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Savol boʻsh boʻlishi mumkin emas' : null,
            ),
            const SizedBox(height: 16),

            // 5.11 Sifat: bitta kartochka — bitta fakt ogohlantirishi
            if (_type == 'qa') ...[
              TextFormField(
                controller: _answerController,
                maxLines: 3,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Javob',
                  hintText: 'Qisqa va aniq fakt...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Javob boʻsh boʻlishi mumkin emas' : null,
              ),
              if (_answerController.text.length > 100) ...[
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppTheme.amber),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Ogohlantirish: Javob 100 belgidan uzun. "Bitta kartochka — bitta fakt" qoidasiga amal qiling.',
                        style: TextStyle(fontSize: 12, color: AppTheme.amber, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ] else ...[
              // Vaziyat uchun umumiy sabab / to'g'ri xulosa
              TextFormField(
                controller: _answerController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Toʻgʻri qaror sababi (Qisqacha)',
                  hintText: 'Nima uchun bu qaror toʻgʻri va eng samarali?',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Sabab kiritilishi kerak' : null,
              ),
              const SizedBox(height: 20),

              // Scenario variantlari (5.6 bo'lim talabi)
              const Text('Variantlar va ularning izohi (Feedback):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),

              ...List.generate(_scenarioOptions.length, (index) {
                final opt = _scenarioOptions[index];
                final textCtrl = opt['text'] as TextEditingController;
                final feedbackCtrl = opt['feedback'] as TextEditingController;
                final isCorrect = opt['is_correct'] as bool;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isCorrect ? AppTheme.accent.withOpacity(0.06) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isCorrect ? AppTheme.accent : AppTheme.line),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: isCorrect,
                            activeColor: AppTheme.accent,
                            onChanged: (_) {
                              setState(() {
                                for (final o in _scenarioOptions) {
                                  o['is_correct'] = false;
                                }
                                opt['is_correct'] = true;
                              });
                            },
                          ),
                          Text(
                            isCorrect ? 'Toʻgʻri variant' : '${index + 1}-variant',
                            style: TextStyle(fontWeight: FontWeight.bold, color: isCorrect ? AppTheme.accent : AppTheme.ink),
                          ),
                        ],
                      ),
                      TextField(
                        controller: textCtrl,
                        decoration: InputDecoration(
                          hintText: 'Variant matni...',
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: feedbackCtrl,
                        decoration: InputDecoration(
                          hintText: 'Izoh: nega toʻgʻri yoki nega xato qaror?',
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 16),

            // Maslahat
            TextFormField(
              controller: _hintController,
              decoration: InputDecoration(
                labelText: 'Maslahat (Hint - ixtiyoriy)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _save,
                child: const Text('Saqlash', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
