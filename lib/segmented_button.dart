library segmented_button;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SegmentedButton<T> extends StatefulWidget {
  final List<T> tabs;
  final Widget Function(T tab, int index, bool selected) childBuilder;
  final void Function(T) onTap;
  final T? initialSelectedTab;
  final int? initialTabIndex;
  final SegmentedTagsStyle? style;
  final double height;

  const SegmentedButton({
    super.key,
    required this.tabs,
    required this.childBuilder,
    required this.onTap,
    this.initialSelectedTab,
    this.initialTabIndex,
    this.height = 40,
    this.style,
  });

  int get initialIndex {
    if (initialTabIndex != null) return initialTabIndex!;
    return tabs.indexOf(initialSelectedTab ?? tabs.first);
  }

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
    return SizedCustomMultiChildLayout(
        delegate: SegmentedButtonDelegate(
          widget.tabs,
          height: widget.height,
        ),
        children: List.generate(widget.tabs.length, (index) {
          final tab = widget.tabs[index];
          return LayoutId(
            id: ValueKey(widget.tabs[index]),
            child: GestureDetector(
              onTap: () {
                selectedTabIndex = index;
                setState(() {});
              },
              child: CustomPaint(
                  painter: BoxPainter(
                    index: index,
                    selectedIndex: selectedTabIndex,
                    childrenLength: widget.tabs.length,
                    style: widget.style ??
                        const SegmentedTagsStyle.withColoredBorders(),
                  ),
                  child: Container(
                    height: widget.height,
                    padding: EdgeInsets.symmetric(
                        horizontal: widget.style?.horizontalPadding ?? 15),
                    child: Center(
                      child: widget.childBuilder(
                        tab,
                        index,
                        index == selectedTabIndex,
                      ),
                    ),
                  )),
            ),
          );
        }));
  }
}

class SizedCustomMultiChildLayout extends MultiChildRenderObjectWidget {
  SizedCustomMultiChildLayout({
    super.key,
    required this.delegate,
    super.children,
  });

  /// The delegate that controls the layout of the children.
  final CustomMultiChildLayoutDelegate delegate;

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

class SegmentedButtonDelegate<T> extends CustomMultiChildLayoutDelegate {
  final List<T> tabs;
  final double height;
  SegmentedButtonDelegate(this.tabs, {required this.height});

  @override
  Size performLayout() {
    var buttonSize = Size.zero;
    var offset = Offset.zero;
    final constraints = BoxConstraints.tightFor(height: height);

    for (var tab in tabs) {
      if (hasChild(ValueKey(tab))) {
        final size = layoutChild(ValueKey(tab), constraints);
        positionChild(ValueKey(tab), offset);
        offset = Offset(offset.dx + size.width, offset.dy);
        buttonSize = Size(buttonSize.width + size.width, height);
      }
    }
    return buttonSize;
  }
}

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
    this.selectedBorderColor = const Color(0xffBAC7D5),
    this.unselectedBackgroundColor = Colors.transparent,
  });

  const SegmentedTagsStyle.withColoredBorders({
    this.borderRadius = 10,
    this.borderWidth = 1,
    this.horizontalPadding = 15,
    this.selectedBackgroundColor = const Color(0xffFFF8E7),
    this.unselectedBorderColor = const Color(0xffBAC7D5),
    this.selectedBorderColor = const Color(0xffFFB800),
    this.unselectedBackgroundColor = Colors.transparent,
  });
}

abstract class CustomMultiChildLayoutDelegate {
  /// Creates a layout delegate.
  ///
  /// The layout will update whenever [relayout] notifies its listeners.
  CustomMultiChildLayoutDelegate({Listenable? relayout}) : _relayout = relayout;

  final Listenable? _relayout;

  Map<Object, RenderBox>? _idToChild;
  Set<RenderBox>? _debugChildrenNeedingLayout;

  /// True if a non-null LayoutChild was provided for the specified id.
  ///
  /// Call this from the [performLayout] or [getSize] methods to
  /// determine which children are available, if the child list might
  /// vary.
  bool hasChild(Object childId) => _idToChild![childId] != null;

