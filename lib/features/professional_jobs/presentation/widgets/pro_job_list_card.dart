import 'package:flutter/material.dart';
import '../../domain/entities/pro_job.dart';

class ProJobListCard extends StatelessWidget {
  final ProJob job;
  final VoidCallback onTap;

  const ProJobListCard({
    super.key,
    required this.job,
    required this.onTap,
  });

  Color get _statusColor {
    switch (job.status) {
      case ProJobStatus.pending:    return const Color(0xFFFF8C1A);
      case ProJobStatus.confirmed:  return const Color(0xFF2196F3);
      case ProJobStatus.onTheWay:   return const Color(0xFF9C27B0);
      case ProJobStatus.inProgress: return const Color(0xFF4CAF50);
      case ProJobStatus.completed:  return const Color(0xFF607D8B);
      case ProJobStatus.cancelled:  return const Color(0xFFF44336);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Row(
          children: [
            // Status bar on the left
            Container(
              width: 36,
              height: 80,
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: RotatedBox(
                quarterTurns: 3,
                child: Center(
                  child: Text(
                    job.status.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

            // Avatar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE0E8F0),
                backgroundImage: job.clientImageUrl.isNotEmpty
                    ? NetworkImage(job.clientImageUrl)
                    : null,
                child: job.clientImageUrl.isEmpty
                    ? const Icon(Icons.person,
                        color: Color(0xFF062B4D), size: 24)
                    : null,
              ),
            ),

            // Name + service
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.clientName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF062B4D),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    job.serviceType,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Date + price
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    job.formattedDate,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF062B4D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
