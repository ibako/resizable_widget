import 'package:flutter/material.dart';
import 'package:resizable_widget/resizable_widget.dart';

import 'custom_separator.dart';

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
        home: DefaultTabController(
            length: 3,
            child: Scaffold(
                appBar: AppBar(
                    title: const Text("Resizable Widget Example"),
                    bottom: const TabBar(tabs: [
                      Tab(text: "Simple"),
                      Tab(text: "Default Separator"),
                      Tab(text: "Custom Separator"),
                    ])),
                body: const TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      SimpleExamplePage(),
                      DefaultSeparatorExamplePage(),
                      CustomSeparatorExamplePage(),
                    ]))));
  }
}

class SimpleExamplePage extends StatelessWidget {
  const SimpleExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResizableWidget(
      isHorizontalSeparator: false,
      isDisabledSmartHide: false,
      separatorColor: Colors.white12,
      separatorSize: 4,
      onResized: _printResizeInfo,
      children: [
        Container(color: Colors.greenAccent),
        ResizableWidget(
          isHorizontalSeparator: true,
          separatorColor: Colors.blue,
          separatorSize: 10,
          children: [
            Container(color: Colors.greenAccent),
            ResizableWidget(
              children: [
                Container(color: Colors.greenAccent),
                Container(color: Colors.yellowAccent),
                Container(color: Colors.redAccent),
              ],
              percentages: const [0.2, 0.5, 0.3],
            ),
            Container(color: Colors.redAccent),
          ],
        ),
        Container(color: Colors.redAccent),
      ],
    );
  }

  _printResizeInfo(List<WidgetSizeInfo> dataList) {
    debugPrint(dataList.map((x) => '(${x.size}, ${x.percentage}%)').join(", "));
  }
}

class DefaultSeparatorExamplePage extends StatelessWidget {
  const DefaultSeparatorExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResizableWidget(
      isHorizontalSeparator: true,
      separatorSize: 16,
      separatorBuilder: (info, controller) => DefaultSeparatorWidget(
        info: info,
        controller: controller,
      ),
      onResized: _printResizeInfo,
      children: [
        Container(color: Colors.greenAccent),
        Container(color: Colors.redAccent),
        Container(color: Colors.blueAccent),
      ],
    );
  }

  _printResizeInfo(List<WidgetSizeInfo> dataList) {
    debugPrint(dataList.map((x) => '(${x.size}, ${x.percentage}%)').join(", "));
  }
}

class CustomSeparatorExamplePage extends StatelessWidget {
  const CustomSeparatorExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResizableWidget(
      isHorizontalSeparator: true,
      separatorSize: 40,
      separatorBuilder: (info, controller) => CustomSeparatorWidget(
        info: info,
        controller: controller,
      ),
      onResized: _printResizeInfo,
      children: [
        Container(color: Colors.greenAccent),
        Container(color: Colors.redAccent),
        Container(color: Colors.blueAccent),
      ],
    );
  }

  _printResizeInfo(List<WidgetSizeInfo> dataList) {
    debugPrint(dataList.map((x) => '(${x.size}, ${x.percentage}%)').join(", "));
  }
}
