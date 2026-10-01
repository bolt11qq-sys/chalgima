import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../store/app_store.dart';
import 'subject_edit.dart';

class SubjectsScreen extends StatelessWidget {
  final AppStore store;

  const SubjectsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final active = store.subjects.where((s) => s.status == 'active').toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // 1. Yuqori sarlavha (Fanlar va + tugmasi)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fanlar',
                    style: GoogleFonts.newsreader(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.ink,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SubjectEditScreen(store: store)),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: AppTheme.squareIconDecoration,
                      child: const Icon(Icons.add, color: AppTheme.ink, size: 24),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Xulosa kartasi (Jami o'qilgan vaqt 81 soat | Kartochka 142)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.cardDecoration,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.mintBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.layers_outlined, color: AppTheme.accent, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Jami o'qilgan vaqt",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '81 soat',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Kartochka',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '142',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.ink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 3. Faol fanlar sarlavhasi
            Text(
              'Faol fanlar',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 12),

            // Faol fanlar ro'yxati (Kiberxavfsizlik, Ingliz tili, Flutter)
            _buildSubjectCard(
              context: context,
              icon: Icons.shield_outlined,
              iconBg: AppTheme.blueBg,
              iconColor: const Color(0xFF3E5FCC),
              name: 'Kiberxavfsizlik',
              hours: '47',
              currentGoalHours: '8,5',
              totalGoalHours: '10',
              progress: 0.85,
              onTap: () {
                final s = active.firstWhere((item) => item.name.contains('Kiber'), orElse: () => active.first);
                Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectEditScreen(store: store, subjectToEdit: s)));
              },
            ),
            const SizedBox(height: 12),

            _buildSubjectCard(
              context: context,
              icon: Icons.language_outlined,
              iconBg: AppTheme.mintBg,
              iconColor: AppTheme.accent,
              name: 'Ingliz tili',
              hours: '23',
              currentGoalHours: '4,0',
              totalGoalHours: '7',
              progress: 0.57,
              onTap: () {
                final s = active.firstWhere((item) => item.name.contains('Ingliz'), orElse: () => active.first);
                Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectEditScreen(store: store, subjectToEdit: s)));
              },
            ),
            const SizedBox(height: 12),

            _buildSubjectCard(
              context: context,
              icon: Icons.code_rounded,
              iconBg: const Color(0xFFFDF0E2),
              iconColor: const Color(0xFFB4690E),
              name: 'Flutter',
              hours: '11',
              currentGoalHours: '1,8',
              totalGoalHours: '3',
              progress: 0.60,
              onTap: () {
                final s = active.firstWhere((item) => item.name.contains('Backend') || item.name.contains('Flutter'), orElse: () => active.first);
                Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectEditScreen(store: store, subjectToEdit: s)));
              },
            ),
            const SizedBox(height: 14),

            // 4. + Yangi fan qo'shish tugmasi
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SubjectEditScreen(store: store)),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5F0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder, width: 1.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, size: 18, color: AppTheme.ink),
                    const SizedBox(width: 8),
                    Text(
                      "Yangi fan qo'shish",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 5. Arxiv bo'limi
            Text(
              'Arxiv',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: AppTheme.cardDecoration,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEEF0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book_outlined, color: AppTheme.grey, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Matematika',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Jami 6 soat · to'xtatilgan",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.grey),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String name,
    required String hours,
    required String currentGoalHours,
    required String totalGoalHours,
    required double progress,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.cardDecoration,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Jami $hours soat',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.grey),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFEAECE7),
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Haftalik maqsad',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.grey,
                  ),
                ),
                Text(
                  '$currentGoalHours / $totalGoalHours soat',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.ink,
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
