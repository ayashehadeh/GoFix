import 'package:flutter/material.dart';
import 'package:gp/l10n/app_localizations.dart';

class UpdateGenderPage extends StatefulWidget {
  final String currentGender;
  final Function(String) onUpdate;

  const UpdateGenderPage({
    super.key,
    required this.currentGender,
    required this.onUpdate,
  });

  @override
  State<UpdateGenderPage> createState() => _UpdateGenderPageState();
}

class _UpdateGenderPageState extends State<UpdateGenderPage> {
  late String selected;

  @override
  void initState() {
    super.initState();
    selected = widget.currentGender;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    // API values stay as 'Male'/'Female'; display labels are localized
    final genderOptions = <String, String>{
      'Male': t.genderMale,
      'Female': t.genderFemale,
    };
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
              Text(t.gender,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF062B4D))),
              const SizedBox(height: 40),
              Row(
                children: genderOptions.entries.map((entry) {
                  final apiValue = entry.key;
                  final displayLabel = entry.value;
                  final isSelected = selected == apiValue;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => selected = apiValue),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF062B4D)
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(displayLabel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF062B4D)
                                      : Colors.grey,
                                )),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
                    widget.onUpdate(selected);
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
