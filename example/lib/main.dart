import 'package:flutter/material.dart';
import 'package:resizable_widget/resizable_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resizable Widget Example',
      theme: ThemeData.dark(),
      home: const MyPage(),
    );
  }
}

GlobalKey<ResizableWidgetState> resizableWidgetKey = GlobalKey();

class MyPage extends StatelessWidget {
   const MyPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resizable Widget Example'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 600,
            child: ResizableWidget(
              key: resizableWidgetKey,
              isHorizontalSeparator: false,
              isDisabledSmartHide: false,
              separatorColor: Colors.white12,
              separatorSize: 4,
              onResized: _printResizeInfo,
              children: [
                Container(color: Colors.greenAccent),
                Container(color: Colors.redAccent),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                /// two buttons to test the [ResizableWidget] with [isDisabledSmartHide] = true
                TextButton(
                  onPressed: () {
                    // ResizableWidget.of(context)?.hideSeparator(0);
                    const offset = Offset(-100, 0);
                    resizableWidgetKey.currentState?.moveSeparator(1, offset);
                  },
                  child: const Text('Hide 0'),
                ),
                TextButton(
                  onPressed: () {
                    // ResizableWidget.of(context)?.showSeparator(0);
                    const offset = Offset(100, 0);
                    resizableWidgetKey.currentState?.moveSeparator(1, offset);
                  },
                  child: const Text('Show 0'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _printResizeInfo(List<WidgetSizeInfo> dataList) {
    // ignore: avoid_print
    print(dataList.map((x) => '(${x.size}, ${x.percentage}%)').join(", "));
  }
}
