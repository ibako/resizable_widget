library resizable_widget;

import 'dart:async';
import 'package:flutter/material.dart';

/// Holds resizable widgets as children.
/// Users can resize inner widgets by dragging.
class ResizableWidget extends StatefulWidget {
  /// Resizable widget list.
  final List<Widget> children;

  /// When set to true, creates vertical separators.
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
  final children = <_ResizableWidgetChild>[];
  late _ResizableWidgetController _controller;

  @override
  void initState() {
    super.initState();

    _controller = _ResizableWidgetController(this);
    final originalChildren = widget.children;
    final separatorNum = originalChildren.length - 1;
    for (var i = 0; i < separatorNum; i++) {
      children.add(_ResizableWidgetChild(originalChildren[i]));
      children.add(_ResizableWidgetChild(
          _Separator(
            2 * i + 1,
            _controller,
            isColumnSeparator: widget.isColumnChildren,
            size: widget.separatorSize,
            color: widget.separatorColor,
          )
      ));
    }
    children.add(_ResizableWidgetChild(
        originalChildren[originalChildren.length - 1]));
  }

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(
        builder: (context, constraints) {
          _setSizeIfNeeded(constraints);
          return StreamBuilder(
              stream: _controller.eventStream.stream,
              builder: (context, snapshot) => widget.isColumnChildren
                  ? Column(children: children.map(_buildChild).toList())
                  : Row(children: children.map(_buildChild).toList()),
          );
        },
      );

  void _setSizeIfNeeded(BoxConstraints constraints) {
    final maxSize = widget.isColumnChildren
        ? constraints.maxHeight : constraints.maxWidth;
    var isWindowSizeChanged = _controller.maxSize == null ||
        _controller.maxSize! != maxSize;
    if (!isWindowSizeChanged || children.isEmpty) {
      return;
    }

    _controller.maxSize = maxSize;
    var remain = _controller.maxSizeWithoutSeparators!;

    if (children[0].size == null) {
      // initialization
      var count = children.length ~/ 2 + 1;
      for (var c in children) {
        if (c.widget is _Separator) {
          c.size = widget.separatorSize;
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

  Widget _buildChild(_ResizableWidgetChild child) {
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

class _ResizableWidgetChild {
  final Widget widget;
  double? size;
  double? percentage;
  _ResizableWidgetChild(this.widget);
}

class _ResizableWidgetController {
  final _ResizableWidgetState _state;
  final eventStream = StreamController<Object>();
  double? maxSize;
  double? get maxSizeWithoutSeparators => maxSize == null
      ? null : maxSize! - (_state.children.length ~/ 2) * _state.widget.separatorSize;

  _ResizableWidgetController(this._state);

  void resize(int separatorIndex, Offset offset) {
    final leftSize = _resizeImpl(separatorIndex - 1, offset);
    final rightSize = _resizeImpl(separatorIndex + 1, offset * (-1));

    if (leftSize < 0) {
      _resizeImpl(separatorIndex - 1, _state.widget.isColumnChildren
          ? Offset(0, -leftSize) : Offset(-leftSize, 0));
      _resizeImpl(separatorIndex + 1, _state.widget.isColumnChildren
          ? Offset(0, leftSize) : Offset(leftSize, 0));
    }
    if (rightSize < 0) {
      _resizeImpl(separatorIndex - 1, _state.widget.isColumnChildren
          ? Offset(0, rightSize) : Offset(rightSize, 0));
      _resizeImpl(separatorIndex + 1, _state.widget.isColumnChildren
          ? Offset(0, -rightSize) : Offset(-rightSize, 0));
    }

    eventStream.add(this);
  }

  double _resizeImpl(int widgetIndex, Offset offset) {
    final size = _state.children[widgetIndex].size ?? 0;
    _state.children[widgetIndex].size = size +
        (_state.widget.isColumnChildren ? offset.dy : offset.dx);
    _state.children[widgetIndex].percentage =
        _state.children[widgetIndex].size! / maxSizeWithoutSeparators!;
    return _state.children[widgetIndex].size!;
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
  Widget build(BuildContext context) =>
      GestureDetector(
        child: MouseRegion(
          cursor: widget.isColumnSeparator
              ? SystemMouseCursors.resizeRow : SystemMouseCursors.resizeColumn,
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
