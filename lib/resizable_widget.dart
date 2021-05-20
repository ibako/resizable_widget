library resizable_widget;

import 'package:flutter/material.dart';

/// A Calculator.
class ResizableWidget extends StatefulWidget {
  /// Resizable widget list.
  final List<Widget> children;

  /// When set to true, creates a vertical separator.
  final bool isColumnChildren;

  /// Creates [ResizableWidget].
  ResizableWidget({
    Key? key,
    required this.children,
    this.isColumnChildren = false,
  }) : super(key: key);

  @override
  _ResizableState createState() => _ResizableState();
}

class _ResizableState extends State<ResizableWidget> {
  @override
  Widget build(BuildContext context) =>
      widget.isColumnChildren ? _buildColumn() : _buildRow();

  Widget _buildRow() =>
      Row(
        children: widget.children,
      );

  Widget _buildColumn() =>
      Column(
        children: widget.children,
      );
}