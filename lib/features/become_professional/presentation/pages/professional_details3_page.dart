import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/become_professional_bloc.dart';
import '../bloc/become_professional_event.dart';
import '../bloc/become_professional_state.dart';

class ProfessionalDetails3Page extends StatefulWidget {
  final VoidCallback onSubmit;
  const ProfessionalDetails3Page({super.key, required this.onSubmit});

  @override
  State<ProfessionalDetails3Page> createState() =>
      _ProfessionalDetails3PageState();
}

class _ProfessionalDetails3PageState extends State<ProfessionalDetails3Page> {
  String? _profilePath;
  String? _idPath;
  String? _certPath;
  String? _conductPath;

  bool _profileError = false;
  bool _idError      = false;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final s = context.read<BecomeProfessionalBloc>().state;
    if (s is BecomeProfessionalFormState) {
      _profilePath = s.profileImagePath;
      _idPath      = s.idImagePath;
      _certPath    = s.certificationImagePath;
      _conductPath = s.conductImagePath;
    }
  }

  Future<void> _pick(DocumentType type) async {
    final xfile = await _picker.pickImage(source: ImageSource.gallery);
    if (xfile == null) return;

    setState(() {
      switch (type) {
        case DocumentType.profile:
          _profilePath = xfile.path;
          _profileError = false;
          break;
        case DocumentType.id:
          _idPath = xfile.path;
          _idError = false;
          break;
        case DocumentType.certification:
          _certPath = xfile.path;
          break;
        case DocumentType.conduct:
          _conductPath = xfile.path;
          break;
      }
    });

    context
        .read<BecomeProfessionalBloc>()
        .add(UpdateDocument(type: type, path: xfile.path));
  }

  bool _validate() {
    setState(() {
      _profileError = _profilePath == null;
      _idError      = _idPath == null;
    });
    return !_profileError && !_idError;
  }

  void _onSubmit() {
    if (_validate()) widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verification Upload',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF062B4D)),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _UploadRow(
                  label: 'Upload Profile Picture',
                  filePath: _profilePath,
                  hasError: _profileError,
                  required: true,
                  onTap: () => _pick(DocumentType.profile),
                ),
                const SizedBox(height: 12),
                _UploadRow(
                  label: 'Upload ID',
                  filePath: _idPath,
                  hasError: _idError,
                  required: true,
                  onTap: () => _pick(DocumentType.id),
                ),
                const SizedBox(height: 12),
                _UploadRow(
                  label: 'Upload Certification',
                  filePath: _certPath,
                  required: false,
                  onTap: () => _pick(DocumentType.certification),
                ),
                const SizedBox(height: 12),
                _UploadRow(
                  label: 'Certificate of Good Conduct',
                  filePath: _conductPath,
                  required: false,
                  onTap: () => _pick(DocumentType.conduct),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        BlocBuilder<BecomeProfessionalBloc, BecomeProfessionalState>(
          builder: (context, state) {
            final isSubmitting = state is BecomeProfessionalSubmitting;
            return SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C1A),
                  disabledBackgroundColor:
                      const Color(0xFFFF8C1A).withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Continue',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _UploadRow extends StatelessWidget {
  final String label;
  final String? filePath;
  final bool hasError;
  final bool required;
  final VoidCallback onTap;

  const _UploadRow({
    required this.label,
    required this.onTap,
    this.filePath,
    this.hasError = false,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = filePath != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasError
                ? Colors.red
                : isDone
                    ? const Color(0xFF062B4D)
                    : const Color(0xFFDDDDDD),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                        fontSize: 13,
                        color: hasError
                            ? Colors.red
                            : const Color(0xFF062B4D)),
                  ),
                  if (!required)
                    const Text('Optional',
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey)),
                  if (isDone)
                    const Text('✓ File selected',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF062B4D),
                            fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(
              isDone ? Icons.check_circle : Icons.chevron_right,
              color: isDone
                  ? const Color(0xFF062B4D)
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
