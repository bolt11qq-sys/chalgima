import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../store/app_store.dart';
import '../store/timer_service.dart';

class SettingsScreen extends StatefulWidget {
  final AppStore store;
  final TimerService? timerService;

  const SettingsScreen({
    super.key,
    required this.store,
    this.timerService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _distractionTrack = true;
  bool _screenTimeStats = false;
  bool _shuffleCards = true;
  bool _dailyReminder = true;
  bool _darkMode = false;

  void _showBackupExportDialog() async {
    final jsonStr = await widget.store.exportBackupJson();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Zaxira nusxa (JSON)', style: GoogleFonts.newsreader(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ushbu JSON kodini nusxalab xavfsiz joyda saqlashingiz mumkin:', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    jsonStr,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Yopish', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppTheme.accent)),
          ),
        ],
      ),
    );
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
                        'Sozlamalar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // Foydalanuvchi profili kartasi
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.cardDecoration,
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: Color(0xFF15253F),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'S',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shovkat',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '81 soat · 13 kunlik streak',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppTheme.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.edit_outlined, color: AppTheme.ink, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 1. MAQSADLAR
                  Text('MAQSADLAR', style: AppTheme.sansLabel(fontSize: 11, color: AppTheme.grey)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: AppTheme.cardDecoration,
                    child: Column(
                      children: [
                        _buildSettingRow(
                          icon: Icons.track_changes_rounded,
                          iconBg: AppTheme.mintBg,
                          iconColor: AppTheme.accent,
                          title: 'Kunlik maqsad',
                          trailingText: '3 soat',
                          showChevron: true,
                        ),
                        const Divider(color: AppTheme.line, height: 1),
                        _buildSettingRow(
                          icon: Icons.calendar_today_outlined,
                          iconBg: AppTheme.blueBg,
                          iconColor: const Color(0xFF3E5FCC),
                          title: 'Dam olish kunlari',
                          subtitle: 'Streak buzilmaydi',
                          trailingText: '1 kun/oy',
                          showChevron: true,
                        ),
                        const Divider(color: AppTheme.line, height: 1),
                        _buildSettingRow(
                          icon: Icons.access_time_rounded,
                          iconBg: const Color(0xFFFEF3C7),
                          iconColor: const Color(0xFFD97706),
                          title: 'Kun almashish vaqti',
                          subtitle: 'Tungi sessiyalar uchun',
                          trailingText: '04:00',
                          showChevron: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. TAYMER
                  Text('TAYMER', style: AppTheme.sansLabel(fontSize: 11, color: AppTheme.grey)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: AppTheme.cardDecoration,
                    child: Column(
                      children: [
                        _buildSettingRow(
                          icon: Icons.play_arrow_outlined,
                          iconBg: AppTheme.mintBg,
                          iconColor: AppTheme.accent,
                          title: 'Pomodoro uzunligi',
                          trailingText: '25 / 5 daq',
                          showChevron: true,
                        ),
                        const Divider(color: AppTheme.line, height: 1),
                        _buildSettingRow(
                          icon: Icons.warning_amber_rounded,
                          iconBg: const Color(0xFFFEF3C7),
                          iconColor: const Color(0xFFD97706),
                          title: 'Chiqib ketishni hisoblash',
                          subtitle: "Boshqa ilovaga o'tishni sanaydi",
                          trailingWidget: Switch(
                            value: _distractionTrack,
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppTheme.accent,
                            onChanged: (v) => setState(() => _distractionTrack = v),
                          ),
                        ),
                        const Divider(color: AppTheme.line, height: 1),
                        _buildSettingRow(
                          icon: Icons.phone_android_outlined,
                          iconBg: const Color(0xFFECEEF0),
                          iconColor: AppTheme.grey,
                          title: 'Ekran vaqti statistikasi',
                          subtitle: 'Ruxsat kerak',
                          trailingWidget: Switch(
                            value: _screenTimeStats,
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppTheme.accent,
                            onChanged: (v) => setState(() => _screenTimeStats = v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. TAKRORLASH
                  Text('TAKRORLASH', style: AppTheme.sansLabel(fontSize: 11, color: AppTheme.grey)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: AppTheme.cardDecoration,
                    child: Column(
                      children: [
                        _buildSettingRow(
                          icon: Icons.psychology_outlined,
                          iconBg: AppTheme.blueBg,
                          iconColor: const Color(0xFF3E5FCC),
                          title: 'Kunlik chegara',
                          trailingText: '20 ta',
                          showChevron: true,
                        ),
                        const Divider(color: AppTheme.line, height: 1),
                        _buildSettingRow(
                          icon: Icons.add_circle_outline,
                          iconBg: AppTheme.mintBg,
                          iconColor: AppTheme.accent,
                          title: 'Yangi kartochka chegarasi',
                          trailingText: '10 ta',
                          showChevron: true,
                        ),
                        const Divider(color: AppTheme.line, height: 1),
                        _buildSettingRow(
                          icon: Icons.layers_outlined,
                          iconBg: const Color(0xFFFEF3C7),
                          iconColor: const Color(0xFFD97706),
                          title: 'Aralashtirib berish',
                          subtitle: 'Fanlar navbatlashadi',
                          trailingWidget: Switch(
                            value: _shuffleCards,
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppTheme.accent,
                            onChanged: (v) => setState(() => _shuffleCards = v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. ILOVA
                  Text('ILOVA', style: AppTheme.sansLabel(fontSize: 11, color: AppTheme.grey)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: AppTheme.cardDecoration,
                    child: Column(
                      children: [
                        _buildSettingRow(
                          icon: Icons.notifications_none_rounded,
                          iconBg: const Color(0xFFFEF3C7),
                          iconColor: const Color(0xFFD97706),
                          title: 'Kunlik eslatma',
                          subtitle: 'Har kuni 21:00',
                          trailingWidget: Switch(
                            value: _dailyReminder,
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppTheme.accent,
                            onChanged: (v) => setState(() => _dailyReminder = v),
                          ),
                        ),
                        const Divider(color: AppTheme.line, height: 1),
                        _buildSettingRow(
                          icon: Icons.dark_mode_outlined,
                          iconBg: const Color(0xFFECEEF0),
                          iconColor: AppTheme.grey,
                          title: "Qorong'i mavzu",
                          trailingWidget: Switch(
                            value: _darkMode,
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppTheme.accent,
                            onChanged: (v) => setState(() => _darkMode = v),
                          ),
                        ),
                        const Divider(color: AppTheme.line, height: 1),
                        _buildSettingRow(
                          icon: Icons.download_outlined,
                          iconBg: const Color(0xFFECEEF0),
                          iconColor: AppTheme.grey,
                          title: 'Zaxira nusxa',
                          subtitle: 'Faylga saqlash',
                          showChevron: true,
                          onTap: _showBackupExportDialog,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Footer: Chalg'ima v1.0
                  Center(
                    child: Text(
                      "Chalg'ima v1.0",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.grey,
                        fontWeight: FontWeight.w500,
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

  Widget _buildSettingRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? subtitle,
    String? trailingText,
    bool showChevron = false,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.grey,
                ),
              ),
              if (showChevron) const SizedBox(width: 4),
            ],
            if (showChevron)
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.grey),
            if (trailingWidget != null) trailingWidget,
          ],
        ),
      ),
    );
  }
}
