import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/professionals/domain/entities/city.dart';
import 'package:gp/features/professionals/domain/entities/service_area.dart';
import '../bloc/become_professional_bloc.dart';
import '../bloc/become_professional_event.dart';
import '../bloc/become_professional_state.dart';

// ── Category → backend categoryId map ────────────────────────────────────────

const _categoryMap = {
  'Plumbing Services': 1,
  'Electrical Work': 2,
  'AC Repair': 3,
  'Carpentry': 4,
  'Painting': 5,
  'Cleaning': 6,
  'Moving Services': 7,
  'Appliance Repair': 8,
};

class ProfessionalDetails1Page extends StatefulWidget {
  final VoidCallback onContinue;
  const ProfessionalDetails1Page({super.key, required this.onContinue});

  @override
  State<ProfessionalDetails1Page> createState() =>
      _ProfessionalDetails1PageState();
}

class _ProfessionalDetails1PageState extends State<ProfessionalDetails1Page> {
  String? _selectedCategory;
  int?    _selectedExperienceYears;
  City?   _selectedCity;
  ServiceArea? _selectedArea;
  final   _bioController = TextEditingController();

  bool _catError  = false;
  bool _expError  = false;
  bool _cityError = false;
  bool _areaError = false;
  bool _bioError  = false;

  bool _citiesLoading = false;
  bool _areasLoading  = false;

  List<City>        _cities = [];
  List<ServiceArea> _areas  = [];

