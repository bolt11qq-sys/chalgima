import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../store/app_store.dart';

class NazarScreen extends StatefulWidget {
  final AppStore store;

  const NazarScreen({super.key, required this.store});

  @override
  State<NazarScreen> createState() => _NazarScreenState();
}

class _NazarScreenState extends State<NazarScreen> {
  int _selectedPromiseStatus = 0; // 0: Ushladim, 1: Ongli buzdim, 2: Ushlamadim
  final TextEditingController _goodHabitController = TextEditingController(
    text: "Kechqurun telefonni olmay, 40 daqiqa kitob o'qidim.",
  );
  final TextEditingController _nextHabitController = TextEditingController(
    text: "Ertalab birinchi 20 daqiqada telefonga qaramayman.",
  );
  bool _showExtraQuestions = false;

  @override
  void dispose() {
    _goodHabitController.dispose();
    _nextHabitController.dispose();
    super.dispose();
  }

  String _formatTodayHeader() {
    final now = DateTime.now();
    final months = [
      'yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun',
      'iyul', 'avgust', 'sentabr', 'oktabr', 'noyabr', 'dekabr'
    ];
    return '${now.day}-${months[now.month - 1].toUpperCase()}, KECHQURUN';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: AppTheme.squareIconDecoration,
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.ink),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _formatTodayHeader(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: AppTheme.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44), // Balancer
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // 1. Kichik va'da kartasi
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "KICHIK VA'DA",
                          style: AppTheme.sansLabel(fontSize: 11, color: AppTheme.grey),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Har kuni 23:00da telefonni yotoqxonadan tashqarida zaryadga qo'yaman.",
                          style: GoogleFonts.newsreader(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.ink,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Text(
                              "12",
                              style: GoogleFonts.newsreader(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accent,
                              ),
                            ),
                            Text(
                              " kun · eng uzun 21 · ushlangan 86%",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppTheme.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // 3 ta holat tugmasi
                        Row(
                          children: [
                            Expanded(
                              child: _buildPromiseChoice(
                                index: 0,
                                title: "Ushladim",
                                subtitle: "bajardim",
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildPromiseChoice(
                                index: 1,
                                title: "Ongli buzdim",
                                subtitle: "halol tan oldim",
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildPromiseChoice(
                                index: 2,
                                title: "Ushlamadim",
                                subtitle: "bo'lmadi",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Bugun qayerda to'g'ri harakat qildim?
                  Text(
                    "Bugun qayerda to'g'ri harakat qildim?",
                    style: GoogleFonts.newsreader(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildQuestionBox(
                    controller: _goodHabitController,
                    hint: "Kechqurun telefonni olmay, 40 daqiqa kitob o'qidim...",
                  ),
                  const SizedBox(height: 24),

                  // 3. Ertaga nimani boshqacha qilaman?
                  Text(
                    "Ertaga nimani boshqacha qilaman?",
                    style: GoogleFonts.newsreader(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildQuestionBox(
                    controller: _nextHabitController,
                    hint: "Ertalab birinchi 20 daqiqada telefonga qaramayman...",
                  ),
                  const SizedBox(height: 20),

                  // 4. Qo'shimcha savollar tugmasi
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showExtraQuestions = !_showExtraQuestions;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F5F0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.cardBorder,
                          style: BorderStyle.solid,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showExtraQuestions ? Icons.remove : Icons.add,
                            size: 18,
                            color: AppTheme.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Yana ikki savol (kuzatuv va sabab)",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_showExtraQuestions) ...[
                    const SizedBox(height: 18),
                    Text(
                      "Bugun eng ko'p nima chalg'itdi?",
                      style: GoogleFonts.newsreader(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.ink),
                    ),
                    const SizedBox(height: 8),
                    _buildQuestionBox(
                      controller: TextEditingController(),
                      hint: "Sabab yoki kuzatuvni yozing...",
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Kecha o'zingizga yozgansiz: ...
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Kecha o'zingizga yozgansiz: ertalab birinchi 20 daqiqada telefonga qaramayman.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.newsreader(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.grey,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Saqlash tugmasi
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Kunlik nazar qaydlari saqlandi! Baraka toping.")),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        "Yakunlash va saqlash",
                        style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromiseChoice({
    required int index,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedPromiseStatus == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPromiseStatus = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent : const Color(0xFFFAF8F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.cardBorder,
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: isSelected ? Colors.white.withOpacity(0.85) : AppTheme.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionBox({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          TextField(
            controller: controller,
            maxLines: 3,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.ink, height: 1.4),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(left: 16, right: 44, top: 16, bottom: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(Icons.mic_none_outlined, size: 20, color: AppTheme.grey.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}
