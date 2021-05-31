import 'package:flutter/material.dart';

class ResizableWidgetChildData {
  final Widget widget;
  double? size;
  double? percentage;
  double? defaultSize;
  double? hidingSize;
  ResizableWidgetChildData(this.widget, this.percentage);
}
