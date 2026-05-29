import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/theme/app_text_styles.dart';
import 'package:gp/core/utils/snackbar_helper.dart';
import 'package:gp/features/settings/presentation/bloc/address_bloc.dart';
import 'package:gp/features/settings/presentation/widgets/address_form.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart';

class NewAddressScreen extends StatelessWidget {
  final double latitude;
  final double longitude;

  const NewAddressScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

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
                      Text(t.newAddress, style: AppTextStyles.heading2),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                SizedBox(
                  height: 140,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(latitude, longitude),
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
                            point: LatLng(latitude, longitude),
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
                          Navigator.pop(context);
                        }
                        if (state is AddressError) {
                          showErrorSnackbar(context, state.message);
                        }
                      },
                      builder: (context, state) {
                        return AddressForm(
                          latitude: latitude,
                          longitude: longitude,
                          onSave: (address) {
                            context
                                .read<AddressBloc>()
                                .add(AddAddressEvent(address));
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
