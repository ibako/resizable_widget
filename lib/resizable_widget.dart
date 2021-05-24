library resizable_widget;

import 'dart:async';
import 'package:flutter/material.dart';

typedef OnResizedFunc = void Function(List<WidgetSizeInfo> infoList);

/// Holds resizable widgets as children.
/// Users can resize the internal widgets by dragging.
class ResizableWidget extends StatefulWidget {
  /// Resizable widget list.
  final List<Widget> children;

  /// Sets the default [children] width or height as percentages.
  ///
  /// If you set this value,
  /// the length of [percentages] must match the one of [children],
  /// and the sum of [percentages] must be equal to 1.
  ///
  /// If this value is [null], [children] will be split into the same size.
  final List<double>? percentages;

  /// When set to true, creates horizontal separators.
  final bool isColumnChildren;

  /// Separator size.
  final double separatorSize;

  /// Separator color.
  final Color separatorColor;

  /// Callback of the resizing event.
  /// You can get the size and percentage of the internal widgets.
  ///
  /// Note that [onResized] is called every frame when resizing [children].
  final OnResizedFunc? onResized;

  /// Creates [ResizableWidget].
  ResizableWidget({
    Key? key,
    required this.children,
    this.percentages,
    this.isColumnChildren = false,
    this.separatorSize = 4,
    this.separatorColor = Colors.white12,
    this.onResized,
  }) : super(key: key) {
    assert(children.isNotEmpty);
    assert(percentages == null || percentages!.length == children.length);
    assert(percentages == null ||
        percentages!.reduce((value, element) => value + element) == 1);
  }

  @override
  _ResizableWidgetState createState() => _ResizableWidgetState();
}

/// Information about an internal widget size of [ResizableWidget].
class WidgetSizeInfo {
  /// The actual pixel size.
  ///
  /// If the app window size is changed, this value will be also changed.
  final double size;

  /// The size percentage among the [ResizableWidget] children.
  ///
  /// Even if the app window size is changed, this value will not be changed
  /// because the ratio of the internal widgets will be maintained.
  final double percentage;

  /// Creates [WidgetSizeInfo].
  const WidgetSizeInfo(this.size, this.percentage);
}

class _ResizableWidgetState extends State<ResizableWidget> {
  late _ResizableWidgetController _controller;

  @override
  void initState() {
    super.initState();

    _controller = _ResizableWidgetController(
        widget.separatorSize, widget.isColumnChildren, widget.onResized);
    final originalChildren = widget.children;
    final size = originalChildren.length;
    final originalPercentages =
        widget.percentages ?? List.filled(size, 1 / size);
    for (var i = 0; i < size - 1; i++) {
      _controller.children.add(_ResizableWidgetChildData(
          originalChildren[i], originalPercentages[i]));
      _controller.children.add(_ResizableWidgetChildData(
          _Separator(
            2 * i + 1,
            _controller,
            isColumnSeparator: widget.isColumnChildren,
            size: widget.separatorSize,
            color: widget.separatorColor,
          ),
          null));
    }
    _controller.children.add(_ResizableWidgetChildData(
        originalChildren[size - 1], originalPercentages[size - 1]));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          _controller.setSizeIfNeeded(constraints);
          return StreamBuilder(
            stream: _controller.eventStream.stream,
            builder: (context, snapshot) => _controller.isColumnChildren
                ? Column(
                    children: _controller.children.map(_buildChild).toList())
                : Row(children: _controller.children.map(_buildChild).toList()),
          );
        },
      );

  Widget _buildChild(_ResizableWidgetChildData child) {
    if (child.widget is _Separator) {
      return child.widget;
    }

    return SizedBox(
      width: widget.isColumnChildren ? double.infinity : child.size,
      height: widget.isColumnChildren ? child.size : double.infinity,
      child: child.widget,
    );
  }
}

class _ResizableWidgetChildData {
  final Widget widget;
  double? size;
  double? percentage;
  _ResizableWidgetChildData(this.widget, this.percentage);
}

