import 'package:flutter/material.dart';

/// A plain white box meant to be placed inside a [Shimmer.fromColors] widget.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            shape == BoxShape.rectangle ? (borderRadius ?? BorderRadius.circular(6)) : null,
        shape: shape,
      ),
    );
  }
}
