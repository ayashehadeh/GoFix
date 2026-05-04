import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/document_type.dart';
import '../bloc/become_professional_bloc.dart';
import '../bloc/become_professional_event.dart';
import '../bloc/become_professional_state.dart';
import '../widgets/step_continue_button.dart';
import 'document_upload_page.dart';

class VerificationUploadPage extends StatefulWidget {
  /// Called when final submission succeeds — pushes the queue page.
  final VoidCallback onSubmitted;

  const VerificationUploadPage({super.key, required this.onSubmitted});

  @override
  State<VerificationUploadPage> createState() => _VerificationUploadPageState();
}

class _VerificationUploadPageState extends State<VerificationUploadPage> {
  ActionStatus _previousSubmitStatus = ActionStatus.idle;

  void _onSubmitPressed() {
    final state = context.read<BecomeProfessionalBloc>().state;
    final app = state.application;

    if (app.profileImagePath == null) {
      _showSnack('Please upload your profile picture first.');
      return;
    }
    if (state.profilePictureUploadStatus != ActionStatus.success) {
      _showSnack('Please upload your profile picture first.');
      return;
    }
    if (app.identityPath == null) {
      _showSnack('Please upload your ID first.');
      return;
    }
    if (state.statusFor(DocumentType.identity) != ActionStatus.success) {
      _showSnack('Please upload your ID first.');
      return;
    }

    context
        .read<BecomeProfessionalBloc>()
        .add(const SubmitApplicationRequested());
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  Future<void> _openUpload({
    required String title,
    DocumentType? documentType, // null => profile picture
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BecomeProfessionalBloc, BecomeProfessionalState>(
      listenWhen: (prev, curr) =>
          prev.submitStatus != curr.submitStatus ||
          prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (_previousSubmitStatus == ActionStatus.loading &&
            state.submitStatus == ActionStatus.success) {
          widget.onSubmitted();
        } else if (state.submitStatus == ActionStatus.failure &&
            state.errorMessage != null) {
          _showSnack(state.errorMessage!);
        }
        _previousSubmitStatus = state.submitStatus;
      },
      builder: (context, state) {
        final isLoading = state.submitStatus == ActionStatus.loading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verification Upload',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Upload the required documents to verify your professional account.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _UploadRow(
                    label: 'Profile Picture',
                    isUploaded: state.profilePictureUploadStatus ==
                        ActionStatus.success,
                    isRequired: true,
                    onTap: () => _openUpload(
                      title: 'Profile Picture',
                      documentType: null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _UploadRow(
                    label: 'Upload ID',
                    isUploaded: state.statusFor(DocumentType.identity) ==
                        ActionStatus.success,
                    isRequired: true,
                    onTap: () => _openUpload(
                      title: 'Upload ID',
                      documentType: DocumentType.identity,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _UploadRow(
                    label: 'Upload Certification',
                    isUploaded: state.statusFor(DocumentType.certification) ==
                        ActionStatus.success,
                    onTap: () => _openUpload(
                      title: 'Upload Certification',
                      documentType: DocumentType.certification,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _UploadRow(
                    label: 'Certificate of Good Conduct',
                    isUploaded: state.statusFor(DocumentType.goodConduct) ==
                        ActionStatus.success,
                    onTap: () => _openUpload(
                      title: 'Certificate of Good Conduct',
                      documentType: DocumentType.goodConduct,
                    ),
                  ),
                ],
              ),
            ),
            StepContinueButton(
              onPressed: _onSubmitPressed,
              isLoading: isLoading,
              label: 'Submit Application',
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _UploadRow extends StatelessWidget {
  final String label;
  final bool isUploaded;
  final bool isRequired;
  final VoidCallback onTap;

  const _UploadRow({
    required this.label,
    required this.isUploaded,
    required this.onTap,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded
                ? AppColors.primaryOrange
                : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isUploaded
                    ? AppColors.primaryOrange.withOpacity(0.1)
                    : AppColors.divider.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isUploaded
                    ? Icons.check_circle
                    : Icons.cloud_upload_outlined,
                color: isUploaded
                    ? AppColors.primaryOrange
                    : AppColors.primaryDark,
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
                    isUploaded ? 'Uploaded' : 'Tap to upload',
                    style: TextStyle(
                      fontSize: 11,
                      color: isUploaded
                          ? AppColors.primaryOrange
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.primaryDark,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
