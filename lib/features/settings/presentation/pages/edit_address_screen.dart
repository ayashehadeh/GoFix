import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/theme/app_text_styles.dart';
import 'package:gp/features/settings/domain/entities/address_entity.dart';
import 'package:gp/features/settings/presentation/bloc/address_bloc.dart';
import 'package:gp/features/settings/presentation/widgets/address_form.dart';
import 'package:gp/core/utils/snackbar_helper.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart';

class EditAddressScreen extends StatelessWidget {
  final AddressEntity address;

  const EditAddressScreen({super.key, required this.address});

  void _confirmDelete(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          t.deleteAddress,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          t.deleteAddressConfirm,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AddressBloc>().add(DeleteAddressEvent(address.id));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(t.delete, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left,
                            color: Colors.black, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(t.editAddress, style: AppTextStyles.heading2),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _confirmDelete(context),
                        child: Text(
                          t.deleteAddress,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                SizedBox(
                  height: 140,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter:
                          LatLng(address.latitude, address.longitude),
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.gp',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(address.latitude, address.longitude),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: BlocConsumer<AddressBloc, AddressState>(
                      listener: (context, state) {
                        if (state is AddressActionSuccess) {
                          Navigator.pop(context);
                        }
                        if (state is AddressError) {
                          showErrorSnackbar(context, state.message);
                        }
                      },
                      builder: (context, state) {
                        return AddressForm(
                          latitude: address.latitude,
                          longitude: address.longitude,
                          existing: address,
                          onSave: (updated) {
                            context
                                .read<AddressBloc>()
                                .add(UpdateAddressEvent(updated));
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
