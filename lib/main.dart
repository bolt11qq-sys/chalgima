import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'store/app_store.dart';
import 'store/timer_service.dart';
import 'screens/home.dart';
import 'screens/review.dart';
import 'screens/timer.dart';
import 'screens/stats.dart';
import 'screens/subjects.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore();
  await store.init();
  final timerService = TimerService();

  runApp(ChalgimaApp(store: store, timerService: timerService));
}

class ChalgimaApp extends StatelessWidget {
  final AppStore store;
  final TimerService timerService;

  const ChalgimaApp({
    super.key,
    required this.store,
    required this.timerService,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          title: "Chalg'ima",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: RootShell(store: store, timerService: timerService),
        );
      },
    );
  }
}

class RootShell extends StatefulWidget {
  final AppStore store;
  final TimerService timerService;

  const RootShell({
    super.key,
    required this.store,
    required this.timerService,
  });

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _currentIndex = 0;

  void _onNavigateTab(int index) {
    if (index == 2) {
      // O'rtadagi Taymer tugmasi
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TimerScreen(store: widget.store, timerService: widget.timerService),
        ),
      );
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 4 ta asosiy yorliq (Bugun, Takrorlash, Statistika, Fanlar)
    final screens = [
      HomeScreen(
        store: widget.store,
        timerService: widget.timerService,
        onNavigateTab: _onNavigateTab,
      ),
      ReviewScreen(store: widget.store),
      // Index 2 taymer bo'lib modal/screen sifatida ochiladi
      StatsScreen(store: widget.store),
      SubjectsScreen(store: widget.store),
    ];

    final activeIndex = _currentIndex > 2 ? _currentIndex - 1 : _currentIndex;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: IndexedStack(
        index: activeIndex.clamp(0, screens.length - 1),
        children: screens,
      ),
      bottomNavigationBar: _buildCustomBottomBar(),
    );
  }

  Widget _buildCustomBottomBar() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppTheme.cardBorder, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 1. Bugun
            _buildNavItem(
              index: 0,
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Bugun',
            ),
            // 2. Takrorlash
            _buildNavItem(
              index: 1,
              icon: Icons.psychology_outlined,
              activeIcon: Icons.psychology,
              label: 'Takrorlash',
            ),
            // 3. Markaziy Taymer (Play)
            GestureDetector(
              onTap: () => _onNavigateTab(2),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            // 4. Statistika
            _buildNavItem(
              index: 3,
              icon: Icons.bar_chart_outlined,
              activeIcon: Icons.bar_chart_rounded,
              label: 'Statistika',
            ),
            // 5. Fanlar
            _buildNavItem(
              index: 4,
              icon: Icons.menu_book_outlined,
              activeIcon: Icons.menu_book_rounded,
              label: 'Fanlar',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.accent : AppTheme.grey;

    return Expanded(
      child: InkWell(
        onTap: () => _onNavigateTab(index),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
