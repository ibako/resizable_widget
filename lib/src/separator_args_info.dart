import 'package:flutter/material.dart';
import 'resizable_widget_controller.dart';

class SeparatorArgsInfo extends SeparatorArgsBasicInfo {
  final ResizableWidgetController parentController;

  SeparatorArgsInfo(this.parentController, SeparatorArgsBasicInfo basicInfo)
      : super.clone(basicInfo);
}

class SeparatorArgsBasicInfo {
  final int index;
  final bool isHorizontalSeparator;
  final double size;
  final Color color;

  const SeparatorArgsBasicInfo(
      this.index, this.isHorizontalSeparator, this.size, this.color);

  SeparatorArgsBasicInfo.clone(SeparatorArgsBasicInfo info)
      : index = info.index,
        isHorizontalSeparator = info.isHorizontalSeparator,
        size = info.size,
        color = info.color;
}
