import 'package:flutter/material.dart';

class ResizableWidgetChildData {
  final Widget widget;
  double? size;
  double? percentage;
  double? defaultPercentage;
  double? hidingPercentage;
  double? maxPercentage;
  double? minPercentage;
  ResizableWidgetChildData(this.widget, this.percentage, this.maxPercentage, this.minPercentage);
}
