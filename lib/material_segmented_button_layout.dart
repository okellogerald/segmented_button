import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MaterialSegmentedButtonLayout extends MultiChildRenderObjectWidget {
  final MaterialSegementedButtonDelegate delegate;

  MaterialSegmentedButtonLayout({
    required this.delegate,
    required super.children,
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomMultiChildLayoutBox(delegate: delegate);
  }
}

class MaterialSegementedButtonDelegate<T> extends MultiChildLayoutDelegate {
  final List<T> tabs;
  final List<Key> keys;
  final double height;

  MaterialSegementedButtonDelegate({
    required this.height,
    required this.keys,
    required this.tabs,
  });

  @override
  Size getSize(BoxConstraints constraints) {
    print(constraints);
    return Size(constraints.maxWidth, height);
  }

  @override
  void performLayout(Size size) {
    print(size);
    var offset = Offset.zero;
    final constraints = BoxConstraints.tightFor(height: height);

    for (var i = 0; i < tabs.length; i++) {
      final key = keys[i];
      if (hasChild(key)) {
        final size = layoutChild(key, constraints);
        positionChild(key, offset);
        offset = Offset(offset.dx + size.width, offset.dy);
      }
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}