class _ResizableWidgetController {
  final eventStream = StreamController<Object>();
  final children = <_ResizableWidgetChildData>[];
  final double separatorSize;
  final bool isColumnChildren;
  final OnResizedFunc? onResized;
  double? maxSize;
  double? get maxSizeWithoutSeparators => maxSize == null
      ? null
      : maxSize! - (children.length ~/ 2) * separatorSize;

  _ResizableWidgetController(
      this.separatorSize, this.isColumnChildren, this.onResized);

  void setSizeIfNeeded(BoxConstraints constraints) {
    final max = isColumnChildren ? constraints.maxHeight : constraints.maxWidth;
    var isMaxSizeChanged = maxSize == null || maxSize! != max;
    if (!isMaxSizeChanged || children.isEmpty) {
      return;
    }

    maxSize = max;
    final remain = maxSizeWithoutSeparators!;

    for (var c in children) {
      if (c.widget is _Separator) {
        c.percentage = 0;
        c.size = separatorSize;
      } else {
        c.size = remain * c.percentage!;
      }
    }

    _callOnResized();
  }

  void resize(int separatorIndex, Offset offset) {
    final leftSize = _resizeImpl(separatorIndex - 1, offset);
    final rightSize = _resizeImpl(separatorIndex + 1, offset * (-1));

    if (leftSize < 0) {
      _resizeImpl(separatorIndex - 1,
          isColumnChildren ? Offset(0, -leftSize) : Offset(-leftSize, 0));
      _resizeImpl(separatorIndex + 1,
          isColumnChildren ? Offset(0, leftSize) : Offset(leftSize, 0));
    }
    if (rightSize < 0) {
      _resizeImpl(separatorIndex - 1,
          isColumnChildren ? Offset(0, rightSize) : Offset(rightSize, 0));
      _resizeImpl(separatorIndex + 1,
          isColumnChildren ? Offset(0, -rightSize) : Offset(-rightSize, 0));
    }

    eventStream.add(this);
    _callOnResized();
  }

  double _resizeImpl(int widgetIndex, Offset offset) {
    final size = children[widgetIndex].size ?? 0;
    children[widgetIndex].size =
        size + (isColumnChildren ? offset.dy : offset.dx);
    children[widgetIndex].percentage =
        children[widgetIndex].size! / maxSizeWithoutSeparators!;
    return children[widgetIndex].size!;
  }

  void _callOnResized() {
    onResized?.call(children
        .where((x) => x.widget is! _Separator)
        .map((x) => WidgetSizeInfo(x.size!, x.percentage!))
        .toList());
  }
}

class _Separator extends StatefulWidget {
  final int _index;
  final _ResizableWidgetController _parentController;
  final bool isColumnSeparator;
  final double size;
  final Color color;

  const _Separator(
    this._index,
    this._parentController, {
    Key? key,
    required this.isColumnSeparator,
    required this.size,
    required this.color,
  }) : super(key: key);

  @override
  _SeparatorState createState() => _SeparatorState();
}

class _SeparatorState extends State<_Separator> {
  late _SeparatorController _controller;

  @override
  void initState() {
    super.initState();

    _controller = _SeparatorController(widget._index, widget._parentController);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        child: MouseRegion(
          cursor: widget.isColumnSeparator
              ? SystemMouseCursors.resizeRow
              : SystemMouseCursors.resizeColumn,
          child: SizedBox(
            child: Container(color: widget.color),
            width: widget.isColumnSeparator ? double.infinity : widget.size,
            height: widget.isColumnSeparator ? widget.size : double.infinity,
          ),
        ),
        onPanUpdate: (details) => _controller.onPanUpdate(details, context),
      );
}

class _SeparatorController {
  final int _index;
  final _ResizableWidgetController _parentController;

  const _SeparatorController(this._index, this._parentController);

  void onPanUpdate(DragUpdateDetails details, BuildContext context) {
    _parentController.resize(_index, details.delta);
  }
}
