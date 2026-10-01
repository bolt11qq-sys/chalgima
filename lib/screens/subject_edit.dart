import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late TextEditingController _weeklyGoalController;
  late TextEditingController _dailyGoalController;

  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;

  final List<IconData> _icons = [
    Icons.shield_outlined,
    Icons.language_outlined,
    Icons.code_rounded,
    Icons.menu_book_outlined,
    Icons.adjust_rounded,
    Icons.star_outline_rounded,
    Icons.psychology_outlined,
    Icons.bar_chart_rounded,
  ];

  final List<String> _iconNames = [
    'shield',
    'language',
    'code',
    'book',
    'target',
    'star',
    'brain',
    'chart',
  ];

  final List<Color> _colors = [
    const Color(0xFF3E5FCC), // Blue
    const Color(0xFF2E6B4E), // Green
    const Color(0xFFB4690E), // Brown/Amber
    const Color(0xFF7C4DBC), // Purple
    const Color(0xFFE08A0B), // Orange
    const Color(0xFFC4453C), // Red
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.subjectToEdit;
    _nameController = TextEditingController(text: s?.name ?? 'Kiberxavfsizlik');
    _noteController = TextEditingController(text: s?.note ?? 'eJPT sertifikatiga tayyorgarlik');
    _weeklyGoalController = TextEditingController(text: s != null ? '${s.weeklyGoalMin ~/ 60}' : '10');
    _dailyGoalController = TextEditingController(text: s != null ? '${(s.dailyGoalMin / 60).toStringAsFixed(1).replaceAll('.', ',')}' : '1,5');

    if (s != null) {
      final idx = _iconNames.indexOf(s.icon);
      if (idx != -1) _selectedIconIndex = idx;

      for (int i = 0; i < _colors.length; i++) {
        final hex = '#${_colors[i].value.toRadixString(16).substring(2).toUpperCase()}';
        if (s.color.toUpperCase() == hex) {
          _selectedColorIndex = i;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _weeklyGoalController.dispose();
    _dailyGoalController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final weeklyHours = double.tryParse(_weeklyGoalController.text.replaceAll(',', '.')) ?? 10.0;
    final dailyHours = double.tryParse(_dailyGoalController.text.replaceAll(',', '.')) ?? 1.5;
    final weeklyMin = (weeklyHours * 60).round();
    final dailyMin = (dailyHours * 60).round();

    final selectedColor = _colors[_selectedColorIndex];
    final hexColor = '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';

    final s = Subject(
      id: widget.subjectToEdit?.id ?? 0,
      name: _nameController.text.trim(),
      icon: _iconNames[_selectedIconIndex],
      color: hexColor,
      weeklyGoalMin: weeklyMin,
      dailyGoalMin: dailyMin,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      sortOrder: widget.subjectToEdit?.sortOrder ?? widget.store.subjects.length + 1,
      status: widget.subjectToEdit?.status ?? 'active',
      totalSeconds: widget.subjectToEdit?.totalSeconds ?? 0,
      createdAt: widget.subjectToEdit?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );

    await widget.store.saveSubject(s);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.subjectToEdit != null ? 'Fan yangilandi!' : 'Yangi fan saqlandi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _colors[_selectedColorIndex];
    final currentIcon = _icons[_selectedIconIndex];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Form(
          key: _formKey,
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
                          widget.subjectToEdit != null ? 'Fanni tahrirlash' : 'Yangi fan',
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
                    // Katta ikonka va nom ko'rinishi (Preview)
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: currentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(currentIcon, size: 40, color: currentColor),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _nameController.text.isNotEmpty ? _nameController.text : 'Fan nomi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Fan nomi
                    Text('Fan nomi', style: AppTheme.sansLabel(fontSize: 12, color: AppTheme.grey)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppTheme.ink, fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(
                          hintText: 'Kiberxavfsizlik',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Nom kiriting' : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Qisqa izoh
                    Text('Qisqa izoh', style: AppTheme.sansLabel(fontSize: 12, color: AppTheme.grey)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: TextFormField(
                        controller: _noteController,
                        style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppTheme.ink),
                        decoration: const InputDecoration(
                          hintText: 'eJPT sertifikatiga tayyorgarlik',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Haftalik maqsad va Kunlik maqsad
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Haftalik maqsad', style: AppTheme.sansLabel(fontSize: 12, color: AppTheme.grey)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _weeklyGoalController,
                                        keyboardType: TextInputType.number,
                                        style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppTheme.ink, fontWeight: FontWeight.bold),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                                        ),
                                      ),
                                    ),
                                    Text('soat', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kunlik maqsad', style: AppTheme.sansLabel(fontSize: 12, color: AppTheme.grey)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _dailyGoalController,
                                        keyboardType: TextInputType.number,
                                        style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppTheme.ink, fontWeight: FontWeight.bold),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                                        ),
                                      ),
                                    ),
                                    Text('soat', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Ikonka (8 ta variant)
                    Text('Ikonka', style: AppTheme.sansLabel(fontSize: 12, color: AppTheme.grey)),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.15,
                      ),
                      itemCount: _icons.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedIconIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIconIndex = index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.accent : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppTheme.accent : AppTheme.cardBorder,
                                width: 1.0,
                              ),
                            ),
                            child: Icon(
                              _icons[index],
                              color: isSelected ? Colors.white : AppTheme.ink,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Rang (6 ta variant)
                    Text('Rang', style: AppTheme.sansLabel(fontSize: 12, color: AppTheme.grey)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(_colors.length, (index) {
                        final color = _colors[index];
                        final isSelected = _selectedColorIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColorIndex = index),
                          child: Container(
                            width: 44,
                            height: 44,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? color : Colors.transparent,
                                width: 2.0,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Saqlash tugmasi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Saqlash',
                      style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
