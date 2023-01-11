import 'package:flutter/material.dart';

import 'segmented_button.dart';

class BoxPainter extends CustomPainter {
  final int index;
  final int selectedIndex;
  final int childrenLength;
  final SegmentedTagsStyle style;

  bool get selected => index == selectedIndex;

  bool get isFirstOrLast => index == 0 || index == childrenLength - 1;

  Color? get backgroundColor => selected
      ? style.selectedBackgroundColor
      : style.unselectedBackgroundColor;

  Color? get borderColor =>
      selected ? style.selectedBorderColor : style.unselectedBorderColor;

  double? get borderRadius {
    if (style.borderRadius == 0) return null;
    return style.borderRadius;
  }

  const BoxPainter({
    required this.index,
    required this.selectedIndex,
    required this.childrenLength,
    this.style = const SegmentedTagsStyle(),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor ?? Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.borderWidth;

    final extraWidth = style.borderWidth * 1.3 / 3;

    final path = Path();

    void drawStraightLines() {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);

      if (index >= selectedIndex) {
        path.lineTo(size.width, size.height);
      } else {
        path.moveTo(size.width, size.height);
      }

      path.lineTo(0, size.height);
      path.moveTo(0, size.height);

      if (selected || index < selectedIndex) {
        path.lineTo(0, -extraWidth);
      }
    }

    void drawFirstItemWithBorderRadius() {
      final side = borderRadius! / 2;
      final radius = Radius.circular(side);

      path.moveTo(side, 0);
      path.lineTo(size.width, 0);

      if (index >= selectedIndex) {
        path.lineTo(size.width, size.height);
      } else {
        path.moveTo(size.width, size.height);
      }

      path.lineTo(side, size.height);

      path.arcToPoint(Offset(0, size.height - side), radius: radius);

      if (selected || index < selectedIndex) {
        path.lineTo(0, side);
        path.arcToPoint(Offset(side, 0), radius: radius);
      }
    }

    void drawLastItemWithBorderRadius() {
      final side = borderRadius! / 2;
      final radius = Radius.circular(side);

      path.moveTo(0, 0);
      path.lineTo(size.width - side, 0);

      path.arcToPoint(Offset(size.width, side), radius: radius);

      path.lineTo(size.width, size.height - side);

      path.arcToPoint(Offset(size.width - side, size.height), radius: radius);

      path.lineTo(0, size.height);

      if (selected || index < selectedIndex) {
        path.lineTo(0, -extraWidth);
      }
    }

    if (borderRadius == null || !isFirstOrLast) {
      drawStraightLines();
    } else {
      if (index == 0) drawFirstItemWithBorderRadius();
      if (index == childrenLength - 1) drawLastItemWithBorderRadius();
    }

    final rect = path.getBounds();
    final rectPaint = Paint()..color = backgroundColor ?? Colors.white;

    if (borderRadius == null || !isFirstOrLast) {
      canvas.drawRect(rect, rectPaint);
    } else {
      final side = borderRadius! / 2;
      final radius = Radius.circular(side);

      if (index == 0) {
        final rrect = RRect.fromRectAndCorners(
          rect,
          topLeft: radius,
          bottomLeft: radius,
        );
        canvas.drawRRect(rrect, rectPaint);
      } else {
        final rrect = RRect.fromRectAndCorners(
          rect,
          topRight: radius,
          bottomRight: radius,
        );
        canvas.drawRRect(rrect, rectPaint);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
