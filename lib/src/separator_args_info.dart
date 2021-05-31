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
  final bool isDisabledSmartHide;
  final double size;
  final Color color;

  const SeparatorArgsBasicInfo(this.index, this.isHorizontalSeparator,
      this.isDisabledSmartHide, this.size, this.color);

  SeparatorArgsBasicInfo.clone(SeparatorArgsBasicInfo info)
      : index = info.index,
        isHorizontalSeparator = info.isHorizontalSeparator,
        isDisabledSmartHide = info.isDisabledSmartHide,
        size = info.size,
        color = info.color;
}
