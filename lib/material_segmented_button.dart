library segmented_button;

import 'package:flutter/material.dart' hide BoxPainter;
import 'package:segmented_button/layout.dart';
import 'package:segmented_button/material_segmented_button_layout.dart';

import 'box_painter.dart';
import 'style.dart';

// idea: create a render-box for single child widgets instead of custom painter
// for the filled widget, because the job there will be done by just setting
// the size. Fir example size =  Size(200,0);

class MaterialSegmentedButton<T> extends StatefulWidget {
  final List<T> tabs;
  final Widget Function(T tab, int index, bool selected) childBuilder;
  final void Function(T) onTap;
  final T? initialSelectedTab;
  final int? initialTabIndex;
  final SegmentedTagsStyle? style;
  final double height;
  final bool expandedToFillWidth;

  const MaterialSegmentedButton({
    super.key,
    required this.tabs,
    required this.childBuilder,
    required this.onTap,
    this.initialSelectedTab,
    this.initialTabIndex,
    this.height = 40,
    this.style,
    this.expandedToFillWidth = false,
  });

  int get initialIndex {
    if (initialTabIndex != null) return initialTabIndex!;
    return tabs.indexOf(initialSelectedTab ?? tabs.first);
  }

  List<Key> get keys {
    return [for (int i = 0; i < tabs.length; i++) ValueKey(i)];
  }

  @override
  State<MaterialSegmentedButton<T>> createState() =>
      _MaterialSegmentedButtonState<T>();
}

class _MaterialSegmentedButtonState<T>
    extends State<MaterialSegmentedButton<T>> {
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedTabIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.expandedToFillWidth) {
      return LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
            width: constraints.maxWidth,
            child: MaterialSegmentedButtonLayout(
              delegate: MaterialSegementedButtonDelegate(
                tabs: widget.tabs,
                keys: widget.keys,
                height: widget.height,
              ),
              children: buildChildren(),
            ));
      });
    }
    return ChildrenControlledLayout(
      delegate: ChildrenControlledLayoutDelegate(
        tabs: widget.tabs,
        keys: widget.keys,
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
          id: widget.keys[index],
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

  List<Widget> buildExpandedChildren() {
   return List.generate(
      widget.tabs.length,
      (index) {
        final tab = widget.tabs[index];
        return LayoutId(
          id: widget.keys[index],
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
