import 'package:flutter/material.dart';
import '../theme.dart';
import '../store/app_store.dart';

class FinishStep3Screen extends StatefulWidget {
  final AppStore store;
  final Map<String, dynamic> sessionData;
  final int rating;
  final String kind;
  final String note;
  final int? intentionDone;

  const FinishStep3Screen({
    super.key,
    required this.store,
    required this.sessionData,
    required this.rating,
    required this.kind,
    required this.note,
    this.intentionDone,
  });

  @override
  State<FinishStep3Screen> createState() => _FinishStep3ScreenState();
}

class _FinishStep3ScreenState extends State<FinishStep3Screen> {
  final TextEditingController _cardsController = TextEditingController();

  @override
  void dispose() {
    _cardsController.dispose();
    super.dispose();
  }

  void _save(bool includeCards) async {
    final text = _cardsController.text.trim();
    final lines = includeCards && text.isNotEmpty
        ? text.split('\n').where((l) => l.contains('::')).toList()
        : <String>[];

    await widget.store.saveCompletedSession(
      baseData: widget.sessionData,
      rating: widget.rating,
      note: widget.note.isNotEmpty ? widget.note : null,
      kind: widget.kind,
      intentionDone: widget.intentionDone,
      quickCardsText: lines,
    );

    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lines.isNotEmpty
                ? 'Sessiya va ${lines.length} ta kartochka saqlandi! 🎉'
                : 'Sessiya saqlandi! Baraka toping.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3/3: Kartochkalar qoʻshish'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tezkor kartochkalar yaratish',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Oʻqiganlaringiz hali yoddaligida 2-3 ta muhim savol-javob yozib qoldiring. Har bir qator alohida kartochka boʻladi.',
              style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),

            // Format namunalari
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.amber.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.amber, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Format: Savol :: Javob\nMisol: Nmap SYN bayrogʻi :: -sS',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.ink),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _cardsController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: '1-savol :: javob\n2-savol :: javob\n3-savol :: javob...',
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
            const SizedBox(height: 36),

            // Tugmalar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _save(false), // Keyinroq
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Keyinroq'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _save(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Yakunlash', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
