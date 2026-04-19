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
  static const List<String> _availableServices = [
    'Pipe Installation',
    'Pipe Repair',
    'Leak Repairs',
    'Bathroom Fixtures',
    'Water Heater Service',
    'Drain Unclogging',
    'Faucet Repair',
  ];

  String? _selectedService;
  final TextEditingController _priceController = TextEditingController();
  bool _showServiceError = false;

  // Local list of confirmed services for this session
  final List<ServicePricing> _addedServices = [];

  @override
  void initState() {
    super.initState();
    // Pre-fill from BLoC state
    final state = context.read<BecomeProfessionalBloc>().state;
    if (state is BecomeProfessionalFormState && state.services.isNotEmpty) {
      _addedServices.addAll(state.services);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _addService() {
    if (_selectedService == null) return;
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) return;

    setState(() {
      // Remove existing entry for same service if present
      _addedServices.removeWhere((s) => s.serviceName == _selectedService);
      _addedServices.add(ServicePricing(
        serviceName: _selectedService!,
        price: price,
      ));
      _selectedService = null;
      _priceController.clear();
    });
  }

  void _removeService(String serviceName) {
    setState(() => _addedServices.removeWhere((s) => s.serviceName == serviceName));
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Services & Pricing',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF062B4D),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tap a service to select it, enter a price, then tap Add.',
          style: TextStyle(color: Color(0xFF062B4D), fontSize: 13),
        ),
        const SizedBox(height: 20),

        // Service grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _availableServices.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3.5,
          ),
          itemBuilder: (context, index) {
            final service = _availableServices[index];
            final isSelected = _selectedService == service;
            final isAdded = _addedServices.any((s) => s.serviceName == service);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedService = isSelected ? null : service;
                  _priceController.clear();
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isAdded
                      ? const Color(0xFFE8F5E9)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF062B4D)
                        : isAdded
                            ? Colors.green
                            : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isAdded)
                      const Icon(Icons.check_circle,
                          size: 14, color: Colors.green),
                    if (isAdded) const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        service,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isAdded
                              ? Colors.green.shade700
                              : const Color(0xFF062B4D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Price input row (shown when a service is selected)
        if (_selectedService != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedService!,
                    style: const TextStyle(color: Color(0xFF062B4D)),
                  ),
                ),
                SizedBox(
                  width: 70,
                  height: 40,
                  child: TextField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xffF4F6F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    'JD',
                    style: TextStyle(color: Color(0xFF062B4D), fontSize: 14),
                  ),
                ),
                GestureDetector(
                  onTap: _addService,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Added services list
        if (_addedServices.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Your Services',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF062B4D),
            ),
          ),
          const SizedBox(height: 8),
          ..._addedServices.map((s) => _AddedServiceTile(
                service: s,
                onRemove: () => _removeService(s.serviceName),
              )),
        ],

        if (_showServiceError)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 4),
            child: Text(
              'Please add at least one service.',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),

        const SizedBox(height: 20),

        // Continue button
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
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
    );
  }
}

class _AddedServiceTile extends StatelessWidget {
  final ServicePricing service;
  final VoidCallback onRemove;

  const _AddedServiceTile({required this.service, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              service.serviceName,
              style: const TextStyle(color: Color(0xFF062B4D)),
            ),
          ),
          Text(
            '${service.price.toStringAsFixed(0)} JD',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF062B4D),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
