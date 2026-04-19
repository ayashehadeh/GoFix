import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/become_professional_bloc.dart';
import '../bloc/become_professional_event.dart';
import '../bloc/become_professional_state.dart';

class ProfessionalDetails1Page extends StatefulWidget {
  final VoidCallback onContinue;

  const ProfessionalDetails1Page({super.key, required this.onContinue});

  @override
  State<ProfessionalDetails1Page> createState() =>
      _ProfessionalDetails1PageState();
}

class _ProfessionalDetails1PageState extends State<ProfessionalDetails1Page> {
  String? _selectedCategory;
  String? _selectedExperience;
  final TextEditingController _descriptionController = TextEditingController();

  bool _showCategoryError = false;
  bool _showExperienceError = false;
  bool _showDescriptionError = false;

  static const List<String> _categories = [
    'Plumbing Services',
    'Electrical Work',
    'AC Repair',
    'Carpentry',
    'Painting',
    'Cleaning',
    'Moving Services',
    'Appliance Repair',
  ];

  static const List<String> _experienceOptions = [
    'Less than a year',
    'One year',
    'More than Two years',
    'Five years or more',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill from BLoC state if user navigated back
    final state = context.read<BecomeProfessionalBloc>().state;
    if (state is BecomeProfessionalFormState) {
      _selectedCategory =
          state.serviceCategory.isEmpty ? null : state.serviceCategory;
      _selectedExperience =
          state.experienceLevel.isEmpty ? null : state.experienceLevel;
      _descriptionController.text = state.workDescription;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _showCategoryError = _selectedCategory == null;
      _showExperienceError = _selectedExperience == null;
      _showDescriptionError = _descriptionController.text.trim().isEmpty;
    });
    return !_showCategoryError &&
        !_showExperienceError &&
        !_showDescriptionError;
  }

  void _onContinue() {
    if (_validate()) {
      context.read<BecomeProfessionalBloc>().add(UpdateStep1(
            serviceCategory: _selectedCategory!,
            experienceLevel: _selectedExperience!,
            workDescription: _descriptionController.text.trim(),
          ));
      widget.onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          const Text(
            'Ready to go pro?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF062B4D),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Professional Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF062B4D),
            ),
          ),
          const SizedBox(height: 20),

          // Category dropdown
          const Text(
            'Service category',
            style: TextStyle(fontSize: 16, color: Color(0xFF062B4D)),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: _showCategoryError
                  ? const Color(0xFFFFF3F3)
                  : Colors.grey.shade300,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: _showCategoryError
                    ? const BorderSide(color: Colors.red, width: 1.5)
                    : BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: _showCategoryError
                    ? const BorderSide(color: Colors.red, width: 1.5)
                    : BorderSide.none,
              ),
            ),
            icon: const Icon(Icons.work_outline, color: Color(0xFF062B4D)),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) => setState(() {
              _selectedCategory = value;
              _showCategoryError = false;
            }),
            hint: const Text(
              'Select a category',
              style: TextStyle(fontSize: 15, color: Color(0xFF062B4D)),
            ),
          ),
          if (_showCategoryError)
            const Padding(
              padding: EdgeInsets.only(top: 4, left: 4),
              child: Text('Please select a category',
                  style: TextStyle(fontSize: 12, color: Colors.red)),
            ),
          const SizedBox(height: 25),
          const Divider(),
          const SizedBox(height: 10),

          // Experience radio
          const Text(
            'Experience years',
            style: TextStyle(fontSize: 16, color: Color(0xFF062B4D)),
          ),
          const SizedBox(height: 10),
          ..._experienceOptions.map(
            (exp) => RadioListTile<String>(
              title: Text(exp),
              value: exp,
              groupValue: _selectedExperience,
              activeColor: const Color(0xFF062B4D),
              onChanged: (value) => setState(() {
                _selectedExperience = value;
                _showExperienceError = false;
              }),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (_showExperienceError)
            const Padding(
              padding: EdgeInsets.only(top: 4, left: 4),
              child: Text('Please select your experience level',
                  style: TextStyle(fontSize: 12, color: Colors.red)),
            ),
          const Divider(),
          const SizedBox(height: 15),

          // Work description
          const Text(
            'Work description',
            style: TextStyle(fontSize: 16, color: Color(0xFF062B4D)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            onChanged: (_) {
              if (_showDescriptionError) {
                setState(() => _showDescriptionError = false);
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: _showDescriptionError
                  ? const Color(0xFFFFF3F3)
                  : Colors.grey.shade300,
              suffixIcon: const Icon(
                Icons.description_outlined,
                color: Color(0xFF062B4D),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: _showDescriptionError
                    ? const BorderSide(color: Colors.red, width: 1.5)
                    : BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: _showDescriptionError
                    ? const BorderSide(color: Colors.red, width: 1.5)
                    : BorderSide.none,
              ),
              hintText: 'Describe your professional experience...',
            ),
          ),
          if (_showDescriptionError)
            const Padding(
              padding: EdgeInsets.only(top: 4, left: 4),
              child: Text('Please add a description',
                  style: TextStyle(fontSize: 12, color: Colors.red)),
            ),
          const SizedBox(height: 40),

          // Continue button
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
              onPressed: _onContinue,
              child: const Text(
                'Continue',
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
  }
}
