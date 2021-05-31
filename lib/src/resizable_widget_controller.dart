import 'dart:async';
import 'package:flutter/material.dart';
import 'resizable_widget.dart';
import 'resizable_widget_child_data.dart';
import 'separator.dart';
import 'widget_size_info.dart';

class ResizableWidgetController {
  final eventStream = StreamController<Object>();
  final children = <ResizableWidgetChildData>[];
  final double separatorSize;
  final bool isColumnChildren;
  final OnResizedFunc? onResized;
  double? maxSize;
  double? get maxSizeWithoutSeparators => maxSize == null
      ? null
      : maxSize! - (children.length ~/ 2) * separatorSize;

  ResizableWidgetController(
      this.separatorSize, this.isColumnChildren, this.onResized);

  void setSizeIfNeeded(BoxConstraints constraints) {
    final max = isColumnChildren ? constraints.maxHeight : constraints.maxWidth;
    var isMaxSizeChanged = maxSize == null || maxSize! != max;
    if (!isMaxSizeChanged || children.isEmpty) {
      return;
    }

    maxSize = max;
    final remain = maxSizeWithoutSeparators!;

    for (var c in children) {
      if (c.widget is Separator) {
        c.percentage = 0;
        c.size = separatorSize;
      } else {
        c.size = remain * c.percentage!;
      }
    }

    _callOnResized();
  }

  void resize(int separatorIndex, Offset offset) {
    final leftSize = _resizeImpl(separatorIndex - 1, offset);
    final rightSize = _resizeImpl(separatorIndex + 1, offset * (-1));

    if (leftSize < 0) {
      _resizeImpl(separatorIndex - 1,
          isColumnChildren ? Offset(0, -leftSize) : Offset(-leftSize, 0));
      _resizeImpl(separatorIndex + 1,
          isColumnChildren ? Offset(0, leftSize) : Offset(leftSize, 0));
    }
    if (rightSize < 0) {
      _resizeImpl(separatorIndex - 1,
          isColumnChildren ? Offset(0, rightSize) : Offset(rightSize, 0));
      _resizeImpl(separatorIndex + 1,
          isColumnChildren ? Offset(0, -rightSize) : Offset(-rightSize, 0));
    }

    eventStream.add(this);
    _callOnResized();
  }

  double _resizeImpl(int widgetIndex, Offset offset) {
    final size = children[widgetIndex].size ?? 0;
    children[widgetIndex].size =
        size + (isColumnChildren ? offset.dy : offset.dx);
    children[widgetIndex].percentage =
        children[widgetIndex].size! / maxSizeWithoutSeparators!;
    return children[widgetIndex].size!;
  }

  void _callOnResized() {
    onResized?.call(children
        .where((x) => x.widget is! Separator)
        .map((x) => WidgetSizeInfo(x.size!, x.percentage!))
        .toList());
  }
}
