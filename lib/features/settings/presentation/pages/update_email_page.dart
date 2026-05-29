import 'package:flutter/material.dart';
import 'package:gp/l10n/app_localizations.dart';

enum _VerificationStep { none, codeSent, verified }

class UpdateEmailPage extends StatefulWidget {
  final Function(String) onUpdate;

  const UpdateEmailPage({super.key, required this.onUpdate});

  @override
  State<UpdateEmailPage> createState() => _UpdateEmailPageState();
}

class _UpdateEmailPageState extends State<UpdateEmailPage> {
  final _emailCtrl = TextEditingController();

  _VerificationStep _step = _VerificationStep.none;
  bool _sendingCode = false;
  bool _verifyingCode = false;
  final List<TextEditingController> _codeCtrl =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _codeFocus = List.generate(6, (_) => FocusNode());
  String? _codeError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    for (final c in _codeCtrl) {
      c.dispose();
    }
    for (final f in _codeFocus) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() {
      _sendingCode = true;
      _codeError = null;
      for (final c in _codeCtrl) {
        c.clear();
      }
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _sendingCode = false;
      _step = _VerificationStep.codeSent;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _codeFocus.first.requestFocus();
    });
  }

  Future<void> _verifyCode() async {
    final code = _codeCtrl.map((c) => c.text).join();
    if (code.length < 6) return;
    setState(() {
      _verifyingCode = true;
      _codeError = null;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _verifyingCode = false;
      _step = _VerificationStep.verified;
    });
    _showVerifiedDialog();
  }

  void _showVerifiedDialog() {
    final t = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Color(0xFF2E7D32), size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                t.emailVerifiedTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF062B4D),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t.emailVerifiedMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF062B4D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(t.ok,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
              Text(
                t.updateYourEmail,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF062B4D)),
              ),
              const SizedBox(height: 8),
              Text(
                t.emailVerificationMsg,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailCtrl,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: t.enterNewEmail,
                  hintStyle: const TextStyle(color: Colors.grey),
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
                ),
              ),
              const SizedBox(height: 16),
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
                    if (_emailCtrl.text.isNotEmpty) {
                      widget.onUpdate(_emailCtrl.text);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    t.update,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              // ── Verification section ────────────────────────────────────
              const SizedBox(height: 28),
              const Divider(thickness: 1),
              const SizedBox(height: 20),
              _buildVerificationSection(t),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationSection(AppLocalizations t) {
    final bool isVerified = _step == _VerificationStep.verified;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isVerified
                  ? Icons.verified_rounded
                  : Icons.mark_email_unread_outlined,
              size: 20,
              color: isVerified
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFF062B4D),
            ),
            const SizedBox(width: 8),
            Text(
              t.emailVerificationTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isVerified
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF062B4D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isVerified) ...[
          Text(
            t.emailVerifiedMessage,
            style:
                const TextStyle(fontSize: 14, color: Color(0xFF2E7D32)),
          ),
        ] else if (_step == _VerificationStep.none) ...[
          Text(
            t.emailNotVerified,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sendingCode ? null : _sendCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF062B4D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _sendingCode
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      t.sendVerificationCode,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ] else ...[
          Text(
            t.codeSentToEmail,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) {
              return SizedBox(
                width: 44,
                height: 52,
                child: TextField(
                  controller: _codeCtrl[i],
                  focusNode: _codeFocus[i],
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF062B4D),
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _codeError != null
                            ? Colors.red
                            : const Color(0xFF062B4D)
                                .withValues(alpha: 0.25),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF062B4D), width: 1.5),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && i < 5) {
                      _codeFocus[i + 1].requestFocus();
                    } else if (val.isEmpty && i > 0) {
                      _codeFocus[i - 1].requestFocus();
                    }
                  },
                ),
              );
            }),
          ),
          if (_codeError != null) ...[
            const SizedBox(height: 6),
            Text(_codeError!,
                style:
                    const TextStyle(fontSize: 12, color: Colors.red)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _verifyingCode ? null : _verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF062B4D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _verifyingCode
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      t.verifyCode,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(t.didNotReceiveCode,
                  style:
                      const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _step = _VerificationStep.none;
                    _codeError = null;
                    for (final c in _codeCtrl) {
                      c.clear();
                    }
                  });
                  _sendCode();
                },
                child: Text(
                  t.sendAgain,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF062B4D),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
