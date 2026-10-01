import 'package:flutter/material.dart';
import '../theme.dart';
import '../store/app_store.dart';
import '../models/subject.dart';
import 'subject_edit.dart';

class SubjectsScreen extends StatelessWidget {
  final AppStore store;

  const SubjectsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final active = store.subjects.where((s) => s.status == 'active').toList();
    final archived = store.subjects.where((s) => s.status == 'archived').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fanlar va Yoʻnalishlar'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.ink,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SubjectEditScreen(store: store),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Fan qoʻshish'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Faol fanlar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...active.map((s) => _buildSubjectCard(context, s)),

          if (archived.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Arxivlangan fanlar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.grey),
            ),
            const SizedBox(height: 12),
            ...archived.map((s) => _buildSubjectCard(context, s)),
          ],
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, Subject subject) {
    final cardCount = store.cards.where((c) => c.subjectId == subject.id).length;
    final hours = (subject.totalSeconds / 3600).toStringAsFixed(1);
    final color = _parseColor(subject.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  subject.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubjectEditScreen(store: store, subjectToEdit: subject),
                    ),
                  );
                },
              ),
            ],
          ),
          if (subject.note != null && subject.note!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subject.note!,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jami: $hours soat • $cardCount ta kartochka',
                style: const TextStyle(fontSize: 13, color: AppTheme.grey, fontWeight: FontWeight.w600),
              ),
              Text(
                'Maqsad: ${subject.dailyGoalMin} daq/kun',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accent),
              ),
            ],
          ),
        ],
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
