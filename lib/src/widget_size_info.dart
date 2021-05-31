/// Information about an internal widget size of [ResizableWidget].
class WidgetSizeInfo {
  /// The actual pixel size.
  ///
  /// If the app window size is changed, this value will be also changed.
  final double size;

  /// The size percentage among the [ResizableWidget] children.
  ///
  /// Even if the app window size is changed, this value will not be changed
  /// because the ratio of the internal widgets will be maintained.
  final double percentage;

  /// Creates [WidgetSizeInfo].
  const WidgetSizeInfo(this.size, this.percentage);
}
