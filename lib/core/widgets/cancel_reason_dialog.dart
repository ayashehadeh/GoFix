import 'package:flutter/material.dart';

Future<void> showCancelReasonDialog(
  BuildContext context, {
  required void Function(String reason) onConfirm,
}) async {
  final reasonController = TextEditingController();
  final reason = await showDialog<String>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (dialogCtx) => Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cancel Job',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF062B4D),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please provide a reason for cancellation.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: reasonController,
              maxLines: 3,
              autofocus: true,
              style: const TextStyle(fontSize: 14, color: Color(0xFF062B4D)),
              decoration: InputDecoration(
                hintText: 'Reason for cancellation...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFFF8C1A), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF062B4D), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          color: Color(0xFF062B4D),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogCtx, reasonController.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C1A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  if (reason != null && reason.isNotEmpty && context.mounted) {
    onConfirm(reason);
  }
}
