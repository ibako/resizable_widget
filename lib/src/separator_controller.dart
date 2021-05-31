import 'package:flutter/material.dart';
import 'resizable_widget_controller.dart';

class SeparatorController {
  final int _index;
  final ResizableWidgetController _parentController;

  const SeparatorController(this._index, this._parentController);

  void onPanUpdate(DragUpdateDetails details, BuildContext context) {
    _parentController.resize(_index, details.delta);
  }

  void onDoubleTap() {
    _parentController.tryHideOrShow(_index);
  }
}
