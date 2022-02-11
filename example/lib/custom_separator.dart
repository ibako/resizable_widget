import 'package:flutter/material.dart';
import 'package:resizable_widget/resizable_widget.dart';

class DefaultSeparatorWidget extends StatelessWidget {
  final SeparatorArgsInfo info;
  final SeparatorController controller;

  const DefaultSeparatorWidget({
    Key? key,
    required this.info,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const Center(child: Text("Default behavior with custom widget")),
      DefaultSeparator(info: info, controller: controller),
    ]);
  }
}

class CustomSeparatorWidget extends StatefulWidget {
  final SeparatorArgsInfo info;
  final SeparatorController controller;

  const CustomSeparatorWidget({
    Key? key,
    required this.info,
    required this.controller,
  }) : super(key: key);

  @override
  State<CustomSeparatorWidget> createState() => _SeparatorWidgetState();
}

class _SeparatorWidgetState extends State<CustomSeparatorWidget> {
  refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: widget.info.size,
        child: Row(children: [
          Expanded(
              child: Container(
            height: widget.info.size,
            color: Colors.black,
            child: const Center(child: Text("Non draggable area")),
          )),
          Expanded(
              child: Container(
                  height: widget.info.size,
                  color: Colors.grey,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: const Center(child: Text("Draggable area")),
                    onPanDown: (details) =>
                        widget.controller.onPanStart(details),
                    onPanUpdate: (details) =>
                        widget.controller.onPanUpdate(details, context),
                    onPanEnd: (details) => widget.controller.onPanEnd(details),
                  )))
        ]));
  }
}
