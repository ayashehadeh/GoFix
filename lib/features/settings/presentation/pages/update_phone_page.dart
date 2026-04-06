import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UpdatePhonePage extends StatefulWidget {
  final Function(String) onUpdate;

  const UpdatePhonePage({super.key, required this.onUpdate});

  @override
  State<UpdatePhonePage> createState() => _UpdatePhonePageState();
}

class _UpdatePhonePageState extends State<UpdatePhonePage> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              const Text('Update your mobile number',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF062B4D))),
              const SizedBox(height: 8),
              const Text('We will send you a code to confirm it',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('+962',
                        style:
                            TextStyle(fontSize: 15, color: Color(0xFF062B4D))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onChanged: (_) => setState(() => _error = null),
                      decoration: InputDecoration(
                        hintText: '7xxxxxxxxx',
                        hintStyle: const TextStyle(color: Colors.grey),
                        errorText: _error,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFF062B4D))),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.red)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.red)),
                      ),
                    ),
                  ),
                ],
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
                    if (_ctrl.text.isEmpty) {
                      setState(() => _error = 'Phone number is required');
                      return;
                    }
                    if (_ctrl.text.length < 9) {
                      setState(() => _error = 'Must be at least 9 digits');
                      return;
                    }
                    widget.onUpdate('+962${_ctrl.text}');
                    Navigator.pop(context);
                  },
                  child: const Text('Update',
                      style: TextStyle(
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
