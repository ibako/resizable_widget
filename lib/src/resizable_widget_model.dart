import 'package:flutter/material.dart';
import 'resizable_widget_args_info.dart';
import 'resizable_widget_child_data.dart';
import 'separator.dart';
import 'separator_args_info.dart';
import 'widget_size_info.dart';

typedef SeparatorFactory = Widget Function(SeparatorArgsBasicInfo basicInfo);

enum ResizableWidgetResizeImplReturnState {
  VALID,
  INVALID
}

class ResizableWidgetResizeImplReturn {
  ResizableWidgetResizeImplReturnState state;
  double size;
  double percent;
  ResizableWidgetResizeImplReturn({required this.size, required this.percent, required this.state});
}

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
    final maxPercentages = _info.maxPercentages;
    final minPercentages = _info.minPercentages;
    for (var i = 0; i < size - 1; i++) {
      children.add(ResizableWidgetChildData(
          originalChildren[i], originalPercentages[i],
          (maxPercentages != null ? maxPercentages[i] : null),
          (minPercentages != null ? minPercentages[i] : null)
      ));
      children.add(ResizableWidgetChildData(
          separatorFactory.call(SeparatorArgsBasicInfo(
            2 * i + 1,
            _info.isHorizontalSeparator,
            _info.isDisabledSmartHide,
            _info.separatorSize,
            _info.separatorColor,
          )),
          null,
          null,
          null,
          ));
    }
    children.add(ResizableWidgetChildData(
        originalChildren[size - 1], originalPercentages[size - 1], 
          (maxPercentages != null ? maxPercentages[size - 1] : null),
          (minPercentages != null ? minPercentages[size - 1] : null)
    ));
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
        c.defaultPercentage = c.percentage;
      }
    }
  }

  void resize(int separatorIndex, Offset offset) {
    ResizableWidgetResizeImplReturn leftReturn  = _resizeImpl(separatorIndex - 1, offset, apply: false);
    if(leftReturn.state != ResizableWidgetResizeImplReturnState.VALID) {
       return;
    }

    ResizableWidgetResizeImplReturn rightReturn = _resizeImpl(separatorIndex + 1, offset * (-1), apply: false);
    if(rightReturn.state != ResizableWidgetResizeImplReturnState.VALID) {
       return;
    }
    __applyResizeImpl(separatorIndex - 1, leftReturn);
    __applyResizeImpl(separatorIndex + 1, rightReturn);


    if (leftReturn.size < 0) {
      _resizeImpl(
          separatorIndex - 1,
          _info.isHorizontalSeparator
              ? Offset(0, -leftReturn.size)
              : Offset(-leftReturn.size, 0));
      _resizeImpl(
          separatorIndex + 1,
          _info.isHorizontalSeparator
              ? Offset(0, leftReturn.size)
              : Offset(leftReturn.size, 0));
    }
    if (rightReturn.size < 0) {
      _resizeImpl(
          separatorIndex - 1,
          _info.isHorizontalSeparator
              ? Offset(0, rightReturn.size)
              : Offset(rightReturn.size, 0));
      _resizeImpl(
          separatorIndex + 1,
          _info.isHorizontalSeparator
              ? Offset(0, -rightReturn.size)
              : Offset(-rightReturn.size, 0));
    }
  }


  void callOnResized() {
    _info.onResized?.call(children
        .where((x) => x.widget is! Separator)
        .map((x) => WidgetSizeInfo(x.size!, x.percentage!))
        .toList());
  }

  bool tryHideOrShow(int separatorIndex) {
    if (_info.isDisabledSmartHide) {
      return false;
    }

    final isLeft = separatorIndex == 1;
    final isRight = separatorIndex == children.length - 2;
    if (!isLeft && !isRight) {
      // valid only for both ends.
      return false;
    }

    final target = children[isLeft ? 0 : children.length - 1];
    final size = target.size!;
    final coefficient = isLeft ? 1 : -1;
    if (_isNearlyZero(size)) {
      // show
      final offsetScala =
          maxSize! * (target.hidingPercentage ?? target.defaultPercentage!) -
              size;
      final offset = _info.isHorizontalSeparator
          ? Offset(0, offsetScala * coefficient)
          : Offset(offsetScala * coefficient, 0);
      resize(separatorIndex, offset);
    } else {
      // hide
      target.hidingPercentage = target.percentage!;
      final offsetScala = maxSize! * target.hidingPercentage!;
      final offset = _info.isHorizontalSeparator
          ? Offset(0, -offsetScala * coefficient)
          : Offset(-offsetScala * coefficient, 0);
      resize(separatorIndex, offset);
    }

    return true;
  }


  ResizableWidgetResizeImplReturn _resizeImpl(int widgetIndex, Offset offset, {bool apply = true}) {
    final size              = children[widgetIndex].size ?? 0;
    final appliedSize       = size + (_info.isHorizontalSeparator ? offset.dy : offset.dx);
    final appliedPercentage = size / maxSizeWithoutSeparators!;


    /// Check if transformation will exceed the requested Min / Max value for the specific row / column
    if(
      (
        (children[widgetIndex].minPercentage != null) &&
        (children[widgetIndex].minPercentage! > appliedPercentage)  &&
        (
          ((_info.isHorizontalSeparator == false) && (offset.dx < 0)) ||
          ((_info.isHorizontalSeparator == true)  && (offset.dy < 0))
        )
      ) ||
      (
        (children[widgetIndex].maxPercentage != null) &&
        (children[widgetIndex].maxPercentage! < appliedPercentage)  &&
        (
          ((_info.isHorizontalSeparator == false) && (offset.dx > 0)) ||
          ((_info.isHorizontalSeparator == true)  && (offset.dy > 0))
        )
      )
    ) {
      return ResizableWidgetResizeImplReturn(
        size: children[widgetIndex].size!,
        percent: children[widgetIndex].percentage!,
        state: ResizableWidgetResizeImplReturnState.INVALID
      );
    }
  
    ResizableWidgetResizeImplReturn _data = ResizableWidgetResizeImplReturn(
        size: appliedSize,
        percent: appliedPercentage,
        state: ResizableWidgetResizeImplReturnState.VALID
      );
    if(apply) { __applyResizeImpl(widgetIndex, _data); }    
    return _data;
  }


  void __applyResizeImpl(int widgetIndex, ResizableWidgetResizeImplReturn data){
    children[widgetIndex].size = data.size;
    children[widgetIndex].percentage = data.percent;
  }

  bool _isNearlyZero(double size) {
    return size < 2;
  }
}
