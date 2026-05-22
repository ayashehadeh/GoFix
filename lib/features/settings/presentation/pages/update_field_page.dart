import 'package:flutter/material.dart';
import 'package:gp/l10n/app_localizations.dart';

class UpdateFieldPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final String hint;
  final Function(String) onUpdate;

  const UpdateFieldPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.onUpdate,
  });

  @override
  State<UpdateFieldPage> createState() => _UpdateFieldPageState();
}

class _UpdateFieldPageState extends State<UpdateFieldPage> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
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
              Text(widget.title,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF062B4D))),
              const SizedBox(height: 8),
              Text(widget.subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 24),
              TextField(
                controller: _ctrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF062B4D))),
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
                    if (_ctrl.text.isNotEmpty) {
                      widget.onUpdate(_ctrl.text);
                      Navigator.pop(context);
                    }
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
