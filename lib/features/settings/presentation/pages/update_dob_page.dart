import 'package:flutter/material.dart';
import 'package:gp/l10n/app_localizations.dart';

class UpdateDobPage extends StatefulWidget {
  final String currentDob;
  final Function(String) onUpdate;

  const UpdateDobPage({
    super.key,
    required this.currentDob,
    required this.onUpdate,
  });

  @override
  State<UpdateDobPage> createState() => _UpdateDobPageState();
}

class _UpdateDobPageState extends State<UpdateDobPage> {
  final days = List.generate(31, (i) => (i + 1).toString().padLeft(2, '0'));
  late final List<String> years;

  int selDay = 3;
  int selMonth = 9;
  int selYear = 4;

  @override
  void initState() {
    super.initState();
    years = List.generate(100, (i) => (DateTime.now().year - i).toString());
    try {
      final p = widget.currentDob.split('-');
      if (p.length == 3) {
        selDay = int.parse(p[0]) - 1;
        selMonth = int.parse(p[1]) - 1;
        selYear = years.indexOf(p[2]);
        if (selYear < 0) selYear = 0;
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final months = [
      t.monthJanuary,
      t.monthFebruary,
      t.monthMarch,
      t.monthApril,
      t.monthMay,
      t.monthJune,
      t.monthJuly,
      t.monthAugust,
      t.monthSeptember,
      t.monthOctober,
      t.monthNovember,
      t.monthDecember,
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_left,
                    color: Color(0xFF062B4D), size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
              Text(t.dateOfBirth,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF062B4D))),
              const SizedBox(height: 40),
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    _WheelPicker(
                      items: days,
                      initialIndex: selDay,
                      selectedIndex: selDay,
                      onChanged: (i) => setState(() => selDay = i),
                    ),
                    _WheelPicker(
                      items: months,
                      initialIndex: selMonth,
                      selectedIndex: selMonth,
                      flex: 2,
                      onChanged: (i) => setState(() => selMonth = i),
                    ),
                    _WheelPicker(
                      items: years,
                      initialIndex: selYear,
                      selectedIndex: selYear,
                      onChanged: (i) => setState(() => selYear = i),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8940A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final d = days[selDay];
                    final m = (selMonth + 1).toString().padLeft(2, '0');
                    final y = years[selYear];
                    widget.onUpdate('$d-$m-$y');
                    Navigator.pop(context);
                  },
                  child: Text(t.update,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelPicker extends StatelessWidget {
  final List<String> items;
  final int initialIndex;
  final int selectedIndex;
  final int flex;
  final ValueChanged<int> onChanged;

  const _WheelPicker({
    required this.items,
    required this.initialIndex,
    required this.selectedIndex,
    required this.onChanged,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 44,
        perspective: 0.003,
        diameterRatio: 1.5,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: initialIndex),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: items.length,
          builder: (_, i) => Center(
            child: Text(items[i],
                style: TextStyle(
                  fontSize: 16,
                  color: i == selectedIndex
                      ? const Color(0xFF062B4D)
                      : Colors.grey,
                  fontWeight:
                      i == selectedIndex ? FontWeight.bold : FontWeight.normal,
                )),
          ),
        ),
      ),
    );
  }
}
