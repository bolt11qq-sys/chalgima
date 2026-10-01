import 'package:flutter/material.dart';
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
  void _showBackupExportDialog() async {
    final jsonStr = await widget.store.exportBackupJson();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Zaxira nusxa (JSON)'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ushbu JSON kodini nusxalab xavfsiz joyda saqlashingiz mumkin:'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.bg,
                  borderRadius: BorderRadius.circular(12),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Yopish')),
        ],
      ),
    );
  }

  void _showBackupImportDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Zaxira nusxadan tiklash'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Eksport qilingan JSON matnini shu yerga joylashtiring:'),
            const SizedBox(height: 10),
            TextField(
              controller: textController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: '{"version": 1, ...}',
                filled: true,
                fillColor: AppTheme.bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Bekor qilish')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            onPressed: () async {
              final ok = await widget.store.importBackupJson(textController.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Maʼlumotlar tiklandi!' : 'Xatolik: notoʻgʻri format')),
                );
              }
            },
            child: const Text('Tiklash', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCsvImportDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('CSV formatda kartochkalar importi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Format: savol, javob, fan_nomi\n(Har qator bitta kartochka):'),
            const SizedBox(height: 10),
            TextField(
              controller: textController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Nmap nima?, Tarmoq skaneri, Tarmoqlar\nApple, Olma, Ingliz tili',
                filled: true,
                fillColor: AppTheme.bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Bekor qilish')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.ink),
            onPressed: () async {
              final count = await widget.store.importCsvCards(textController.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$count ta yangi kartochka muvaffaqiyatli qoʻshildi!')),
                );
              }
            },
            child: const Text('Import qilish', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sozlamalar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. Maqsadlar
          _buildSectionHeader('Oʻqish maqsadlari'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.line),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kunlik umumiy maqsad:', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('${widget.store.dailyGoalMinutes} daqiqa', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent)),
                  ],
                ),
                Slider(
                  value: widget.store.dailyGoalMinutes.toDouble(),
                  min: 30,
                  max: 240,
                  divisions: 14,
                  activeColor: AppTheme.accent,
                  onChanged: (val) {
                    setState(() => widget.store.dailyGoalMinutes = val.toInt());
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Takrorlash (SRS) chegaralari
          _buildSectionHeader('Takrorlash (SRS) chegaralari'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.line),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kunlik jami kartochkalar:'),
                    Text('${widget.store.srsDailyLimit} ta', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: widget.store.srsDailyLimit.toDouble(),
                  min: 10,
                  max: 50,
                  divisions: 8,
                  activeColor: AppTheme.ink,
                  onChanged: (val) => setState(() => widget.store.srsDailyLimit = val.toInt()),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Yangi kartochkalar chegarasi:'),
                    Text('${widget.store.srsNewLimit} ta', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: widget.store.srsNewLimit.toDouble(),
                  min: 5,
                  max: 25,
                  divisions: 4,
                  activeColor: AppTheme.ink,
                  onChanged: (val) => setState(() => widget.store.srsNewLimit = val.toInt()),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kunlik vaziyatlar chegarasi:'),
                    Text('${widget.store.srsScenarioLimit} ta', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.amber)),
                  ],
                ),
                Slider(
                  value: widget.store.srsScenarioLimit.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: AppTheme.amber,
                  onChanged: (val) => setState(() => widget.store.srsScenarioLimit = val.toInt()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Bezovta qilmang va Bildirishnomalar
          _buildSectionHeader('Diqqat va Rejimlar'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.line),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Bezovta qilmang (DND)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Taymer paytida ovoz va chalgʻituvchi signallarni cheklash'),
                  value: widget.store.dndEnabled,
                  activeColor: AppTheme.accent,
                  onChanged: (val) => setState(() => widget.store.dndEnabled = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Zaxira nusxa va Import / Eksport (5.12)
          _buildSectionHeader('Zaxira nusxa va Maʼlumotlar (Oflayn)'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.line),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: AppTheme.accent),
                  title: const Text('Zaxira nusxa olish (JSON eksport)'),
                  subtitle: const Text('Barcha fanlar, sessiyalar va kartochkalarni saqlash'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: _showBackupExportDialog,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_upload_outlined, color: AppTheme.ink),
                  title: const Text('Zaxiradan tiklash (JSON import)'),
                  subtitle: const Text('Oldingi zaxira nusxani qayta tiklash'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: _showBackupImportDialog,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.table_chart_outlined, color: Color(0xFF7C4DBC)),
                  title: const Text('CSV formatda kartochkalar importi'),
                  subtitle: const Text('Anki yoki boshqa ilovalardan kartochkalarni koʻchirish'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: _showCsvImportDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Ilova haqida
          Center(
            child: Column(
              children: [
                const Text(
                  "Chalg'ima — 1.0.0",
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  "100% oflayn • Ma'lumot faqat sizning telefoningizda saqlanadi",
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.ink),
      ),
    );
  }
}
