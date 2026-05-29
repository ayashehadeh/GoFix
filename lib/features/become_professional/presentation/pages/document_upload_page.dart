import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/document_type.dart';
import '../bloc/become_professional_bloc.dart';
import '../bloc/become_professional_event.dart';
import '../bloc/become_professional_state.dart';
import '../widgets/step_continue_button.dart';

class DocumentUploadPage extends StatefulWidget {
  final String title;
  final DocumentType? documentType;

  const DocumentUploadPage({
    super.key,
    required this.title,
    required this.documentType,
  });

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  final _picker = ImagePicker();
  final _nameController = TextEditingController();
  final _issuedYearController = TextEditingController();
  ActionStatus _previousUploadStatus = ActionStatus.idle;

  @override
  void dispose() {
    _nameController.dispose();
    _issuedYearController.dispose();
    super.dispose();
  }

  ActionStatus _statusFrom(BecomeProfessionalState state) {
    return widget.documentType == null
        ? state.profilePictureUploadStatus
        : state.statusFor(widget.documentType!);
  }

  String? _pathFrom(BecomeProfessionalState state) {
    final app = state.application;
    if (widget.documentType == null) return app.profileImagePath;
    return app.pathFor(widget.documentType!);
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final t = AppLocalizations.of(ctx)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined,
                    color: AppColors.primaryDark),
                title: Text(t.takePhoto),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.primaryDark),
                title: Text(t.chooseFromGallery),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (picked == null) return;

      final bloc = context.read<BecomeProfessionalBloc>();
      if (widget.documentType == null) {
        bloc.add(ProfilePicturePicked(picked.path));
      } else {
        bloc.add(DocumentPicked(
          documentType: widget.documentType!,
          filePath: picked.path,
        ));
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, 'Could not pick image: $e');
      }
    }
  }

  void _onSavePressed() {
    final state = context.read<BecomeProfessionalBloc>().state;
    final path = _pathFrom(state);
    if (path == null) {
      final t = AppLocalizations.of(context)!;
      showWarningSnackbar(context, t.pleaseChoosePhotoFirst);
      return;
    }

    if (widget.documentType == DocumentType.certification &&
        _nameController.text.trim().isEmpty) {
      showWarningSnackbar(context, 'Please enter the certification name.');
      return;
    }

    final bloc = context.read<BecomeProfessionalBloc>();
    if (widget.documentType == null) {
      bloc.add(UploadProfilePictureWithPathRequested(path));
    } else {
      bloc.add(UploadDocumentWithPathRequested(
        documentType: widget.documentType!,
        filePath: path,
        name: widget.documentType == DocumentType.certification
            ? _nameController.text.trim()
            : null,
        issuedYear: widget.documentType == DocumentType.certification
            ? int.tryParse(_issuedYearController.text.trim())
            : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<BecomeProfessionalBloc, BecomeProfessionalState>(
        listenWhen: (prev, curr) {
          return _statusFrom(prev) != _statusFrom(curr);
        },
        listener: (context, state) {
          final status = _statusFrom(state);
          if (_previousUploadStatus == ActionStatus.loading &&
              status == ActionStatus.success) {
            final t = AppLocalizations.of(context)!;
            showSuccessSnackbar(context, t.uploadedSuccessfully);
            Navigator.pop(context);
          } else if (status == ActionStatus.failure &&
              state.errorMessage != null) {
            showErrorSnackbar(context, state.errorMessage!);
          }
          _previousUploadStatus = status;
        },
        builder: (context, state) {
          final path = _pathFrom(state);
          final status = _statusFrom(state);
          final isLoading = status == ActionStatus.loading;

          final t = AppLocalizations.of(context)!;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.documentType == null
                              ? t.uploadProfilePicture
                              : t.uploadDoc(widget.title),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t.tapToChoosePhoto,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: isLoading ? null : _pickPhoto,
                          child: Container(
                            width: double.infinity,
                            height: 220,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.divider,
                                width: 1.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: path == null
                                  ? _buildPlaceholder()
                                  : _buildPreview(path),
                            ),
                          ),
                        ),
                        if (widget.documentType == DocumentType.certification) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Certification Name *',
                              hintText: 'e.g. Plumbing Level 2',
                              filled: true,
                              fillColor: Colors.white,
                              floatingLabelStyle: const TextStyle(color: AppColors.primaryOrange),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.divider),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.divider),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.primaryOrange),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _issuedYearController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            decoration: InputDecoration(
                              labelText: 'Issued Year (optional)',
                              hintText: 'e.g. 2021',
                              counterText: '',
                              filled: true,
                              fillColor: Colors.white,
                              floatingLabelStyle: const TextStyle(color: AppColors.primaryOrange),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.divider),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.divider),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.primaryOrange),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                StepContinueButton(
                  onPressed: _onSavePressed,
                  isLoading: isLoading,
                  label: t.savePhoto,
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    final t = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.divider.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.primaryDark,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.tapToChoosePhoto,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.photoFormatLimit,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(String path) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(File(path), fit: BoxFit.cover),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.changePhoto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}