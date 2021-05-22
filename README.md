# resizable_widget

`ResizableWidget` Holds resizable widgets as children.

Users can resize inner widgets by dragging.

## Example

![example](https://user-images.githubusercontent.com/76907198/119232375-0defb580-bb60-11eb-9a95-e9c84fce43f4.gif)


```dart
import 'package:resizable_widget/resizable_widget.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResizableWidget(
        isColumnChildren: false,
        separatorColor: Colors.white12,
        separatorSize: 4,
        children: [
          Container(color: Colors.greenAccent),
          ResizableWidget(
            isColumnChildren: true,
            separatorColor: Colors.blue,
            separatorSize: 10,
            children: [
              Container(color: Colors.greenAccent),
              Container(color: Colors.yellowAccent),
              Container(color: Colors.redAccent),
            ],
          ),
          Container(color: Colors.redAccent),
        ],
      ),
    );
  }
}
```
