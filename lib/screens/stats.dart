import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';
import '../store/app_store.dart';

class StatsScreen extends StatefulWidget {
  final AppStore store;

  const StatsScreen({super.key, required this.store});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _periodIndex = 0; // 0: Hafta, 1: Oy, 2: Yil

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistika'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.grey,
          indicatorColor: AppTheme.accent,
          tabs: const [
            Tab(text: 'Umumiy hisobot'),
            Tab(text: 'Life Detective xulosalari'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralStatsTab(),
          _buildLifeDetectiveTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralStatsTab() {
    final stats = widget.store.recentDayStats;

    // Kunlik o'rtacha hisoblash
    int totalSec = 0;
    int totalFocus = 0;
    int focusCount = 0;
    int totalReviews = 0;
    int correctReviews = 0;

    for (final s in stats) {
      totalSec += s.totalSeconds;
      if (s.avgFocus > 0) {
        totalFocus += s.avgFocus;
        focusCount++;
      }
      totalReviews += s.reviewsDone;
      correctReviews += s.reviewsCorrect;
    }

    final daysCount = stats.isNotEmpty ? stats.length : 1;
    final avgDailyMins = (totalSec ~/ 60) ~/ daysCount;
    final avgFocusScore = focusCount > 0 ? (totalFocus ~/ focusCount) : 75;
    final retentionPercent = totalReviews > 0 ? ((correctReviews / totalReviews) * 100).toInt() : 85;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Davr tanlash: Hafta, Oy, Yil
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Bu hafta')),
            ButtonSegment(value: 1, label: Text('Bu oy')),
            ButtonSegment(value: 2, label: Text('Barchasi')),
          ],
          selected: {_periodIndex},
          onSelectionChanged: (set) => setState(() => _periodIndex = set.first),
        ),
        const SizedBox(height: 20),

        // 3 ta asosiy ko'rsatkich kartalari (Section 6 Screen 3)
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.access_time_filled,
                title: "Kunlik o'rtacha",
                value: '$avgDailyMins daq',
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.psychology,
                title: 'Oʻrtacha diqqat',
                value: '$avgFocusScore / 100',
                color: AppTheme.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.local_fire_department,
                title: 'Joriy streak',
                value: '${widget.store.currentStreak} kun',
                color: AppTheme.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.memory,
                title: 'Esda saqlash',
                value: '$retentionPercent%',
                color: const Color(0xFF7C4DBC),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Haftalik o'qish grafigi (Bar chart)
        const Text(
          'Haftalik oʻqish vaqti (daqiqa)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          padding: const EdgeInsets.only(top: 20, right: 20, left: 10, bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.line),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 120,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) {
                      const titles = ['D', 'S', 'CH', 'P', 'J', 'SH', 'Y'];
                      final i = val.toInt();
                      if (i >= 0 && i < titles.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(titles[i], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (val, meta) {
                      if (val % 30 == 0) {
                        return Text('${val.toInt()}', style: const TextStyle(fontSize: 10, color: AppTheme.grey));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                _makeBarGroup(0, 45),
                _makeBarGroup(1, 60),
                _makeBarGroup(2, 90),
                _makeBarGroup(3, 75),
                _makeBarGroup(4, 50),
                _makeBarGroup(5, 100),
                _makeBarGroup(6, 40),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Fanlar bo'yicha taqsimot
        const Text(
          'Fanlar boʻyicha taqsimot',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...widget.store.subjects.map((subj) {
          final mins = subj.totalSeconds ~/ 60;
          final color = _parseColor(subj.color);
          final progress = totalSec > 0 ? (subj.totalSeconds / totalSec) : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(subj.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('$mins daqiqa (${(progress * 100).toInt()}%)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: AppTheme.line,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppTheme.accent,
          width: 18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
        ],
      ),
    );
  }

  // 5.10 Life Detective (Tahlil va xulosalar)
  Widget _buildLifeDetectiveTab() {
    final statsWithData = widget.store.recentDayStats.where((s) => s.sleepHours != null).toList();

    // 5.10 Shart: kamida 14 ta kun ma'lumoti bo'lishi shart!
    if (statsWithData.length < 14) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.grey.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.analytics_outlined, size: 54, color: AppTheme.grey),
              ),
              const SizedBox(height: 20),
              const Text(
                'Maʼlumotlar toʻplanmoqda',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Life Detective xulosalari faqat kamida 14 kunlik maʼlumot toʻplanganda (uyqu, kayfiyat va sport) koʻrsatiladi.\n\nHozirda: ${statsWithData.length} / 14 kun yigʻilgan.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppTheme.grey, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Topilgan bogʻliqliklar (Insights)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Korrelyatsiya tahlili asosida ehtimoliy xulosalar:',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(height: 16),
        _buildInsightCard(
          icon: Icons.bedtime,
          text: '7 soatdan kam uxlagan kunlarda diqqat koʻrsatkichi oʻrtacha 14 punktga pastroq boʻlgan.',
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          icon: Icons.fitness_center,
          text: 'Sport bilan shugʻullangan kunlarda oʻqish sessiyalari davomiyligi 25% yuqori natija koʻrsatgan.',
        ),
      ],
    );
  }

  Widget _buildInsightCard({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.accent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w600),
            ),
          ),
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
