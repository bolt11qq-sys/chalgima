import 'package:flutter/material.dart';
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
  int _durationMinutes = 45;
  int _rating = 4;
  String _kind = 'read';
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _intentionController = TextEditingController();

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
    _intentionController.dispose();
    super.dispose();
  }

  void _save() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final netSeconds = _durationMinutes * 60;
    final dayKey = SrsScheduler.getDayKey();

    final baseData = {
      'subject_id': _subjectId,
      'start_at': now - (netSeconds * 1000),
      'end_at': now,
      'net_seconds': netSeconds,
      'pause_seconds': 0,
      'distraction_count': 0,
      'mode': 'manual',
      'day_key': dayKey,
      'confirmed': 1,
      'intention': _intentionController.text.trim().isNotEmpty ? _intentionController.text.trim() : null,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qoʻlda sessiya kiritish'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Fan tanlash
          const Text('Fan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
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

          // Davomiylik tezkor tugmalari (Section 6 Screen 9)
          const Text('Davomiylik', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [15, 30, 45, 60, 90, 120].map((m) {
              final isSelected = _durationMinutes == m;
              return ChoiceChip(
                label: Text('$m daq'),
                selected: isSelected,
                selectedColor: AppTheme.accent,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.ink,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) => setState(() => _durationMinutes = m),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Faoliyat turi
          const Text('Faoliyat turi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
          const SizedBox(height: 20),

          // Diqqat bahosi
          const Text('Diqqat bahosi (1-5)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 1; i <= 5; i++)
                GestureDetector(
                  onTap: () => setState(() => _rating = i),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _rating == i ? AppTheme.accent.withOpacity(0.15) : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: _rating == i ? AppTheme.accent : AppTheme.line, width: 2),
                    ),
                    child: Text(
                      ['😫', '😕', '😐', '🙂', '🔥'][i - 1],
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _intentionController,
            decoration: InputDecoration(
              labelText: 'Niyat (maqsad)',
              hintText: 'Ushbu vaqtda nima qilindi?',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Xulosa / Izoh',
              hintText: 'Natijalar haqida qisqacha...',
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
}
