// lib/features/bookings/presentation/pages/book_details_screen.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/bookings/presentation/pages/booking_success_screen.dart';
import 'package:gp/injection_container.dart' as di;
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/l10n/service_name_l10n.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';
import '../bloc/bookings_state.dart';

class BookDetailsScreen extends StatefulWidget {
  final String serviceName;
  final String? serviceNameAr;
  final String servicePrice;
  final String description;
  final List<File> images;
  final String date;
  final String time;
  final String address;
  final double? latitude;
  final double? longitude;
  final String workerName;
  final String professionalId;
  final DateTime scheduledDate;

  const BookDetailsScreen({
    super.key,
    required this.serviceName,
    this.serviceNameAr,
    required this.servicePrice,
    required this.description,
    required this.images,
    required this.date,
    required this.time,
    required this.address,
    this.latitude,
    this.longitude,
    required this.workerName,
    required this.professionalId,
    required this.scheduledDate,
  });

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  static const Color darkBlue = Color(0xFF1A2B4A);
  static const Color orange = Color(0xFFFF8C00);
  static const Color lightGrey = Color(0xFFF5F5F5);

  bool _isUploading = false;

  Future<void> _submitBooking(BuildContext context) async {
    setState(() => _isUploading = true);

    List<String> imageUrls = [];

    try {
      if (widget.images.isNotEmpty) {
        final dio = di.sl<Dio>();
        final formData = FormData();
        for (final file in widget.images) {
          final fileName = file.path.split('/').last;
          formData.files.add(MapEntry(
            'files',
            await MultipartFile.fromFile(file.path, filename: fileName),
          ));
        }
        final response = await dio.post(
          '/bookings/images',
          data: formData,
        );
        final data = response.data['data'] as List;
        imageUrls = data.cast<String>();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload images. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isUploading = false);
      return;
    }

    if (!mounted) return;
    context.read<BookingsBloc>().add(
          CreateBookingEvent(
            professionalId: widget.professionalId,
            serviceName: widget.serviceName,
            serviceNameAr: widget.serviceNameAr,
            servicePrice: widget.servicePrice,
            scheduledDate: widget.scheduledDate,
            scheduledTime: widget.time,
            address: widget.address,
            latitude: widget.latitude,
            longitude: widget.longitude,
            description: widget.description,
            imageUrls: imageUrls,
          ),
        );

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingsBloc, BookingsState>(
      listener: (context, state) {
        if (state is BookingActionSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const BookingSuccessScreen(),
            ),
          );
        }
        if (state is BookingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = _isUploading || state is BookingActionLoading;

        return Scaffold(
          backgroundColor: lightGrey,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const BackButton(color: darkBlue),
            title: Text(
              AppLocalizations.of(context)!.bookingDetails,
              style: const TextStyle(
                color: darkBlue,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Booking Details Card
                      Container(
                        width: double.infinity,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.bookingDetails,
                              style: const TextStyle(
                                color: darkBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              icon: Icons.settings,
                              text: localizeServiceName(widget.serviceName, AppLocalizations.of(context)!),
                            ),
                            _buildDetailRow(
                              icon: Icons.calendar_month,
                              text: widget.date,
                            ),
                            _buildDetailRow(
                              icon: Icons.access_time,
                              text: widget.time,
                            ),
                            _buildDetailRow(
                              icon: Icons.map_outlined,
                              text: widget.address,
                            ),
                            _buildDetailRow(
                              icon: Icons.attach_money,
                              text: widget.servicePrice,
                            ),
                            _buildDetailRow(
                              icon: Icons.person,
                              text: widget.workerName,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Service Description Card
                      Container(
                        width: double.infinity,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.edit, color: orange, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.serviceDescription,
                                  style: const TextStyle(
                                    color: darkBlue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.description,
                              style: const TextStyle(
                                color: Color(0xFF4A4A4A),
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                            if (widget.images.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.image, color: darkBlue, size: 22),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${widget.images.length} ${widget.images.length == 1 ? AppLocalizations.of(context)!.pictureAttachedSingular : AppLocalizations.of(context)!.picturesAttachedPlural}',
                                    style: const TextStyle(
                                      color: darkBlue,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: widget.images.map((file) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      file,
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Send Booking Request Button
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _submitBooking(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: orange.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.sendBookingRequest,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: orange, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(color: darkBlue, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }
}
