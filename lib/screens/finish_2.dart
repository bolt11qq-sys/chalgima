import 'package:flutter/material.dart';
import '../theme.dart';
import '../store/app_store.dart';
import 'finish_3.dart';

class FinishStep2Screen extends StatefulWidget {
  final AppStore store;
  final Map<String, dynamic> sessionData;
  final int? intentionDone;

  const FinishStep2Screen({
    super.key,
    required this.store,
    required this.sessionData,
    this.intentionDone,
  });

  @override
  State<FinishStep2Screen> createState() => _FinishStep2ScreenState();
}

class _FinishStep2ScreenState extends State<FinishStep2Screen> {
  int _rating = 4; // 1-5
  String _kind = 'read';
  final TextEditingController _noteController = TextEditingController();

  final List<String> _quickPrefixes = [
    'Tugatdim: ',
    'Tushunmadim: ',
    'Keyingi safar: ',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _addPrefix(String prefix) {
    setState(() {
      if (_noteController.text.isEmpty) {
        _noteController.text = prefix;
      } else {
        _noteController.text += '\n$prefix';
      }
      _noteController.selection = TextSelection.fromPosition(
        TextPosition(offset: _noteController.text.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2/3: Diqqat va xulosa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Diqqat bahosi (5 ta smaylik)
            const Text(
              'Diqqatingiz qanday boʻldi?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int i = 1; i <= 5; i++)
                  GestureDetector(
                    onTap: () => setState(() => _rating = i),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _rating == i ? AppTheme.accent.withOpacity(0.15) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _rating == i ? AppTheme.accent : AppTheme.line,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        ['😫', '😕', '😐', '🙂', '🔥'][i - 1],
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),

            // 2. Faoliyat turi (kind)
            const Text(
              'Faoliyat turi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                _buildKindChip('Oʻqish/Nazariya', 'read'),
                _buildKindChip('Amaliyot', 'practice'),
                _buildKindChip('Loyiha', 'project'),
                _buildKindChip('Takrorlash', 'review'),
              ],
            ),
            const SizedBox(height: 28),

            // 3. Nima o'rgandingiz?
            const Text(
              'Nima oʻrgandingiz? (Xulosa)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Tayyor boshlanish chiplari
            Wrap(
              spacing: 8,
              children: _quickPrefixes.map((prefix) {
                return ActionChip(
                  label: Text(prefix.replaceAll(': ', '')),
                  backgroundColor: AppTheme.ink.withOpacity(0.06),
                  onPressed: () => _addPrefix(prefix),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Qisqa xulosalar, muhim gʻoyalar yoki savollar...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.line),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Tugmalar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saveDirectly,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Saqlash'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _goToStep3,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.ink,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Kartochkalar →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKindChip(String label, String value) {
    final isSelected = _kind == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.accent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.ink,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (_) => setState(() => _kind = value),
    );
  }

  void _saveDirectly() async {
    await widget.store.saveCompletedSession(
      baseData: widget.sessionData,
      rating: _rating,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      kind: _kind,
      intentionDone: widget.intentionDone,
      quickCardsText: [],
    );

    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessiya muvaffaqiyatli saqlandi!')),
      );
    }
  }

  void _goToStep3() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FinishStep3Screen(
          store: widget.store,
          sessionData: widget.sessionData,
          rating: _rating,
          kind: _kind,
          note: _noteController.text.trim(),
          intentionDone: widget.intentionDone,
        ),
      ),
    );
  }
}
