import 'package:flutter/material.dart';
import '../theme.dart';
import '../store/app_store.dart';
import '../widgets/session_row.dart';
import '../widgets/empty_state.dart';
import 'session_edit.dart';

class HistoryScreen extends StatefulWidget {
  final AppStore store;

  const HistoryScreen({super.key, required this.store});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int? _selectedSubjectFilter;

  @override
  Widget build(BuildContext context) {
    final filteredSessions = widget.store.sessions.where((s) {
      if (_selectedSubjectFilter != null) {
        return s.subjectId == _selectedSubjectFilter;
      }
      return true;
    }).toList();

    // Sessiyalarni kunlar (dayKey) bo'yicha guruhlash
    final Map<String, List<dynamic>> grouped = {};
    for (final s in filteredSessions) {
      grouped.putIfAbsent(s.dayKey, () => []).add(s);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oʻqish tarixi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Qoʻlda sessiya kiritish',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SessionEditScreen(store: widget.store)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Fan filtri chiplari
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Barchasi'),
                    selected: _selectedSubjectFilter == null,
                    selectedColor: AppTheme.ink,
                    labelStyle: TextStyle(
                      color: _selectedSubjectFilter == null ? Colors.white : AppTheme.ink,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => setState(() => _selectedSubjectFilter = null),
                  ),
                ),
                ...widget.store.subjects.map((subj) {
                  final isSelected = _selectedSubjectFilter == subj.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(subj.name),
                      selected: isSelected,
                      selectedColor: AppTheme.accent,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.ink,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedSubjectFilter = isSelected ? null : subj.id;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: filteredSessions.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.history,
                    title: 'Hozircha sessiyalar yoʻq',
                    subtitle: 'Oʻqish taymerini ishga tushiring yoki qoʻlda yangi sessiya kiriting.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: sortedKeys.length,
                    itemBuilder: (context, index) {
                      final dayKey = sortedKeys[index];
                      final daySessions = grouped[dayKey]!;

                      // Kunlik jami daqiqalar
                      int dayTotalSec = 0;
                      for (final s in daySessions) {
                        dayTotalSec += (s.netSeconds as int);
                      }
                      final dayMins = dayTotalSec ~/ 60;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 14, bottom: 6, left: 4, right: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dayKey,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.grey),
                                ),
                                Text(
                                  'Jami: $dayMins daqiqa',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.ink),
                                ),
                              ],
                            ),
                          ),
                          ...daySessions.map((sess) {
                            final subj = widget.store.subjects.where((s) => s.id == sess.subjectId).firstOrNull;
                            return SessionRowWidget(session: sess, subject: subj);
                          }),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
