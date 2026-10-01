import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../models/subject.dart';
import '../theme.dart';

class SessionRowWidget extends StatelessWidget {
  final StudySession session;
  final Subject? subject;

  const SessionRowWidget({
    super.key,
    required this.session,
    this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final startTime = DateTime.fromMillisecondsSinceEpoch(session.startAt);
    final timeStr = DateFormat('HH:mm').format(startTime);
    final mins = session.netSeconds ~/ 60;
    final color = _parseColor(subject?.color);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subject?.name ?? "Noma'lum fan",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                timeStr,
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Vaqt belgisi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: AppTheme.accent),
                    const SizedBox(width: 4),
                    Text(
                      '$mins daq',
                      style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Diqqat ko'rsatkichi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.ink.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.psychology_outlined, size: 14, color: AppTheme.ink),
                    const SizedBox(width: 4),
                    Text(
                      'Diqqat: ${session.focusScore}',
                      style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (session.cardsCreated > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.amber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.style_outlined, size: 13, color: AppTheme.amber),
                      const SizedBox(width: 4),
                      Text(
                        '+${session.cardsCreated}',
                        style: const TextStyle(color: AppTheme.amber, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (session.intention != null && session.intention!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '🎯 Niyat: ${session.intention}',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
          if (session.note != null && session.note!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '📝 ${session.note}',
              style: const TextStyle(fontSize: 13),
            ),
          ],
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
