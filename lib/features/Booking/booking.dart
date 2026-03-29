import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gp/features/Booking/bookservice.dart';
import 'package:gp/core/theme/app_colors.dart';

class ServiceItem {
  final String name;
  final String price;
  const ServiceItem({required this.name, required this.price});
}

class SelectServiceScreen extends StatefulWidget {
  /// The professional's name passed in from ProfessionalDetailPage
  final String professionalName;
  final String professionalRole;
  final String professionalId;

  const SelectServiceScreen({
    super.key,
    required this.professionalName,
    required this.professionalRole,
    required this.professionalId,
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

  final List<ServiceItem> _services = const [
    ServiceItem(name: 'Pipe Installation', price: '30-40 JD'),
    ServiceItem(name: 'Leak Repairs', price: '25-35 JD'),
    ServiceItem(name: 'Water Heater Service', price: '40-60 JD'),
    ServiceItem(name: 'Drain Cleaning', price: '25-30 JD'),
    ServiceItem(name: 'Bathroom Fixtures', price: '35-50 JD'),
    ServiceItem(name: 'Other', price: 'TBD'),
  ];

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
          builder: (context) => BookServiceScreen(
            serviceName: _services[_selectedServiceIndex!].name,
            servicePrice: _services[_selectedServiceIndex!].price,
            description: _descriptionController.text.trim(),
            images: List.from(_pickedImages),
            workerName: widget.professionalName,
            workerRole: widget.professionalRole,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: darkBlue),
        title: const Text(
          'Book a Service',
          style: TextStyle(
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
                  _buildSelectServiceCard(),
                  const SizedBox(height: 16),
                  _buildDescriptionCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildContinueButton(),
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

  Widget _buildSelectServiceCard() {
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
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.settings, color: orange, size: 22),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Service',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: darkBlue,
                          ),
                        ),
                        Text(
                          'Choose the service you need',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
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
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Please select a service to continue.',
              style: TextStyle(color: errorRed, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
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
              const Row(
                children: [
                  Icon(Icons.edit, color: orange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Describe the service you need',
                    style: TextStyle(
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
                  hintText: 'Write a description...',
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
                  const Text(
                    'Upload picture',
                    style: TextStyle(color: darkBlue, fontSize: 14),
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
                      child: const Row(
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            color: orange,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Add',
                            style: TextStyle(
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
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Please add a description.',
              style: TextStyle(color: errorRed, fontSize: 12),
            ),
          ),
        if (_showPictureError)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 4),
            child: Text(
              'Please upload at least one picture.',
              style: TextStyle(color: errorRed, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildContinueButton() {
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
          child: const Text(
            'Continue',
            style: TextStyle(
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
