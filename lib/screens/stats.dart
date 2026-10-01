import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';
import '../store/app_store.dart';

class StatsScreen extends StatefulWidget {
  final AppStore store;

  const StatsScreen({super.key, required this.store});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _periodIndex = 0; // 0: Hafta, 1: Oy, 2: Yil
  String _selectedMonth = 'Sentabr';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // 1. Yuqori sarlavha qatori (Statistika va Sentabr ⌵)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Statistika',
                    style: GoogleFonts.newsreader(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.ink,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedMonth,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Segmented control (Hafta, Oy, Yil)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EBE6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildPeriodTab(0, 'Hafta'),
                  _buildPeriodTab(1, 'Oy'),
                  _buildPeriodTab(2, 'Yil'),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 3. 1-Karta: Kunlar bo'yicha (Bar chart)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Kunlar bo'yicha",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppTheme.ink,
                        ),
                      ),
                      Text(
                        'jami 14 s 20 daq',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppTheme.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 7 ta kun ustunlari
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildDayBar('Du', 46, const Color(0xFFCBD5E1)),
                      _buildDayBar('Se', 58, const Color(0xFFCBD5E1)),
                      _buildDayBar('Ch', 32, const Color(0xFFCBD5E1)),
                      _buildDayBar('Pa', 72, const Color(0xFFCBD5E1)),
                      _buildDayBar('Ju', 54, const Color(0xFFCBD5E1)),
                      _buildDayBar('Sh', 24, const Color(0xFFCBD5E1)),
                      _buildDayBar('Ya', 62, AppTheme.accent), // Yakshanba tanlangan yashil
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. 3 ta ko'rsatkich kartochkalari (Bir qatorda)
            Row(
              children: [
                Expanded(
                  child: _buildMetricBox(
                    label: "Kunlik o'rtacha",
                    val: '2 s 03 daq',
                    sub: "+18% o'tgan haftaga",
                    subColor: AppTheme.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricBox(
                    label: 'Eng uzun streak',
                    val: '21 kun',
                    sub: 'hozir 13',
                    subColor: AppTheme.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricBox(
                    label: 'Esda saqlash',
                    val: '84%',
                    sub: 'oxirgi 7 kun',
                    subColor: AppTheme.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 5. 2-Karta: Fanlar bo'yicha (Donut chart & ro'yxat)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Fanlar bo'yicha",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Donut chart markazda
                  Center(
                    child: SizedBox(
                      width: 170,
                      height: 170,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 55,
                              startDegreeOffset: -90,
                              sections: [
                                PieChartSectionData(
                                  color: const Color(0xFF3E5FCC),
                                  value: 58,
                                  title: '',
                                  radius: 26,
                                ),
                                PieChartSectionData(
                                  color: AppTheme.accent,
                                  value: 28,
                                  title: '',
                                  radius: 26,
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFFB4690E),
                                  value: 14,
                                  title: '',
                                  radius: 26,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Jami',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppTheme.grey,
                                ),
                              ),
                              Text(
                                '14:20',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.ink,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Legend
                  _buildSubjectLegend(
                    color: const Color(0xFF3E5FCC),
                    title: 'Kiberxavfsizlik',
                    duration: '8 s 20 daq',
                    percent: '58%',
                  ),
                  const Divider(color: AppTheme.line, height: 18),
                  _buildSubjectLegend(
                    color: AppTheme.accent,
                    title: 'Ingliz tili',
                    duration: '4 s 00 daq',
                    percent: '28%',
                  ),
                  const Divider(color: AppTheme.line, height: 18),
                  _buildSubjectLegend(
                    color: const Color(0xFFB4690E),
                    title: 'Flutter',
                    duration: '2 s 00 daq',
                    percent: '14%',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 6. Ogohlantirish / Maslahat kartasi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE2EBE6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Ertalabki sessiyalarda o'rtacha baho 4,3, kechqurun 3,1. Muhim mavzularni ertalabga qoldiring.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF283830),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 7. Ekran vaqti ruxsati kartasi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.phone_android_outlined, size: 24, color: AppTheme.grey),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          "Ekran vaqtini ko'rsatish uchun ruxsat kerak. Yoqsangiz, o'qish va boshqa ilovalar taqqoslanadi.",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppTheme.grey,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Ekran vaqti ruxsati so'raldi")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B263B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Ruxsat berish',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTab(int index, String title) {
    final isSelected = _periodIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _periodIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.ink : AppTheme.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayBar(String day, double height, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String val,
    required String sub,
    required Color subColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.grey),
          ),
          const SizedBox(height: 6),
          Text(
            val,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: subColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectLegend({
    required Color color,
    required String title,
    required String duration,
    required String percent,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.ink,
            ),
          ),
        ),
        Text(
          duration,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppTheme.grey,
          ),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 38,
          child: Text(
            percent,
            textAlign: TextAlign.right,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.ink,
            ),
          ),
        ),
      ],
    );
  }
}
