// lib/features/bookings/presentation/pages/book_details_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/bookings/presentation/pages/booking_success_screen.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';

class BookDetailsScreen extends StatelessWidget {
  final String serviceName;
  final String servicePrice;
  final String description;
  final List<File> images;
  final String date;
  final String time;
  final String address;
  final String workerName;
  final String professionalId;
  final DateTime scheduledDate;

  const BookDetailsScreen({
    super.key,
    required this.serviceName,
    required this.servicePrice,
    required this.description,
    required this.images,
    required this.date,
    required this.time,
    required this.address,
    required this.workerName,
    required this.professionalId,
    required this.scheduledDate,
  });

  static const Color darkBlue = Color(0xFF1A2B4A);
  static const Color orange = Color(0xFFFF8C00);
  static const Color lightGrey = Color(0xFFF5F5F5);

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
          // Step 3 active
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
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
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),

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
                        const Text(
                          'Booking Details',
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.settings,
                          text: serviceName,
                        ),
                        _buildDetailRow(
                          icon: Icons.calendar_month,
                          text: date,
                        ),
                        _buildDetailRow(
                          icon: Icons.access_time,
                          text: time,
                        ),
                        _buildDetailRow(
                          icon: Icons.map_outlined,
                          text: address,
                        ),
                        _buildDetailRow(
                          icon: Icons.attach_money,
                          text: servicePrice,
                        ),
                        _buildDetailRow(
                          icon: Icons.person,
                          text: workerName,
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
                        const Row(
                          children: [
                            Icon(Icons.edit, color: orange, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Service Description',
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Color(0xFF4A4A4A),
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                        if (images.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.image,
                                color: darkBlue,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${images.length} picture${images.length > 1 ? 's' : ''} attached',
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
                            children: images.map((file) {
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
                onPressed: () {
                  context.read<BookingsBloc>().add(
                        CreateBookingEvent(
                          professionalId: professionalId,
                          serviceName: serviceName,
                          servicePrice: servicePrice,
                          scheduledDate: scheduledDate,
                          scheduledTime: time,
                          address: address,
                          description: description,
                          imageUrls: const [], // images are local Files, not uploaded URLs yet
                        ),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Send Booking Request',
                  style: TextStyle(
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
