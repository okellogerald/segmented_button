import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DeviceControlledLayout extends MultiChildRenderObjectWidget {
  DeviceControlledLayout({
    super.key,
    required this.delegate,
    super.children,
  });

  /// The delegate that controls the layout of the children.
  final MultiChildLayoutDelegate delegate;

  @override
  RenderCustomMultiChildLayoutBox createRenderObject(BuildContext context) {
    return RenderCustomMultiChildLayoutBox(delegate: delegate);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderCustomMultiChildLayoutBox renderObject) {
    renderObject.delegate = delegate;
  }
}

class DeviceControlledLayoutDelegate<T> extends MultiChildLayoutDelegate {
  final List<T> tabs;
  final double height;
  DeviceControlledLayoutDelegate(this.tabs, {required this.height});

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, height);
  }

  @override
  void performLayout(Size size) {
    final childSize = Size(size.width / tabs.length, size.height);
    var offset = Offset.zero;
    final constraints = BoxConstraints.tightFor(height: height);

    for (var tab in tabs) {
      if (hasChild(ValueKey(tab))) {
        layoutChild(ValueKey(tab), constraints);
        positionChild(ValueKey(tab), offset);
        offset = Offset(offset.dx + childSize.width, offset.dy);
      }
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}
