import 'package:flutter/material.dart';
import 'resizable_widget_controller.dart';
import 'separator_controller.dart';

class Separator extends StatefulWidget {
  final int _index;
  final ResizableWidgetController _parentController;
  final bool isColumnSeparator;
  final double size;
  final Color color;

  const Separator(
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

class _SeparatorState extends State<Separator> {
  late SeparatorController _controller;

  @override
  void initState() {
    super.initState();

    _controller = SeparatorController(widget._index, widget._parentController);
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
