import 'package:flutter/material.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/l10n/app_localizations.dart';

class UpdateNamePage extends StatefulWidget {
  final String currentName;
  final Future<void> Function(String firstName, String lastName) onUpdate;

  const UpdateNamePage({
    super.key,
    required this.currentName,
    required this.onUpdate,
  });

  @override
  State<UpdateNamePage> createState() => _UpdateNamePageState();
}

class _UpdateNamePageState extends State<UpdateNamePage> {
  late final TextEditingController _firstCtrl;
  late final TextEditingController _lastCtrl;
  bool _loading = false;
  String? _firstError;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    final parts = widget.currentName.trim().split(RegExp(r'\s+'));
    _firstCtrl = TextEditingController(text: parts.isNotEmpty ? parts.first : '');
    _lastCtrl = TextEditingController(
      text: parts.length > 1 ? parts.skip(1).join(' ') : '',
    );
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryDark),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  Future<void> _submit(AppLocalizations t) async {
    final first = _firstCtrl.text.trim();
    final last = _lastCtrl.text.trim();

    setState(() {
      _firstError = first.isEmpty ? t.required : null;
      _lastError = last.isEmpty ? t.required : null;
    });
    if (first.isEmpty || last.isEmpty) return;

    setState(() => _loading = true);
    await widget.onUpdate(first, last);
    if (mounted) {
      setState(() => _loading = false);
      Navigator.pop(context);
    }
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
                    color: AppColors.primaryDark, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
              Text(
                t.updateYourName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.namePersonalizeExp,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 28),

              // First name
              TextField(
                controller: _firstCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: _fieldDecoration(t.firstName, t.firstName).copyWith(
                  errorText: _firstError,
                ),
                onChanged: (_) {
                  if (_firstError != null) setState(() => _firstError = null);
                },
              ),
              const SizedBox(height: 16),

              // Last name
              TextField(
                controller: _lastCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: _fieldDecoration(t.lastName, t.lastName).copyWith(
                  errorText: _lastError,
                ),
                onChanged: (_) {
                  if (_lastError != null) setState(() => _lastError = null);
                },
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _loading ? null : () => _submit(t),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          t.update,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
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
