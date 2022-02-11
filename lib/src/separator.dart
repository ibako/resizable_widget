import 'package:flutter/material.dart';

import 'separator_args_info.dart';
import 'separator_controller.dart';

class Separator extends StatefulWidget {
  final SeparatorArgsInfo info;

  const Separator(
    this.info, {
    Key? key,
  }) : super(key: key);

  @override
  _SeparatorState createState() => _SeparatorState();
}

class _SeparatorState extends State<Separator> {
  late SeparatorController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        SeparatorController(widget.info.index, widget.info.parentController);
  }

  @override
  Widget build(BuildContext context) => widget.info.separatorBuilder != null
      ? widget.info.separatorBuilder!(widget.info, _controller)
      : DefaultSeparator(info: widget.info, controller: _controller);
}

class DefaultSeparator extends StatelessWidget {
  final SeparatorArgsInfo info;
  final SeparatorController controller;

  const DefaultSeparator(
      {Key? key, required this.info, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MouseRegion(
        cursor: info.isHorizontalSeparator
            ? SystemMouseCursors.resizeRow
            : SystemMouseCursors.resizeColumn,
        child: SizedBox(
          child: Container(color: info.color),
          width: info.isHorizontalSeparator ? double.infinity : info.size,
          height: info.isHorizontalSeparator ? info.size : double.infinity,
        ),
      ),
      onPanDown: (details) => controller.onPanStart(details),
      onPanUpdate: (details) => controller.onPanUpdate(details, context),
      onPanEnd: (details) => controller.onPanEnd(details),
      onDoubleTap: () => controller.onDoubleTap(),
    );
  }
}
