# resizable_widget

`ResizableWidget` enables users to resize the internal widgets by dragging.

This package contains simple APIs, but if needed, you can customize `ResizableWidget` flexibly.

## Example

![example](https://user-images.githubusercontent.com/76907198/119232375-0defb580-bb60-11eb-9a95-e9c84fce43f4.gif)


```dart
import 'package:resizable_widget/resizable_widget.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResizableWidget(
        isColumnChildren: false, // optional
        separatorColor: Colors.white12, // optional
        separatorSize: 4, // optional
        children: [ // must
          Container(color: Colors.greenAccent),
          Container(color: Colors.yellowAccent),
          Container(color: Colors.redAccent),
        ],
      ),
    );
  }
}
```

## Package page (pub.dev)

https://pub.dev/packages/resizable_widget

## API Document

https://pub.dev/documentation/resizable_widget/latest/resizable_widget/resizable_widget-library.html
