// lib/features/bookings/presentation/pages/select_service_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/professionals/domain/entities/service_offered.dart';
import 'package:gp/features/settings/presentation/bloc/address_bloc.dart';
import 'package:gp/injection_container.dart' as di;
import 'package:gp/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gp/features/bookings/presentation/pages/book_service_screen.dart';

class ServiceItem {
  final String name;
  final String price;
  const ServiceItem({required this.name, required this.price});
}

class SelectServiceScreen extends StatefulWidget {
  final String professionalName;
  final String professionalRole;
  final String professionalId;
  final List<ServiceOffered> services;

  const SelectServiceScreen({
    super.key,
    required this.professionalName,
    required this.professionalRole,
    required this.professionalId,
    required this.services,
  });

  @override
  State<SelectServiceScreen> createState() => _SelectServiceScreenState();
}

class _SelectServiceScreenState extends State<SelectServiceScreen> {
  int? _selectedServiceIndex;
  final TextEditingController _descriptionController = TextEditingController();
  final List<File> _pickedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _showServiceError = false;
  bool _showDescriptionError = false;
  bool _showPictureError = false;

  static const Color darkBlue = Color(0xFF1A3A52);
  static const Color orange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color lightGrey = Color(0xFFF5F5F5);

  late final List<ServiceItem> _services = widget.services
      .map((s) => ServiceItem(name: s.name, price: s.priceDisplay))
      .toList();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _pickedImages.add(File(image.path));
        _showPictureError = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _pickedImages.removeAt(index));
  }

  bool _validate() {
    setState(() {
      _showServiceError = _selectedServiceIndex == null;
      _showDescriptionError = _descriptionController.text.trim().isEmpty;
      _showPictureError = _pickedImages.isEmpty;
    });
    return !_showServiceError && !_showDescriptionError && !_showPictureError;
  }

  void _onContinue() {
    if (_validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => di.sl<AddressBloc>(),
            child: BookServiceScreen(
              serviceName: _services[_selectedServiceIndex!].name,
              servicePrice: _services[_selectedServiceIndex!].price,
              description: _descriptionController.text.trim(),
              images: List.from(_pickedImages),
              workerName: widget.professionalName,
              workerRole: widget.professionalRole,
              professionalId: widget.professionalId,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: darkBlue),
        title: Text(
          t.bookAService,
          style: const TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildProgressSteps(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildWorkerCard(),
                  const SizedBox(height: 16),
                  _buildSelectServiceCard(t),
                  const SizedBox(height: 16),
                  _buildDescriptionCard(t),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildContinueButton(t),
        ],
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: orange,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: darkBlue,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: darkBlue,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFE0E8F0),
            child: Icon(Icons.person, color: darkBlue, size: 30),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.professionalName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.professionalRole,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectServiceCard(AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: _showServiceError
                ? Border.all(color: errorRed, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.settings, color: orange, size: 22),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.selectServiceTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: darkBlue,
                          ),
                        ),
                        Text(
                          t.selectServiceSubtitle,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              if (_services.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'This professional has not listed any services yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                )
              else
              Column(
                children: List.generate(_services.length, (index) {
                  final service = _services[index];
                  final isSelected = _selectedServiceIndex == index;
                  final isLast = index == _services.length - 1;
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          _selectedServiceIndex = index;
                          _showServiceError = false;
                        }),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          color: isSelected
                              ? const Color(0xFFFFF3E0)
                              : Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                service.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected ? orange : darkBlue,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              Text(
                                service.price,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? orange : darkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast) const Divider(height: 1),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
        if (_showServiceError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              t.selectServiceToContinue,
              style: const TextStyle(color: errorRed, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDescriptionCard(AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: (_showDescriptionError || _showPictureError)
                ? Border.all(color: errorRed, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit, color: orange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    t.describeServiceNeeded,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: darkBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                onChanged: (_) {
                  if (_showDescriptionError) {
                    setState(() => _showDescriptionError = false);
                  }
                },
                decoration: InputDecoration(
                  hintText: t.writeDescription,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: _showDescriptionError
                      ? const Color(0xFFFFF3F3)
                      : const Color(0xFFF8F8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.upload_file, color: darkBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    t.uploadPicture,
                    style: const TextStyle(color: darkBlue, fontSize: 14),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        border: Border.all(color: orange),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add_photo_alternate,
                            color: orange,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t.add,
                            style: const TextStyle(
                              color: orange,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_pickedImages.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_pickedImages.length, (index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _pickedImages[index],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_pickedImages.length} picture${_pickedImages.length > 1 ? 's' : ''} attached',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        if (_showDescriptionError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              t.descriptionRequired,
              style: const TextStyle(color: errorRed, fontSize: 12),
            ),
          ),
        if (_showPictureError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              t.pictureRequired,
              style: const TextStyle(color: errorRed, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildContinueButton(AppLocalizations t) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            t.continue1,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
