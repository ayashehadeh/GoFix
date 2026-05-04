import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/professional_application.dart';
import '../bloc/become_professional_bloc.dart';
import '../bloc/become_professional_event.dart';
import '../bloc/become_professional_state.dart';

class ProfessionalDetails2Page extends StatefulWidget {
  final VoidCallback onContinue;
  const ProfessionalDetails2Page({super.key, required this.onContinue});

  @override
  State<ProfessionalDetails2Page> createState() =>
      _ProfessionalDetails2PageState();
}

class _ProfessionalDetails2PageState extends State<ProfessionalDetails2Page> {
  // All services fetched from API for this category
  List<_ServiceOption> _availableServices = [];

  // Services user has added with pricing
  final List<ServicePricing> _addedServices = [];

  // Currently selected service chip
  _ServiceOption? _selectedService;

  // Min/max price controllers
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();

  bool _showServiceError = false;
  bool _servicesLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill added services from BLoC
    final s = context.read<BecomeProfessionalBloc>().state;
    if (s is BecomeProfessionalFormState && s.services.isNotEmpty) {
      _addedServices.addAll(s.services);
    }
    // Use cached services if already loaded
    final bloc = context.read<BecomeProfessionalBloc>();
    if (bloc.cachedCategoryServices.isNotEmpty) {
      _availableServices = bloc.cachedCategoryServices
          .map((s) => _ServiceOption(id: s.serviceId ?? 0, name: s.name))
          .toList();
    }
  }

  @override
  void dispose() {
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  void _addService() {
    if (_selectedService == null) return;
    final min = double.tryParse(_minPriceCtrl.text.trim());
    if (min == null || min <= 0) return;
    final max = double.tryParse(_maxPriceCtrl.text.trim());

    setState(() {
      _addedServices.removeWhere((s) => s.serviceId == _selectedService!.id);
      _addedServices.add(ServicePricing(
        serviceId: _selectedService!.id,
        serviceName: _selectedService!.name,
        minPrice: min,
        maxPrice: max,
      ));
      _selectedService = null;
      _minPriceCtrl.clear();
      _maxPriceCtrl.clear();
    });
  }

  void _removeService(int serviceId) {
    setState(() => _addedServices.removeWhere((s) => s.serviceId == serviceId));
  }

  bool _validate() {
    setState(() => _showServiceError = _addedServices.isEmpty);
    return _addedServices.isNotEmpty;
  }

  void _onContinue() {
    if (_validate()) {
      context
          .read<BecomeProfessionalBloc>()
          .add(UpdateServices(List.from(_addedServices)));
      widget.onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BecomeProfessionalBloc, BecomeProfessionalState>(
      listener: (context, state) {
        if (state is CategoryServicesLoading) {
          setState(() => _servicesLoading = true);
        } else if (state is CategoryServicesLoaded) {
          setState(() {
            _servicesLoading = false;
            _availableServices = state.services
                .map((s) => _ServiceOption(id: s.serviceId ?? 0, name: s.name))
                .toList();
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Services & Pricing',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF062B4D)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap a service to select it, then set your price range.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Service chips ──────────────────────────────────────
                  if (_servicesLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                            color: Color(0xFF062B4D)),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableServices.map((svc) {
                        final isSelected = _selectedService?.id == svc.id;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedService = isSelected ? null : svc),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF062B4D)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF062B4D)
                                      : const Color(0xFFDDDDDD)),
                            ),
                            child: Text(
                              svc.name,
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF062B4D),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  // ── Price inputs (show only when service selected) ──────
                  if (_selectedService != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Set price for ${_selectedService!.name} (JD)',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF062B4D)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _PriceField(
                            controller: _minPriceCtrl,
                            hint: 'Min price',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PriceField(
                            controller: _maxPriceCtrl,
                            hint: 'Max (optional)',
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _addService,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8C1A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Add',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // ── Added services list ────────────────────────────────
                  if (_addedServices.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Your Services',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _showServiceError
                              ? Colors.red
                              : const Color(0xFF062B4D)),
                    ),
                    const SizedBox(height: 8),
                    ..._addedServices.map((s) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFDDDDDD)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(s.serviceName,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF062B4D))),
                              ),
                              Text(
                                s.maxPrice != null
                                    ? '${s.minPrice.toStringAsFixed(0)}-${s.maxPrice!.toStringAsFixed(0)} JD'
                                    : '${s.minPrice.toStringAsFixed(0)} JD',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF062B4D)),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _removeService(s.serviceId),
                                child: const Icon(Icons.close,
                                    size: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )),
                  ] else if (_showServiceError)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Please add at least one service.',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Continue
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
              child: const Text('Continue',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ServiceOption {
  final int id;
  final String name;
  _ServiceOption({required this.id, required this.name});
}

class _PriceField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _PriceField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 13, color: Color(0xFF062B4D)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
