import 'package:flutter/material.dart';
import '../theme.dart';
import '../store/app_store.dart';
import '../models/path.dart';

class PathsScreen extends StatelessWidget {
  final AppStore store;

  const PathsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oʻquv yoʻllari (Roadmap)'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: store.paths.map((p) => _buildPathCard(context, p)).toList(),
      ),
    );
  }

  Widget _buildPathCard(BuildContext context, LearningPath path) {
    final totalItems = path.items.length;
    final doneItems = path.items.where((i) => i.status == 'done').length;
    final progress = totalItems > 0 ? (doneItems / totalItems) : 0.0;
    final subject = store.subjects.where((s) => s.id == path.subjectId).firstOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  path.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (subject != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    subject.name,
                    style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
            ],
          ),
          if (path.note != null && path.note!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(path.note!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
          const SizedBox(height: 14),

          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress: $doneItems / $totalItems mavzu', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppTheme.line,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 18),

          const Text('Rejadagi mavzular:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),

          ...path.items.map((item) {
            final isDone = item.status == 'done';
            final isDoing = item.status == 'doing';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDone ? Colors.grey[50] : (isDoing ? AppTheme.accent.withOpacity(0.05) : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDoing ? AppTheme.accent.withOpacity(0.4) : AppTheme.line,
                ),
              ),
              child: CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                value: isDone,
                activeColor: AppTheme.accent,
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isDoing ? FontWeight.bold : FontWeight.normal,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? AppTheme.grey : AppTheme.ink,
                  ),
                ),
                subtitle: item.note != null ? Text(item.note!, style: const TextStyle(fontSize: 12)) : null,
                onChanged: (val) {
                  store.togglePathItem(item.id, val == true ? 'done' : 'todo');
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
