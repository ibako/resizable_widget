import 'dart:async';
import 'package:flutter/material.dart';
import 'resizable_widget_args_info.dart';
import 'resizable_widget_child_data.dart';
import 'resizable_widget_model.dart';
import 'separator.dart';
import 'separator_args_info.dart';

class ResizableWidgetController {
  final eventStream = StreamController<Object>();
  final ResizableWidgetModel _model;
  List<ResizableWidgetChildData> get children => _model.children;

  ResizableWidgetController(ResizableWidgetArgsInfo info) : _model = ResizableWidgetModel(info) {
    _model.init(_separatorFactory);
  }

  void setSizeIfNeeded(BoxConstraints constraints) {
    _model.setSizeIfNeeded(constraints);
    _model.callOnResized();
  }

  void resizeStart(int separatorIndex, DragDownDetails details) {
    _model.resizeStart(separatorIndex, details);
    eventStream.add(this);
    _model.callResizedBegin(separatorIndex, details);
  }

  void resize(int separatorIndex, Offset offset) {
    _model.resize(separatorIndex, offset);

    eventStream.add(this);
    _model.callOnResized();
  }

  void resizeEnd(int separatorIndex, DragEndDetails details) {
    _model.resizeEnd(separatorIndex, details);
    eventStream.add(this);
    _model.callResizedEnd(separatorIndex, details);
  }

  void tryHideOrShow(int separatorIndex) {
    final result = _model.tryHideOrShow(separatorIndex);

    if (result) {
      eventStream.add(this);
      _model.callOnResized();
    }
  }

  Widget _separatorFactory(SeparatorArgsBasicInfo basicInfo) {
    return Separator(SeparatorArgsInfo(this, basicInfo));
  }
}
