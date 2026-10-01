import 'package:flutter/material.dart';
import '../theme.dart';
import '../store/app_store.dart';
import '../models/card.dart';
import '../widgets/empty_state.dart';
import 'card_edit.dart';

class ReviewScreen extends StatefulWidget {
  final AppStore store;
  final bool difficultOnly;

  const ReviewScreen({
    super.key,
    required this.store,
    this.difficultOnly = false,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<FlashCard> _queue = [];
  int _currentIndex = 0;
  bool _isAnswerRevealed = false;
  int? _selectedOptionId;
  int _rememberedCount = 0;
  int _forgotCount = 0;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  void _loadQueue() {
    if (widget.difficultOnly) {
      _queue = widget.store.getDifficultCards();
    } else {
      _queue = widget.store.getTodayQueue();
    }
    _currentIndex = 0;
    _isAnswerRevealed = false;
    _selectedOptionId = null;
    _rememberedCount = 0;
    _forgotCount = 0;
  }

  void _onAnswer(bool remembered) async {
    if (_currentIndex >= _queue.length) return;
    final currentCard = _queue[_currentIndex];

    if (remembered) {
      _rememberedCount++;
    } else {
      _forgotCount++;
    }

    await widget.store.reviewCard(currentCard.id, remembered);

    setState(() {
      _currentIndex++;
      _isAnswerRevealed = false;
      _selectedOptionId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_queue.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Takrorlash')),
        body: EmptyStateWidget(
          icon: Icons.check_circle_outline,
          title: widget.difficultOnly
              ? "Qiyin kartochkalar yo'q! 🎉"
              : "Bugungi takrorlash yakunlandi! 🌟",
          subtitle: widget.difficultOnly
              ? "Sizda qiyin deb belgilangan kartochkalar mavjud emas."
              : "Kunlik barcha kartochkalar takrorlandi. Ertaga yangi navbat boʻladi.",
          actionLabel: 'Kartochkalar roʻyxati',
          onAction: () => Navigator.pop(context),
        ),
      );
    }

    if (_currentIndex >= _queue.length) {
      // Barcha kartochkalar tugadi
      final total = _rememberedCount + _forgotCount;
      final percent = total > 0 ? ((_rememberedCount / total) * 100).toInt() : 0;

      return Scaffold(
        appBar: AppBar(title: const Text('Natija')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_events_outlined, size: 64, color: AppTheme.accent),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bugungi mashq yakunlandi!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Esda saqlash: $percent% ($total tadan $_rememberedCount tasi toʻgʻri)',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.ink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      _loadQueue();
                      setState(() {});
                    }
                  },
                  child: const Text('Bosh sahifaga qaytish', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final card = _queue[_currentIndex];
    final subject = widget.store.subjects.where((s) => s.id == card.subjectId).firstOrNull;
    final progress = (_currentIndex + 1) / _queue.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.difficultOnly ? 'Qiyin kartochkalar mashqi' : 'Takrorlash'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Kartochkani tahrirlash',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CardEditScreen(store: widget.store, cardToEdit: card),
                ),
              ).then((_) {
                _loadQueue();
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indikatori
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subject?.name ?? 'Fan',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.grey),
                      ),
                      Text(
                        '${_currentIndex + 1} / ${_queue.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppTheme.line,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            // Sifat ogohlantirishi (5.11 bo'lim: wrong_count >= 5)
            if (card.wrongCount >= 5) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.amber.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: AppTheme.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bu kartochka 5+ marta xato qilindi. Savolni soddalashtirib qayta yozish tavsiya etiladi.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: card.type == 'scenario'
                    ? _buildScenarioCard(card)
                    : _buildStandardCard(card),
              ),
            ),

            // Javob berish tugmalari ("Unutdim" / "Esladim")
            if (_isAnswerRevealed || card.type == 'scenario' && _selectedOptionId != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppTheme.line)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => _onAnswer(false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.red, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Unutdim (1 kun)',
                            style: TextStyle(color: AppTheme.red, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => _onAnswer(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Esladim 👍',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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

  // 1. Oddiy QA kartochka widgeti
  Widget _buildStandardCard(FlashCard card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Savol kartasi
        GestureDetector(
          onTap: () {
            if (!_isAnswerRevealed) {
              setState(() => _isAnswerRevealed = true);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.line),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.ink.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Bosqich: ${card.stage}/5',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.ink),
                      ),
                    ),
                    if (card.difficult) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.red.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Qiyin',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.red),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  card.question,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
                ),
                if (card.hint != null && card.hint!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    '💡 Maslahat: ${card.hint}',
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 24),
                if (!_isAnswerRevealed)
                  Center(
                    child: Text(
                      'Javobni koʻrish uchun bosing',
                      style: TextStyle(fontSize: 13, color: AppTheme.grey.withOpacity(0.8), fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Ochilgan javob
        if (_isAnswerRevealed) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Toʻgʻri javob:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  card.answer,
                  style: const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // 2. Vaziyat (Scenario) kartochkasi widgeti (5.6 bo'lim)
  Widget _buildScenarioCard(FlashCard card) {
    final options = card.options ?? [];
    final selectedOption = options.where((o) => o.id == _selectedOptionId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Kontekst / Vaziyat
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Vaziyat (Qaror qabul qilish)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.amber),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                card.question,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Qaroringizni tanlang:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),

        // Variantlar tugmalari
        ...options.map((opt) {
          final isSelected = _selectedOptionId == opt.id;
          final showResult = _selectedOptionId != null;

          Color borderColor = AppTheme.line;
          Color bgColor = Colors.white;

          if (showResult) {
            if (opt.isCorrect) {
              borderColor = AppTheme.accent;
              if (isSelected) bgColor = AppTheme.accent.withOpacity(0.1);
            } else if (isSelected) {
              borderColor = AppTheme.red;
              bgColor = AppTheme.red.withOpacity(0.08);
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (_selectedOptionId == null) {
                  setState(() => _selectedOptionId = opt.id);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? (opt.isCorrect ? Icons.check_circle : Icons.cancel)
                          : Icons.radio_button_unchecked,
                      color: showResult
                          ? (opt.isCorrect ? AppTheme.accent : (isSelected ? AppTheme.red : AppTheme.grey))
                          : AppTheme.grey,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opt.text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        // 5.6 Tanlangach, tanlangan variantning izohi (feedback) va xulosa chiqadi
        if (selectedOption != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: selectedOption.isCorrect
                  ? AppTheme.accent.withOpacity(0.08)
                  : AppTheme.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selectedOption.isCorrect ? AppTheme.accent : AppTheme.red,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      selectedOption.isCorrect ? Icons.check_circle : Icons.warning_amber_rounded,
                      color: selectedOption.isCorrect ? AppTheme.accent : AppTheme.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      selectedOption.isCorrect ? 'Toʻgʻri qaror!' : 'Qaror tahlili:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selectedOption.isCorrect ? AppTheme.accent : AppTheme.red,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  selectedOption.feedback,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const Divider(height: 20),
                Text(
                  'Asosiy sabab: ${card.answer}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.ink),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
