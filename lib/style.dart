import 'package:flutter/material.dart';

class SegmentedTagsStyle {
  final double borderRadius;
  final double borderWidth, horizontalPadding;
  final Color? selectedBackgroundColor,
      unselectedBorderColor,
      selectedBorderColor,
      unselectedBackgroundColor;

  const SegmentedTagsStyle({
    this.borderRadius = 40,
    this.borderWidth = 1,
    this.horizontalPadding = 15,
    this.selectedBackgroundColor = const Color(0xff2B3467),
    this.unselectedBorderColor = const Color(0xffBAC7D5),
    this.selectedBorderColor = const Color(0xff2B3467),
    this.unselectedBackgroundColor = Colors.transparent,
  });
}
