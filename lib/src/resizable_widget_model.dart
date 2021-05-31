import 'package:flutter/material.dart';
import 'resizable_widget_args_info.dart';
import 'resizable_widget_child_data.dart';
import 'separator.dart';
import 'separator_args_info.dart';
import 'widget_size_info.dart';

typedef SeparatorFactory = Widget Function(SeparatorArgsBasicInfo basicInfo);

class ResizableWidgetModel {
  final ResizableWidgetArgsInfo _info;
  final children = <ResizableWidgetChildData>[];
  double? maxSize;
  double? get maxSizeWithoutSeparators => maxSize == null
      ? null
      : maxSize! - (children.length ~/ 2) * _info.separatorSize;

  ResizableWidgetModel(this._info);

  void init(SeparatorFactory separatorFactory) {
    final originalChildren = _info.children;
    final size = originalChildren.length;
    final originalPercentages =
        _info.percentages ?? List.filled(size, 1 / size);
    for (var i = 0; i < size - 1; i++) {
      children.add(ResizableWidgetChildData(
          originalChildren[i], originalPercentages[i]));
      children.add(ResizableWidgetChildData(
          separatorFactory.call(SeparatorArgsBasicInfo(
            2 * i + 1,
            _info.isHorizontalSeparator,
            _info.separatorSize,
            _info.separatorColor,
          )),
          null));
    }
    children.add(ResizableWidgetChildData(
        originalChildren[size - 1], originalPercentages[size - 1]));
  }

  void setSizeIfNeeded(BoxConstraints constraints) {
    final max = _info.isHorizontalSeparator
        ? constraints.maxHeight
        : constraints.maxWidth;
    var isMaxSizeChanged = maxSize == null || maxSize! != max;
    if (!isMaxSizeChanged || children.isEmpty) {
      return;
    }

    maxSize = max;
    final remain = maxSizeWithoutSeparators!;

    for (var c in children) {
      if (c.widget is Separator) {
        c.percentage = 0;
        c.size = _info.separatorSize;
      } else {
        c.size = remain * c.percentage!;
      }
    }
  }

  void resize(int separatorIndex, Offset offset) {
    final leftSize = _resizeImpl(separatorIndex - 1, offset);
    final rightSize = _resizeImpl(separatorIndex + 1, offset * (-1));

    if (leftSize < 0) {
      _resizeImpl(
          separatorIndex - 1,
          _info.isHorizontalSeparator
              ? Offset(0, -leftSize)
              : Offset(-leftSize, 0));
      _resizeImpl(
          separatorIndex + 1,
          _info.isHorizontalSeparator
              ? Offset(0, leftSize)
              : Offset(leftSize, 0));
    }
    if (rightSize < 0) {
      _resizeImpl(
          separatorIndex - 1,
          _info.isHorizontalSeparator
              ? Offset(0, rightSize)
              : Offset(rightSize, 0));
      _resizeImpl(
          separatorIndex + 1,
          _info.isHorizontalSeparator
              ? Offset(0, -rightSize)
              : Offset(-rightSize, 0));
    }
  }

  void callOnResized() {
    _info.onResized?.call(children
        .where((x) => x.widget is! Separator)
        .map((x) => WidgetSizeInfo(x.size!, x.percentage!))
        .toList());
  }

  double _resizeImpl(int widgetIndex, Offset offset) {
    final size = children[widgetIndex].size ?? 0;
    children[widgetIndex].size =
        size + (_info.isHorizontalSeparator ? offset.dy : offset.dx);
    children[widgetIndex].percentage =
        children[widgetIndex].size! / maxSizeWithoutSeparators!;
    return children[widgetIndex].size!;
  }
}