  /// Ask the child to update its layout within the limits specified by
  /// the constraints parameter. The child's size is returned.
  ///
  /// Call this from your [performLayout] function to lay out each
  /// child. Every child must be laid out using this function exactly
  /// once each time the [performLayout] function is called.
  Size layoutChild(Object childId, BoxConstraints constraints) {
    final RenderBox? child = _idToChild![childId];
    assert(() {
      if (child == null) {
        throw FlutterError(
          'The $this custom multichild layout delegate tried to lay out a non-existent child.\n'
          'There is no child with the id "$childId".',
        );
      }
      if (!_debugChildrenNeedingLayout!.remove(child)) {
        throw FlutterError(
          'The $this custom multichild layout delegate tried to lay out the child with id "$childId" more than once.\n'
          'Each child must be laid out exactly once.',
        );
      }
      try {
        assert(constraints.debugAssertIsValid(isAppliedConstraint: true));
      } on AssertionError catch (exception) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              'The $this custom multichild layout delegate provided invalid box constraints for the child with id "$childId".'),
          DiagnosticsProperty<AssertionError>('Exception', exception,
              showName: false),
          ErrorDescription(
            'The minimum width and height must be greater than or equal to zero.\n'
            'The maximum width must be greater than or equal to the minimum width.\n'
            'The maximum height must be greater than or equal to the minimum height.',
          ),
        ]);
      }
      return true;
    }());
    child!.layout(constraints, parentUsesSize: true);
    return child.size;
  }

  /// Specify the child's origin relative to this origin.
  ///
  /// Call this from your [performLayout] function to position each
  /// child. If you do not call this for a child, its position will
  /// remain unchanged. Children initially have their position set to
  /// (0,0), i.e. the top left of the [RenderCustomMultiChildLayoutBox].
  void positionChild(Object childId, Offset offset) {
    final child = _idToChild![childId];
    assert(() {
      if (child == null) {
        throw FlutterError(
          'The $this custom multichild layout delegate tried to position out a non-existent child:\n'
          'There is no child with the id "$childId".',
        );
      }
      return true;
    }());
    final childParentData = child!.parentData! as MultiChildLayoutParentData;
    childParentData.offset = offset;
  }

  DiagnosticsNode _debugDescribeChild(RenderBox child) {
    final childParentData = child.parentData! as MultiChildLayoutParentData;
    return DiagnosticsProperty<RenderBox>('${childParentData.id}', child);
  }

  Size _callPerformLayout(RenderBox? firstChild) {
    var buttonSize = Size.zero;
    // A particular layout delegate could be called reentrantly, e.g. if it used
    // by both a parent and a child. So, we must restore the _idToChild map when
    // we return.
    final Map<Object, RenderBox>? previousIdToChild = _idToChild;

    Set<RenderBox>? debugPreviousChildrenNeedingLayout;
    assert(() {
      debugPreviousChildrenNeedingLayout = _debugChildrenNeedingLayout;
      _debugChildrenNeedingLayout = <RenderBox>{};
      return true;
    }());

    try {
      _idToChild = <Object, RenderBox>{};
      RenderBox? child = firstChild;
      while (child != null) {
        final childParentData = child.parentData! as MultiChildLayoutParentData;
        assert(() {
          if (childParentData.id == null) {
            throw FlutterError.fromParts(<DiagnosticsNode>[
              ErrorSummary(
                  'Every child of a RenderCustomMultiChildLayoutBox must have an ID in its parent data.'),
              child!.describeForError('The following child has no ID'),
            ]);
          }
          return true;
        }());
        _idToChild![childParentData.id!] = child;
        assert(() {
          _debugChildrenNeedingLayout!.add(child!);
          return true;
        }());
        child = childParentData.nextSibling;
      }
      buttonSize = performLayout();
      assert(() {
        if (_debugChildrenNeedingLayout!.isNotEmpty) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('Each child must be laid out exactly once.'),
            DiagnosticsBlock(
              name: 'The $this custom multichild layout delegate forgot '
                  'to lay out the following '
                  '${_debugChildrenNeedingLayout!.length > 1 ? 'children' : 'child'}',
              properties: _debugChildrenNeedingLayout!
                  .map<DiagnosticsNode>(_debugDescribeChild)
                  .toList(),
            ),
          ]);
        }
        return true;
      }());
    } finally {
      _idToChild = previousIdToChild;
      assert(() {
        _debugChildrenNeedingLayout = debugPreviousChildrenNeedingLayout;
        return true;
      }());
    }

    return buttonSize;
  }

  /// Override this method to return the size of this object given the
  /// incoming constraints.
  ///
  /// The size cannot reflect the sizes of the children. If this layout has a
  /// fixed width or height the returned size can reflect that; the size will be
  /// constrained to the given constraints.
  ///
  /// By default, attempts to size the box to the biggest size
  /// possible given the constraints.
  //Size getSize(BoxConstraints constraints) => constraints.biggest;

  /// Override this method to lay out and position all children given this
  /// widget's size.
  ///
  /// This method must call [layoutChild] for each child. It should also specify
  /// the final position of each child with [positionChild].
  Size performLayout();

  /// Override this method to return true when the children need to be
  /// laid out.
  ///
  /// This should compare the fields of the current delegate and the given
  /// `oldDelegate` and return true if the fields are such that the layout would
  /// be different.
  bool shouldRelayout(covariant CustomMultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}

/// Defers the layout of multiple children to a delegate.
///
/// The delegate can determine the layout constraints for each child and can
/// decide where to position each child. The delegate can also determine the
/// size of the parent, but the size of the parent cannot depend on the sizes of
/// the children.
class RenderCustomMultiChildLayoutBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  /// Creates a render object that customizes the layout of multiple children.
  ///
  /// The [delegate] argument must not be null.
  RenderCustomMultiChildLayoutBox({
    List<RenderBox>? children,
    required CustomMultiChildLayoutDelegate delegate,
  }) : _delegate = delegate {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData) {
      child.parentData = MultiChildLayoutParentData();
    }
  }

  /// The delegate that controls the layout of the children.
  CustomMultiChildLayoutDelegate get delegate => _delegate;
  CustomMultiChildLayoutDelegate _delegate;

  set delegate(CustomMultiChildLayoutDelegate newDelegate) {
    if (_delegate == newDelegate) {
      return;
    }
    final oldDelegate = _delegate;
    if (newDelegate.runtimeType != oldDelegate.runtimeType ||
        newDelegate.shouldRelayout(oldDelegate)) {
      markNeedsLayout();
    }
    _delegate = newDelegate;
    if (attached) {
      oldDelegate._relayout?.removeListener(markNeedsLayout);
      newDelegate._relayout?.addListener(markNeedsLayout);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _delegate._relayout?.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _delegate._relayout?.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void performLayout() {
    // sets the size of the whole widget after laying out every widget
    size = delegate._callPerformLayout(firstChild);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
