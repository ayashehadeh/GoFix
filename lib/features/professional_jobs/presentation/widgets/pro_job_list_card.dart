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

  ({Color bg, Color text}) get _chipColors {
    switch (job.status) {
      case ProJobStatus.pending:    return (bg: const Color(0xFFF5EFEB), text: const Color(0xFF795548));
      case ProJobStatus.confirmed:  return (bg: const Color(0xFFE8F0F8), text: const Color(0xFF1A3A5C));
      case ProJobStatus.onTheWay:   return (bg: const Color(0xFFFFF3E8), text: const Color(0xFFE87722));
      case ProJobStatus.arrived:    return (bg: const Color(0xFFE8F0F8), text: const Color(0xFF1A3A5C));
      case ProJobStatus.inProgress: return (bg: const Color(0xFFFFF3E8), text: const Color(0xFFE87722));
      case ProJobStatus.completed:  return (bg: const Color(0xFFE8F0F8), text: const Color(0xFF1A3A5C));
      case ProJobStatus.cancelled:  return (bg: const Color(0xFFF0F0F0), text: const Color(0xFF757575));
    }
  }

  @override
  Widget build(BuildContext context) {
    final chip = _chipColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: const Border(left: BorderSide(color: Color(0xFF012249), width: 3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE0E8F0),
                backgroundImage: job.clientImageUrl.isNotEmpty
                    ? NetworkImage(job.clientImageUrl)
                    : null,
                child: job.clientImageUrl.isEmpty
                    ? const Icon(Icons.person, color: Color(0xFF062B4D), size: 24)
                    : null,
              ),
            ),

            // Name + service + status
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: chip.bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        job.status.label,
                        style: TextStyle(
                          color: chip.text,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
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
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
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