  @override
  void initState() {
    super.initState();
    final s = context.read<BecomeProfessionalBloc>().state;
    if (s is BecomeProfessionalFormState) {
      _selectedCategory =
          s.serviceCategory.isEmpty ? null : s.serviceCategory;
      _selectedExperienceYears =
          s.experienceLevel.isEmpty ? null : int.tryParse(s.experienceLevel);
      _bioController.text = s.workDescription;
    }
    // use cached if already loaded
    final bloc = context.read<BecomeProfessionalBloc>();
    if (bloc.cachedCities.isNotEmpty) {
      _cities = bloc.cachedCities;
    } else {
      bloc.add(LoadCities());
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _onCitySelected(City city) {
    setState(() {
      _selectedCity = city;
      _selectedArea = null;
      _cityError    = false;
      _areas        = [];
    });
    context.read<BecomeProfessionalBloc>().add(LoadAreas(city.id));
  }

  bool _validate() {
    setState(() {
      _catError  = _selectedCategory == null;
      _expError  = _selectedExperienceYears == null;
      _cityError = _selectedCity == null;
      _areaError = _selectedArea == null;
      _bioError  = _bioController.text.trim().isEmpty;
    });
    return !_catError && !_expError && !_cityError && !_areaError && !_bioError;
  }

  void _onContinue() {
    if (!_validate()) return;
    final categoryId = _categoryMap[_selectedCategory!] ?? 1;
    context.read<BecomeProfessionalBloc>().add(UpdateStep1(
          serviceCategory: _selectedCategory!,
          categoryId: categoryId,
          experienceLevel: _selectedExperienceYears!.toString(),
          workDescription: _bioController.text.trim(),
          cityId: _selectedCity!.id,
          serviceAreaId: _selectedArea!.id,
        ));
    // Load services for chosen category so step 2 has them ready
    context
        .read<BecomeProfessionalBloc>()
        .add(LoadServicesForCategory(categoryId));
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BecomeProfessionalBloc, BecomeProfessionalState>(
      listener: (context, state) {
        if (state is CitiesLoading) {
          setState(() => _citiesLoading = true);
        } else if (state is CitiesLoaded) {
          setState(() { _citiesLoading = false; _cities = state.cities; });
        } else if (state is AreasLoading) {
          setState(() => _areasLoading = true);
        } else if (state is AreasLoaded) {
          setState(() { _areasLoading = false; _areas = state.areas; });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Professional Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF062B4D),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormField(
                    label: 'Service category',
                    icon: Icons.work_outline,
                    hasError: _catError,
                    value: _selectedCategory,
                    onTap: () => _showPicker<String>(
                      context: context,
                      title: 'Service Category',
                      items: _categoryMap.keys.toList(),
                      labelOf: (e) => e,
                      selected: _selectedCategory,
                      onSelected: (v) =>
                          setState(() { _selectedCategory = v; _catError = false; }),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    label: 'Experience years',
                    icon: Icons.access_time_outlined,
                    hasError: _expError,
                    value: _selectedExperienceYears == null
                        ? null
                        : _selectedExperienceYears == 0
                            ? 'Less than a year'
                            : '$_selectedExperienceYears years',
                    onTap: () => _showPicker<int>(
                      context: context,
                      title: 'Experience Years',
                      items: List.generate(51, (i) => i),
                      labelOf: (e) => e == 0 ? 'Less than a year' : '$e years',
                      selected: _selectedExperienceYears,
                      onSelected: (v) =>
                          setState(() { _selectedExperienceYears = v; _expError = false; }),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    label: 'City',
                    icon: Icons.location_city_outlined,
                    hasError: _cityError,
                    value: _selectedCity?.name,
                    isLoading: _citiesLoading,
                    onTap: _citiesLoading
                        ? null
                        : () => _showPicker<City>(
                              context: context,
                              title: 'Select City',
                              items: _cities,
                              labelOf: (e) => e.name,
                              selected: _selectedCity,
                              onSelected: _onCitySelected,
                            ),
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    label: 'Area',
                    icon: Icons.map_outlined,
                    hasError: _areaError,
                    value: _selectedArea?.name,
                    enabled: _selectedCity != null,
                    isLoading: _areasLoading,
                    onTap: (_selectedCity == null || _areasLoading)
                        ? null
                        : () => _showPicker<ServiceArea>(
                              context: context,
                              title: 'Select Area',
                              items: _areas,
                              labelOf: (e) => e.name,
                              selected: _selectedArea,
                              onSelected: (v) =>
                                  setState(() { _selectedArea = v; _areaError = false; }),
                            ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Introduce Yourself',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _bioError ? Colors.red : const Color(0xFF062B4D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _bioError ? Colors.red : const Color(0xFFDDDDDD),
                      ),
                    ),
                    child: TextField(
                      controller: _bioController,
                      maxLines: 5,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF062B4D)),
                      decoration: const InputDecoration(
                        hintText: 'This will appear as your bio on your public profile.',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14),
                      ),
                      onChanged: (_) => setState(() => _bioError = false),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C1A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showPicker<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) labelOf,
    required T? selected,
    required ValueChanged<T> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF062B4D))),
          const Divider(),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: items.map((item) {
                final isSel = item == selected;
                return ListTile(
                  title: Text(labelOf(item),
                      style: TextStyle(
                          color: isSel
                              ? const Color(0xFFFF8C1A)
                              : const Color(0xFF062B4D),
                          fontWeight: isSel
                              ? FontWeight.w600
                              : FontWeight.normal)),
                  trailing: isSel
                      ? const Icon(Icons.check,
                          color: Color(0xFFFF8C1A), size: 18)
                      : null,
                  onTap: () {
                    onSelected(item);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Reusable field widget ─────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final bool hasError;
  final bool enabled;
  final bool isLoading;
  final VoidCallback? onTap;

  const _FormField({
    required this.label,
    required this.icon,
    required this.onTap,
    this.value,
    this.hasError = false,
    this.enabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: hasError ? Colors.red : const Color(0xFFDDDDDD)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color: hasError ? Colors.red : const Color(0xFF062B4D))),
            ),
            Container(
              width: 1, height: 20,
              color: const Color(0xFFDDDDDD),
              margin: const EdgeInsets.only(right: 12),
            ),
            Expanded(
              child: Text(
                value ?? '',
                style: TextStyle(
                    fontSize: 13,
                    color: enabled ? const Color(0xFF062B4D) : Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (isLoading)
              const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFF062B4D)),
              )
            else
              Icon(icon,
                  size: 20,
                  color: enabled ? const Color(0xFF062B4D) : Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
