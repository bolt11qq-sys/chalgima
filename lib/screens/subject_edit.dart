import 'package:flutter/material.dart';
import '../theme.dart';
import '../store/app_store.dart';
import '../models/subject.dart';

class SubjectEditScreen extends StatefulWidget {
  final AppStore store;
  final Subject? subjectToEdit;

  const SubjectEditScreen({
    super.key,
    required this.store,
    this.subjectToEdit,
  });

  @override
  State<SubjectEditScreen> createState() => _SubjectEditScreenState();
}

class _SubjectEditScreenState extends State<SubjectEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _noteController;
  late int _dailyGoalMin;
  late int _weeklyGoalMin;
  late Color _selectedColor;
  late String _status;

  @override
  void initState() {
    super.initState();
    final s = widget.subjectToEdit;
    _nameController = TextEditingController(text: s?.name ?? '');
    _noteController = TextEditingController(text: s?.note ?? '');
    _dailyGoalMin = s?.dailyGoalMin ?? 45;
    _weeklyGoalMin = s?.weeklyGoalMin ?? 300;
    _selectedColor = s != null ? _parseColor(s.color) : AppTheme.subjectColors.first;
    _status = s?.status ?? 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final hexColor = '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';
    final s = Subject(
      id: widget.subjectToEdit?.id ?? 0,
      name: _nameController.text.trim(),
      icon: 'book',
      color: hexColor,
      weeklyGoalMin: _weeklyGoalMin,
      dailyGoalMin: _dailyGoalMin,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      sortOrder: widget.subjectToEdit?.sortOrder ?? widget.store.subjects.length + 1,
      status: _status,
      totalSeconds: widget.subjectToEdit?.totalSeconds ?? 0,
      createdAt: widget.subjectToEdit?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );

    await widget.store.saveSubject(s);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.subjectToEdit != null ? 'Fan yangilandi!' : 'Yangi fan qoʻshildi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectToEdit != null ? 'Fanni tahrirlash' : 'Yangi fan qoʻshish'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Fan nomi',
                hintText: 'Masalan: Kiberxavfsizlik & Pentest',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Iltimos nom kiriting' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Qisqa izoh yoki maqsad',
                hintText: 'Masalan: eJPT v2 va TryHackMe xonalari',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Fan rangi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: AppTheme.subjectColors.map((col) {
                final isSelected = _selectedColor.value == col.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = col),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: col,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: AppTheme.ink, width: 3) : null,
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Kunlik maqsad surgichi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kunlik maqsad:', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('$_dailyGoalMin daqiqa', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent)),
              ],
            ),
            Slider(
              value: _dailyGoalMin.toDouble(),
              min: 15,
              max: 180,
              divisions: 11,
              activeColor: AppTheme.accent,
              onChanged: (val) => setState(() => _dailyGoalMin = val.toInt()),
            ),
            const SizedBox(height: 16),

            // Haftalik maqsad surgichi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Haftalik maqsad:', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${_weeklyGoalMin ~/ 60} soat (${_weeklyGoalMin} daq)', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ink)),
              ],
            ),
            Slider(
              value: _weeklyGoalMin.toDouble(),
              min: 60,
              max: 1200,
              divisions: 19,
              activeColor: AppTheme.ink,
              onChanged: (val) => setState(() => _weeklyGoalMin = val.toInt()),
            ),
            const SizedBox(height: 24),

            if (widget.subjectToEdit != null) ...[
              SwitchListTile(
                title: const Text('Faol holatda'),
                subtitle: Text(_status == 'active' ? 'Bosh sahifada koʻrinadi' : 'Arxivlangan'),
                value: _status == 'active',
                activeColor: AppTheme.accent,
                onChanged: (val) => setState(() => _status = val ? 'active' : 'archived'),
              ),
              const SizedBox(height: 24),
            ],

            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _save,
                child: const Text('Saqlash', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
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
