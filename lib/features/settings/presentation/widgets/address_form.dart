import 'package:flutter/material.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/theme/app_text_styles.dart';
import 'package:gp/features/settings/domain/entities/address_entity.dart';

class AddressForm extends StatefulWidget {
  final double latitude;
  final double longitude;
  final AddressEntity? existing;
  final void Function(AddressEntity address) onSave;

  const AddressForm({
    super.key,
    required this.latitude,
    required this.longitude,
    this.existing,
    required this.onSave,
  });

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  AddressType _type = AddressType.apartment;

  final _areaCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _aptNumberCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _houseCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _directionsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _type = e.type;
      _areaCtrl.text = e.area;
      _buildingCtrl.text = e.buildingName ?? '';
      _aptNumberCtrl.text = e.apartmentNumber ?? '';
      _floorCtrl.text = e.floor ?? '';
      _houseCtrl.text = e.house ?? '';
      _streetCtrl.text = e.street;
      _directionsCtrl.text = e.additionalDirections ?? '';
    }
  }

  @override
  void dispose() {
    _areaCtrl.dispose();
    _buildingCtrl.dispose();
    _aptNumberCtrl.dispose();
    _floorCtrl.dispose();
    _houseCtrl.dispose();
    _streetCtrl.dispose();
    _directionsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final address = AddressEntity(
        id: widget.existing?.id ?? '',
        type: _type,
        area: _areaCtrl.text.trim(),
        street: _streetCtrl.text.trim(),
        buildingName: _buildingCtrl.text.trim().isEmpty
            ? null
            : _buildingCtrl.text.trim(),
        apartmentNumber: _aptNumberCtrl.text.trim().isEmpty
            ? null
            : _aptNumberCtrl.text.trim(),
        floor: _floorCtrl.text.trim().isEmpty ? null : _floorCtrl.text.trim(),
        house: _houseCtrl.text.trim().isEmpty ? null : _houseCtrl.text.trim(),
        additionalDirections: _directionsCtrl.text.trim().isEmpty
            ? null
            : _directionsCtrl.text.trim(),
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
      widget.onSave(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TypeButton(
                label: 'Apartment',
                selected: _type == AddressType.apartment,
                onTap: () => setState(() => _type = AddressType.apartment),
              ),
              const SizedBox(width: 12),
              _TypeButton(
                label: 'House',
                selected: _type == AddressType.house,
                onTap: () => setState(() => _type = AddressType.house),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _FormField(label: 'Area', controller: _areaCtrl, required: true),
          const SizedBox(height: 12),
          if (_type == AddressType.apartment) ...[
            _FormField(label: 'Building name', controller: _buildingCtrl),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _FormField(
                      label: 'Apartment number', controller: _aptNumberCtrl),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: _FormField(label: 'Floor', controller: _floorCtrl),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (_type == AddressType.house) ...[
            _FormField(label: 'House', controller: _houseCtrl),
            const SizedBox(height: 12),
          ],
          _FormField(label: 'Street', controller: _streetCtrl, required: true),
          const SizedBox(height: 12),
          _FormField(
              label: 'Additional directions', controller: _directionsCtrl),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                'Save Address',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryOrange : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.primaryOrange : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool required;

  const _FormField({
    required this.label,
    required this.controller,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: AppTextStyles.bodyMedium,
      validator: required
          ? (val) => val == null || val.isEmpty ? 'Required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primaryOrange, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
