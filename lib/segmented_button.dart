library segmented_button;

import 'package:flutter/material.dart' hide BoxPainter;
import 'package:segmented_button/layouts/children_controlled_layout.dart';

import 'box_painter.dart';
import 'layouts/device_controlled_layout.dart';

// idea: create a render-box for single child widgets instead of custom painter
// for the filled widget, because the job there will be done by just setting
// the size. Fir example size =  Size(200,0);

enum ButtonType { normal, filled }

class SegmentedButton<T> extends StatefulWidget {
  final List<T> tabs;
  final Widget Function(T tab, int index, bool selected) childBuilder;
  final void Function(T) onTap;
  final T? initialSelectedTab;
  final int? initialTabIndex;
  final SegmentedTagsStyle? style;
  final double height;

  final ButtonType type;

  const SegmentedButton({
    super.key,
    required this.tabs,
    required this.childBuilder,
    required this.onTap,
    this.initialSelectedTab,
    this.initialTabIndex,
    this.height = 40,
    this.style,
    this.type = ButtonType.filled,
  });

  int get initialIndex {
    if (initialTabIndex != null) return initialTabIndex!;
    return tabs.indexOf(initialSelectedTab ?? tabs.first);
  }

  bool get _isFilled => type == ButtonType.filled;

  @override
  State<SegmentedButton<T>> createState() => _SegmentedButtonState<T>();
}

class _SegmentedButtonState<T> extends State<SegmentedButton<T>> {
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedTabIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return widget._isFilled
        ? DeviceControlledLayout(
            delegate: DeviceControlledLayoutDelegate(
              widget.tabs,
              height: widget.height,
            ),
            children: buildChildren(),
          )
        : ChildrenControlledLayout(
            delegate: ChildrenControlledLayoutDelegate(
              widget.tabs,
              height: widget.height,
            ),
            children: buildChildren(),
          );
  }

  List<Widget> buildChildren() {
    return List.generate(
      widget.tabs.length,
      (index) {
        final tab = widget.tabs[index];
        return LayoutId(
          id: ValueKey(widget.tabs[index]),
          child: GestureDetector(
            onTap: () {
              selectedTabIndex = index;
              setState(() {});
              widget.onTap(tab);
            },
            child: CustomPaint(
              painter: BoxPainter(
                index: index,
                selectedIndex: selectedTabIndex,
                childrenLength: widget.tabs.length,
                style: widget.style ?? const SegmentedTagsStyle(),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: widget.style?.horizontalPadding ?? 15),
                child: Center(
                  child: widget.childBuilder(
                    tab,
                    index,
                    index == selectedTabIndex,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SegmentedTagsStyle {
  final double borderRadius;
  final double borderWidth, horizontalPadding;
  final Color? selectedBackgroundColor,
      unselectedBorderColor,
      selectedBorderColor,
      unselectedBackgroundColor;

  const SegmentedTagsStyle({
    this.borderRadius = 10,
    this.borderWidth = 1,
    this.horizontalPadding = 15,
    this.selectedBackgroundColor = const Color(0xffFFF8E7),
    this.unselectedBorderColor = const Color(0xffBAC7D5),
    this.selectedBorderColor = const Color(0xffFFB800),
    this.unselectedBackgroundColor = Colors.transparent,
  });
}
