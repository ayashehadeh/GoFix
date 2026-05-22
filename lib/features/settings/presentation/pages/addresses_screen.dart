import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/theme/app_text_styles.dart';
import 'package:gp/features/settings/domain/entities/address_entity.dart';
import 'package:gp/features/settings/presentation/bloc/address_bloc.dart';
import 'package:gp/features/settings/presentation/pages/confirm_location_screen.dart';
import 'package:gp/features/settings/presentation/pages/edit_address_screen.dart';
import 'package:gp/l10n/app_localizations.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(const GetAddressesEvent());
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left,
                          color: Colors.black, size: 28),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const Spacer(),
                    Text(t.addresses, style: AppTextStyles.heading2),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<AddressBloc>(),
                            child: const ConfirmLocationScreen(),
                          ),
                        ),
                      ),
                      child: Text(
                        t.add,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Expanded(
                  child: BlocConsumer<AddressBloc, AddressState>(
                    listener: (context, state) {
                      if (state is AddressError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message)),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is AddressLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primaryOrange),
                        );
                      }

                      List<AddressEntity> addresses = [];
                      if (state is AddressLoaded) {
                        addresses = state.addresses;
                      } else if (state is AddressActionSuccess) {
                        addresses = state.addresses;
                      }

                      if (addresses.isEmpty) {
                        return Center(
                          child: Text(
                            t.noAddressesYet,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall,
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: addresses.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          return _AddressTile(
                            address: address,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<AddressBloc>(),
                                  child: EditAddressScreen(address: address),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
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

class _AddressTile extends StatelessWidget {
  final AddressEntity address;
  final VoidCallback onTap;

  const _AddressTile({required this.address, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.map_outlined,
                  color: AppColors.primaryOrange, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address.displayTitle, style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 2),
                  Text(address.displaySubtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
