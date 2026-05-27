import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/features/become_professional/domain/entities/document_type.dart';
import 'package:gp/features/become_professional/presentation/bloc/become_professional_bloc.dart';
import 'package:gp/features/become_professional/presentation/bloc/become_professional_state.dart';
import 'package:gp/features/become_professional/presentation/pages/document_upload_page.dart';
import 'package:gp/features/become_professional/presentation/widgets/step_continue_button.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/professional_document.dart';

class EditVerificationPage extends StatelessWidget {
  final Professional professional;
  final VoidCallback onSaved;

  const EditVerificationPage({
    super.key,
    required this.professional,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    final certifications = professional.documents
        .where((d) => d.isCertification)
        .toList();

    return BlocBuilder<BecomeProfessionalBloc, BecomeProfessionalState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verification Documents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your existing certifications are shown below. You can add new ones but cannot modify existing ones.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  // ── Profile Picture ───────────────────────────────────
                  _DocRow(
                    label: 'Profile Picture',
                    isRequired: true,
                    existingFileName:
                        professional.profileImageUrl != null ? _fileNameFromUrl(professional.profileImageUrl!) : null,
                    sessionUploaded: state.profilePictureUploadStatus == ActionStatus.success,
                    onTap: () => _openUpload(
                      context,
                      title: 'Profile Picture',
                      documentType: null,
                    ),
                  ),

                  // ── Existing certifications (read-only) ───────────────
                  if (certifications.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Your Certifications',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...certifications.map((doc) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _CertCard(doc: doc),
                        )),
                  ],

                  // ── Add new certification ─────────────────────────────
                  const SizedBox(height: 10),
                  _DocRow(
                    label: 'Add New Certification',
                    sessionUploaded: state.statusFor(DocumentType.certification) == ActionStatus.success,
                    onTap: () => _openUpload(
                      context,
                      title: 'Add New Certification',
                      documentType: DocumentType.certification,
                    ),
                  ),
                ],
              ),
            ),
            StepContinueButton(
              onPressed: onSaved,
              label: 'Save Changes',
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Future<void> _openUpload(
    BuildContext context, {
    required String title,
    DocumentType? documentType,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BecomeProfessionalBloc>(),
          child: DocumentUploadPage(
            title: title,
            documentType: documentType,
          ),
        ),
      ),
    );
  }

  String _fileNameFromUrl(String url) {
    return url.split('/').last.split('?').first;
  }
}

// ─── Read-only certification card ────────────────────────────────────────────

class _CertCard extends StatelessWidget {
  final ProfessionalDocument doc;

  const _CertCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: AppColors.primaryOrange,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                if (doc.issuedYear != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Issued ${doc.issuedYear}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.divider.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'On File',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Document row ─────────────────────────────────────────────────────────────

class _DocRow extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String? existingFileName;
  final bool sessionUploaded;
  final VoidCallback onTap;

  const _DocRow({
    required this.label,
    required this.onTap,
    this.isRequired = false,
    this.existingFileName,
    this.sessionUploaded = false,
  });

  bool get _isUploaded => sessionUploaded || existingFileName != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isUploaded ? AppColors.primaryOrange : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isUploaded
                    ? AppColors.primaryOrange.withValues(alpha: 0.1)
                    : AppColors.divider.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isUploaded ? Icons.check_circle : Icons.cloud_upload_outlined,
                color: _isUploaded ? AppColors.primaryOrange : AppColors.primaryDark,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      if (isRequired) ...[
                        const SizedBox(width: 4),
                        const Text(
                          '*',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isUploaded ? 'Uploaded${existingFileName != null ? ' · $existingFileName' : ''}' : 'Tap to upload',
                    style: TextStyle(
                      fontSize: 11,
                      color: _isUploaded ? AppColors.primaryOrange : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.primaryDark, size: 22),
          ],
        ),
      ),
    );
  }
}
