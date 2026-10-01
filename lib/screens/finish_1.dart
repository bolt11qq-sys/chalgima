import 'package:flutter/material.dart';
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
  int? _intentionDone; // 1 = Ha, 2 = Qisman, 0 = Yo'q
  bool _isShortSession = false;

  @override
  void initState() {
    super.initState();
    _netSeconds = widget.sessionData['net_seconds'] ?? 0;
    _isShortSession = _netSeconds < 300; // 5 daqiqadan kam
  }

  void _adjustMinutes(int deltaMin) {
    setState(() {
      _netSeconds = (_netSeconds + (deltaMin * 60)).clamp(60, 86400);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mins = _netSeconds ~/ 60;
    final subject = widget.store.subjects.where((s) => s.id == widget.sessionData['subject_id']).firstOrNull;
    final intention = widget.sessionData['intention'] as String?;
    final isForgotten = (widget.sessionData['confirmed'] ?? 1) == 0 || _netSeconds >= 14400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('1/3: Vaqtni tasdiqlash'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject?.name ?? "O'quv sessiyasi",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isForgotten
                  ? '⚠️ Taymer uzoq vaqt ishladi. Haqiqiy vaqtni tanlang:'
                  : 'Sessiya vaqti toʻgʻrimi? Kerak boʻlsa tuzatishingiz mumkin.',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Katta vaqt ko'rinishi va -5 / +5 tugmalari
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.line),
                ),
                child: Column(
                  children: [
                    Text(
                      '$mins',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.ink,
                      ),
                    ),
                    const Text('daqiqa', style: TextStyle(fontSize: 16, color: AppTheme.grey)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () => _adjustMinutes(-5),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: const Text('−5 daq', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: () => _adjustMinutes(5),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: const Text('+5 daq', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (isForgotten) ...[
              const SizedBox(height: 16),
              const Text('Tezkor tanlovlar:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [30, 45, 60, 90, 120].map((m) {
                  return ActionChip(
                    label: Text('$m daq'),
                    onPressed: () => setState(() => _netSeconds = m * 60),
                  );
                }).toList(),
              ),
            ],

            // 5.8 Niyat bo'lsa "Bajarildimi?" so'raladi
            if (intention != null && intention.isNotEmpty) ...[
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎯 Niyat: "$intention"',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text('Niyat bajarildimi?', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildChoiceChip('Ha', 1),
                        const SizedBox(width: 8),
                        _buildChoiceChip('Qisman', 2),
                        const SizedBox(width: 8),
                        _buildChoiceChip("Yo'q", 0),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),

            // Tugmalar: 5 daqiqadan kam bo'lsa faqat saqlash / bekor qilish
            if (_isShortSession) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Bekor qilish'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveDirectly,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Saqlash', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saveDirectly,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Darhol saqlash'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _goToStep2,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.ink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Tafsilot qoʻshish →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, int value) {
    final isSelected = _intentionDone == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.accent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.ink,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (_) => setState(() => _intentionDone = value),
    );
  }

  void _saveDirectly() async {
    final updatedData = Map<String, dynamic>.from(widget.sessionData);
    updatedData['net_seconds'] = _netSeconds;

    await widget.store.saveCompletedSession(
      baseData: updatedData,
      rating: null,
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

  void _goToStep2() {
    final updatedData = Map<String, dynamic>.from(widget.sessionData);
    updatedData['net_seconds'] = _netSeconds;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FinishStep2Screen(
          store: widget.store,
          sessionData: updatedData,
          intentionDone: _intentionDone,
        ),
      ),
    );
  }
}
