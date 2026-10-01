import 'package:flutter/material.dart';
import '../theme.dart';
import '../store/app_store.dart';
import '../widgets/empty_state.dart';
import 'card_edit.dart';
import 'review.dart';

class CardsScreen extends StatefulWidget {
  final AppStore store;

  const CardsScreen({super.key, required this.store});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  String _filter = 'all'; // all, new, learning, mastered, difficult
  int? _subjectFilter;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allCards = widget.store.cards;
    final totalCards = allCards.length;
    final masteredCards = allCards.where((c) => c.stage >= 5).length;
    final difficultCards = allCards.where((c) => c.difficult).length;

    final filtered = allCards.where((c) {
      if (_subjectFilter != null && c.subjectId != _subjectFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = c.question.toLowerCase().contains(q) || c.answer.toLowerCase().contains(q);
        if (!match) return false;
      }
      switch (_filter) {
        case 'new':
          return c.stage == 0;
        case 'learning':
          return c.stage > 0 && c.stage < 5;
        case 'mastered':
          return c.stage >= 5;
        case 'difficult':
          return c.difficult;
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kartochkalar kutubxonasi'),
        actions: [
          if (difficultCards > 0)
            IconButton(
              icon: const Icon(Icons.fitness_center, color: AppTheme.red),
              tooltip: 'Qiyin kartochkalar mashqi',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewScreen(store: widget.store, difficultOnly: true),
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CardEditScreen(store: widget.store),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Kartochka qoʻshish'),
      ),
      body: Column(
        children: [
          // 3 ta ko'rsatkich (Section 6 Screen 10)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricTile('Jami', '$totalCards', AppTheme.ink),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile('Oʻzlashtirilgan', '$masteredCards', AppTheme.accent),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile('Qiyin', '$difficultCards', AppTheme.red),
                ),
              ],
            ),
          ),

          // Qidiruv
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Kartochkalardan qidirish...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
          ),
          const SizedBox(height: 8),

          // Filtr chiplari
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildFilterChip('Barchasi', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Yangi', 'new'),
                const SizedBox(width: 8),
                _buildFilterChip('Oʻrganilmoqda', 'learning'),
                const SizedBox(width: 8),
                _buildFilterChip('Oʻzlashtirilgan', 'mastered'),
                const SizedBox(width: 8),
                _buildFilterChip('Qiyin', 'difficult'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Kartochkalar ro'yxati
          Expanded(
            child: filtered.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.style_outlined,
                    title: 'Kartochkalar topilmadi',
                    subtitle: 'Yangi kartochka yoki vaziyat qoʻshib oʻrganishni boshlang.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final card = filtered[index];
                      final subject = widget.store.subjects.where((s) => s.id == card.subjectId).firstOrNull;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (subject != null) ...[
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: _parseColor(subject.color),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    subject.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.grey),
                                  ),
                                ],
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: card.type == 'scenario' ? AppTheme.amber.withOpacity(0.12) : AppTheme.ink.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    card.type == 'scenario' ? 'Vaziyat' : 'QA',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: card.type == 'scenario' ? AppTheme.amber : AppTheme.ink,
                                    ),
                                  ),
                                ),
                                if (card.difficult) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.red.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('Qiyin', style: TextStyle(color: AppTheme.red, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CardEditScreen(store: widget.store, cardToEdit: card),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              card.question,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              card.answer,
                              style: TextStyle(color: Colors.grey[700], fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Bosqich nuqtalari (0-5)
                                Row(
                                  children: List.generate(6, (i) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 3),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: i <= card.stage ? AppTheme.accent : AppTheme.line,
                                      ),
                                    );
                                  }),
                                ),
                                Text(
                                  'Keyingi: ${card.nextDue}',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.grey, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.grey)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.accent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.ink,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) => setState(() => _filter = value),
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
