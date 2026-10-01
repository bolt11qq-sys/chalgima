import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../store/app_store.dart';
import 'session_edit.dart';

class HistoryScreen extends StatefulWidget {
  final AppStore store;

  const HistoryScreen({super.key, required this.store});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedDay = 27;
  String _selectedFilter = 'Hammasi';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Top Bar (Back, Tarix va Qidiruv)
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
                            'Tarix',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.ink,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _isSearching = !_isSearching),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: AppTheme.squareIconDecoration,
                          child: const Icon(Icons.search_rounded, size: 22, color: AppTheme.ink),
                        ),
                      ),
                    ],
                  ),
                ),

                // Qidiruv maydoni (agar ochiq bo'lsa)
                if (_isSearching)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.plusJakartaSans(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Sessiyalarni qidirish...',
                          prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close, size: 18, color: AppTheme.grey),
                            onPressed: () => setState(() {
                              _searchController.clear();
                              _isSearching = false;
                            }),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 90),
                    children: [
                      // 2. Kalendar kartasi (Sentabr 2026)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.cardDecoration,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECEEF0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.chevron_left_rounded, size: 20, color: AppTheme.ink),
                                ),
                                Text(
                                  'Sentabr 2026',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.ink,
                                  ),
                                ),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECEEF0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.ink),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 7 ta kun (Du 21 dan Ya 27 gacha)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildCalendarDay('Du', 21, true),
                                _buildCalendarDay('Se', 22, true),
                                _buildCalendarDay('Ch', 23, false),
                                _buildCalendarDay('Pa', 24, true),
                                _buildCalendarDay('Ju', 25, true),
                                _buildCalendarDay('Sh', 26, true),
                                _buildCalendarDay('Ya', 27, true),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. Filtr chiplari (Hammasi, Kiberxavfsizlik, Ingliz tili, Flutter)
                      SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildFilterChip('Hammasi'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Kiberxavfsizlik'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Ingliz tili'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Flutter'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 4. Guruhlangan sessiyalar ro'yxati
                      // Guruh 1: Bugun, 27-sentabr · 2 s 42 daq
                      _buildDateHeader('Bugun, 27-sentabr', '2 s 42 daq'),
                      const SizedBox(height: 10),
                      _buildSessionCard(
                        icon: Icons.shield_outlined,
                        iconBg: AppTheme.blueBg,
                        iconColor: const Color(0xFF3E5FCC),
                        title: 'TryHackMe: Nmap xonasi',
                        subtitle: '08:10 · baho 4 · 2 kartochka',
                        duration: '1:12',
                      ),
                      const SizedBox(height: 10),
                      _buildSessionCard(
                        icon: Icons.language_outlined,
                        iconBg: AppTheme.mintBg,
                        iconColor: AppTheme.accent,
                        title: 'Speaking part 2',
                        subtitle: '13:30 · baho 3',
                        duration: '0:45',
                      ),
                      const SizedBox(height: 10),
                      _buildSessionCard(
                        icon: Icons.code_rounded,
                        iconBg: const Color(0xFFFDF0E2),
                        iconColor: const Color(0xFFB4690E),
                        title: 'SQLite bilan ishlash',
                        subtitle: '19:05 · baho 5 · 1 kartochka',
                        duration: '0:45',
                      ),
                      const SizedBox(height: 20),

                      // Guruh 2: Kecha, 26-sentabr · 1 s 10 daq
                      _buildDateHeader('Kecha, 26-sentabr', '1 s 10 daq'),
                      const SizedBox(height: 10),
                      _buildSessionCard(
                        icon: Icons.shield_outlined,
                        iconBg: AppTheme.blueBg,
                        iconColor: const Color(0xFF3E5FCC),
                        title: 'Burp Suite asoslari',
                        subtitle: '10:20 · baho 4',
                        duration: '0:40',
                      ),
                      const SizedBox(height: 10),
                      _buildSessionCard(
                        icon: Icons.language_outlined,
                        iconBg: AppTheme.mintBg,
                        iconColor: AppTheme.accent,
                        title: 'Reading practice',
                        subtitle: "21:00 · baho 2 · qo'lda",
                        duration: '0:30',
                      ),
                      const SizedBox(height: 20),

                      // Guruh 3: 25-sentabr · 3 s 05 daq
                      _buildDateHeader('25-sentabr', '3 s 05 daq'),
                      const SizedBox(height: 10),
                      _buildSessionCard(
                        icon: Icons.shield_outlined,
                        iconBg: AppTheme.blueBg,
                        iconColor: const Color(0xFF3E5FCC),
                        title: 'Linux huquqlari',
                        subtitle: '09:00 · baho 5 · 4 kartochka',
                        duration: '2:05',
                      ),
                      const SizedBox(height: 10),
                      _buildSessionCard(
                        icon: Icons.code_rounded,
                        iconBg: const Color(0xFFFDF0E2),
                        iconColor: const Color(0xFFB4690E),
                        title: 'Flutter widgetlari',
                        subtitle: '20:10 · baho 3',
                        duration: '1:00',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Pastki "+ Qo'lda sessiya qo'shish" tugmasi
            Positioned(
              bottom: 16,
              left: 24,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SessionEditScreen(store: widget.store)),
                  );
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppTheme.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 20, color: AppTheme.ink),
                      const SizedBox(width: 8),
                      Text(
                        "Qo'lda sessiya qo'shish",
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDay(String dayName, int dayNumber, bool hasActivity) {
    final isSelected = _selectedDay == dayNumber;
    return GestureDetector(
      onTap: () => setState(() => _selectedDay = dayNumber),
      child: Column(
        children: [
          Text(
            dayName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.grey,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accent
                  : (hasActivity ? AppTheme.mintBg : const Color(0xFFF3F4F1)),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$dayNumber',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (hasActivity ? const Color(0xFF1E4633) : AppTheme.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.cardBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(String title, String totalTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.ink,
          ),
        ),
        Text(
          totalTime,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String duration,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
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
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            duration,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}
