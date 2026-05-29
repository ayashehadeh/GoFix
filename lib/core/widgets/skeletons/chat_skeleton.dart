import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer skeleton for the chat loading state — alternating message bubbles.
/// Each bubble container lives outside the shimmer so it stays white;
/// the bubble shape inside is grey against it.
class ChatSkeleton extends StatelessWidget {
  const ChatSkeleton({super.key});

  static const _bubbles = [
    _BubbleSpec(width: 180, isMe: false),
    _BubbleSpec(width: 140, isMe: true),
    _BubbleSpec(width: 220, isMe: false),
    _BubbleSpec(width: 100, isMe: true),
    _BubbleSpec(width: 200, isMe: false),
    _BubbleSpec(width: 160, isMe: true),
    _BubbleSpec(width: 120, isMe: false),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _bubbles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _BubbleSkeleton(spec: _bubbles[i]),
    );
  }
}

class _BubbleSpec {
  final double width;
  final bool isMe;
  const _BubbleSpec({required this.width, required this.isMe});
}

class _BubbleSkeleton extends StatelessWidget {
  final _BubbleSpec spec;
  const _BubbleSkeleton({required this.spec});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: spec.isMe ? const Radius.circular(16) : const Radius.circular(4),
      bottomRight: spec.isMe ? const Radius.circular(4) : const Radius.circular(16),
    );

    return Align(
      alignment: spec.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        // White bubble outside shimmer
        width: spec.width,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(color: Colors.white, width: spec.width, height: 38),
          ),
        ),
      ),
    );
  }
}
