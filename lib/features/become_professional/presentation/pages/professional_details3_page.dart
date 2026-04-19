import 'dart:ui';
import 'dart:io';
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
  final ImagePicker _picker = ImagePicker();

  static const _docs = [
    _DocItem(
      type: DocumentType.profile,
      label: 'Upload Profile picture',
    ),
    _DocItem(
      type: DocumentType.id,
      label: 'Upload ID',
    ),
    _DocItem(
      type: DocumentType.certification,
      label: 'Upload certification',
    ),
    _DocItem(
      type: DocumentType.conduct,
      label: 'Certificate of good conduct',
    ),
  ];

  void _showUploadSheet(DocumentType type, String label, String? currentPath) {
    File? tempImage = currentPath != null ? File(currentPath) : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return Stack(
          children: [
            // Blurred backdrop
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: StatefulBuilder(
                builder: (ctx, setModalState) {
                  return Container(
                    height: 350,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF062B4D),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Image picker area
                        GestureDetector(
                          onTap: () async {
                            final XFile? image = await _picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 85,
                            );
                            if (image != null) {
                              setModalState(() {
                                tempImage = File(image.path);
                              });
                            }
                          },
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFF062B4D)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: tempImage == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.upload_file,
                                          size: 40, color: Color(0xFF062B4D)),
                                      SizedBox(height: 10),
                                      Text('Tap to choose a photo',
                                          style: TextStyle(
                                              color: Color(0xFF062B4D))),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.file(
                                      tempImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                          ),
                        ),
                        const Spacer(),

                        // Save button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            if (tempImage != null) {
                              // Dispatch to BLoC
                              context
                                  .read<BecomeProfessionalBloc>()
                                  .add(UpdateDocument(
                                    type: type,
                                    path: tempImage!.path,
                                  ));
                              // Refresh local UI
                              setState(() {});
                            }
                            Navigator.pop(ctx);
                          },
                          child: const Text(
                            'Save Photo',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BecomeProfessionalBloc, BecomeProfessionalState>(
      builder: (context, state) {
        final formState = state is BecomeProfessionalFormState
            ? state
            : BecomeProfessionalFormState();

        final isSubmitting = state is BecomeProfessionalSubmitting;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),

              // Document rows
              ..._docs.map((doc) {
                final path = formState.pathFor(doc.type);
                final isUploaded = path != null;
                return _DocumentRow(
                  label: doc.label,
                  isUploaded: isUploaded,
                  onTap: () => _showUploadSheet(doc.type, doc.label, path),
                );
              }),

              const SizedBox(height: 32),

              // Submit / Done button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: isSubmitting ? null : widget.onSubmit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

// ─── Doc item model ───────────────────────────────────────────────────────────

class _DocItem {
  final DocumentType type;
  final String label;
  const _DocItem({required this.type, required this.label});
}

// ─── Document row widget ──────────────────────────────────────────────────────

class _DocumentRow extends StatelessWidget {
  final String label;
  final bool isUploaded;
  final VoidCallback onTap;

  const _DocumentRow({
    required this.label,
    required this.isUploaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            if (isUploaded)
              const Icon(Icons.check_circle, size: 18, color: Colors.green)
            else
              const SizedBox(width: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  color: isUploaded
                      ? Colors.green.shade700
                      : const Color(0xFF062B4D),
                  fontWeight: isUploaded ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            GestureDetector(
              onTap: onTap,
              child: Icon(
                isUploaded ? Icons.edit_outlined : Icons.chevron_right,
                color: const Color(0xFF062B4D),
                size: 28,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(height: 30),
      ],
    );
  }
}
