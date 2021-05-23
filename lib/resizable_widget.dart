library resizable_widget;

import 'dart:async';
import 'package:flutter/material.dart';

/// Holds resizable widgets as children.
/// Users can resize inner widgets by dragging.
class ResizableWidget extends StatefulWidget {
  /// Resizable widget list.
  final List<Widget> children;

  /// When set to true, creates horizontal separators.
  final bool isColumnChildren;

  /// Separator size.
  final double separatorSize;

  /// Separator color.
  final Color separatorColor;

  /// Creates [ResizableWidget].
  const ResizableWidget({
    Key? key,
    required this.children,
    this.isColumnChildren = false,
    this.separatorSize = 4,
    this.separatorColor = Colors.white12,
  }) : super(key: key);

  @override
  _ResizableWidgetState createState() => _ResizableWidgetState();
}

class _ResizableWidgetState extends State<ResizableWidget> {
  late _ResizableWidgetController _controller;

  @override
  void initState() {
    super.initState();

    _controller = _ResizableWidgetController(
        widget.separatorSize, widget.isColumnChildren);
    final originalChildren = widget.children;
    final separatorNum = originalChildren.length - 1;
    for (var i = 0; i < separatorNum; i++) {
      _controller.children.add(_ResizableWidgetChildData(originalChildren[i]));
      _controller.children.add(_ResizableWidgetChildData(_Separator(
        2 * i + 1,
        _controller,
        isColumnSeparator: widget.isColumnChildren,
        size: widget.separatorSize,
        color: widget.separatorColor,
      )));
    }
    _controller.children.add(_ResizableWidgetChildData(
        originalChildren[originalChildren.length - 1]));
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
  _ResizableWidgetChildData(this.widget);
}

class _ResizableWidgetController {
  final eventStream = StreamController<Object>();
  final children = <_ResizableWidgetChildData>[];
  final double separatorSize;
  final bool isColumnChildren;
  double? maxSize;
  double? get maxSizeWithoutSeparators => maxSize == null
      ? null
      : maxSize! - (children.length ~/ 2) * separatorSize;

  _ResizableWidgetController(this.separatorSize, this.isColumnChildren);

  void setSizeIfNeeded(BoxConstraints constraints) {
    final max = isColumnChildren ? constraints.maxHeight : constraints.maxWidth;
    var isMaxSizeChanged = maxSize == null || maxSize! != max;
    if (!isMaxSizeChanged || children.isEmpty) {
      return;
    }

    maxSize = max;
    var remain = maxSizeWithoutSeparators!;

    if (children[0].size == null) {
      // initialization
      var count = children.length ~/ 2 + 1;
      for (var c in children) {
        if (c.widget is _Separator) {
          c.size = separatorSize;
          c.percentage = 0;
        } else {
          c.size = remain / count;
          c.percentage = c.size! / remain;
        }
      }
    } else {
      // when window size changed
      for (var c in children) {
        if (c.widget is! _Separator) {
          c.size = remain * c.percentage!;
        }
      }
    }
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
  }

  double _resizeImpl(int widgetIndex, Offset offset) {
    final size = children[widgetIndex].size ?? 0;
    children[widgetIndex].size =
        size + (isColumnChildren ? offset.dy : offset.dx);
    children[widgetIndex].percentage =
        children[widgetIndex].size! / maxSizeWithoutSeparators!;
    return children[widgetIndex].size!;
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
