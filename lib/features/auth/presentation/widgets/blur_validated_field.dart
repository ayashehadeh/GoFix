import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gp/core/theme/app_colors.dart';

/// A text field that validates ONLY when focus leaves it (on blur),
/// not on every keystroke. The error clears as soon as the user edits again,
/// and re-checks when they leave the field once more.
///
/// Still works with a parent Form: it exposes the same `validator`, so calling
/// `Form.validate()` on submit will surface any remaining errors too.
class BlurValidatedField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? hint;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const BlurValidatedField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.hint,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
  });

  @override
  State<BlurValidatedField> createState() => _BlurValidatedFieldState();
}

class _BlurValidatedFieldState extends State<BlurValidatedField> {
  final FocusNode _focusNode = FocusNode();
  String? _errorText;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    // When focus LEAVES the field, validate it once.
    if (!_focusNode.hasFocus && _touched) {
      _runValidation();
    }
  }

  void _runValidation() {
    final error = widget.validator?.call(widget.controller.text);
    setState(() => _errorText = error);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 7),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscure,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          // Form.validate() on submit still uses this; inline display is manual.
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.disabled,
          onChanged: (_) {
            _touched = true;
            // Clear the error the moment they start fixing it.
            if (_errorText != null) {
              setState(() => _errorText = null);
            }
          },
          decoration: InputDecoration(
            prefixIcon: Icon(widget.icon),
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            // We render the error ourselves (below) so it only appears on blur.
            errorText: _errorText,
            suffixIcon: widget.onToggleObscure == null
                ? null
                : IconButton(
                    icon: Icon(widget.obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: widget.onToggleObscure,
                  ),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: _border(Colors.transparent),
            enabledBorder: _border(Colors.transparent),
            focusedBorder: _border(AppColors.accent, width: 1.5),
            errorBorder: _border(Colors.red, width: 1.2),
            focusedErrorBorder: _border(Colors.red, width: 1.5),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: color == Colors.transparent ? BorderSide.none : BorderSide(color: color, width: width),
    );
  }
}
