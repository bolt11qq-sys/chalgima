import 'package:flutter/material.dart';
import 'theme.dart';
import 'store/app_store.dart';
import 'store/timer_service.dart';
import 'screens/home.dart';
import 'screens/review.dart';
import 'screens/timer.dart';
import 'screens/history.dart';
import 'screens/stats.dart';

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
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        store: widget.store,
        timerService: widget.timerService,
        onNavigateTab: _onNavigateTab,
      ),
      ReviewScreen(store: widget.store),
      TimerScreen(store: widget.store, timerService: widget.timerService),
      HistoryScreen(store: widget.store),
      StatsScreen(store: widget.store),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        elevation: 2,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Bosh sahifa',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Takrorlash',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Taymer',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Tarix',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistika',
          ),
        ],
      ),
    );
  }
}
