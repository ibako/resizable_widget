library resizable_widget;

import 'package:flutter/material.dart';

/// A Calculator.
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
  List<Widget> composedChildren = [];

  @override
  void initState() {
    super.initState();

    final children = widget.children;
    final separatorNum = children.length - 1;
    for (var i = 0; i < separatorNum; i++) {
      composedChildren.add(children[i]);
      composedChildren.add(
          _Separator(
            isColumnSeparator: widget.isColumnChildren,
            size: widget.separatorSize,
            color: widget.separatorColor,
          )
      );
    }
    composedChildren.add(children[children.length - 1]);
  }

  @override
  Widget build(BuildContext context) =>
      widget.isColumnChildren ? _buildColumn() : _buildRow();

  Widget _buildRow() =>
      Row(
        children: composedChildren,
      );

  Widget _buildColumn() =>
      Column(
        children: composedChildren,
      );
}

class _ResizableWidgetController {

}

class _Separator extends StatefulWidget {
  final bool isColumnSeparator;
  final double size;
  final Color color;

  const _Separator({
    Key? key,
    required this.isColumnSeparator,
    required this.size,
    required this.color,
  }) : super(key: key);

  @override
  _SeparatorState createState() => _SeparatorState();
}

class _SeparatorState extends State<_Separator> {
  @override
  Widget build(BuildContext context) =>
      SizedBox(
        child: Container(color: widget.color),
        width: widget.isColumnSeparator ? double.infinity : widget.size,
        height: widget.isColumnSeparator ? widget.size : double.infinity,
      );
}
