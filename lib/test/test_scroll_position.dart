import 'package:flutter/material.dart';

class TestScrollPosition extends StatefulWidget {
  @override
  _TestScrollPositionState createState() => _TestScrollPositionState();
}

class _TestScrollPositionState extends State<TestScrollPosition> {
  ScrollController _controller;

  final double itemHeight = 100.0;
  final int visibleItemSize = 5;
  List<int> items;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    items = List.generate(10, (i) => i + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Test Scroll Position"),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'up',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => _scroll(-1),
            ),
            FlatButton(
              child: Text(
                'down',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => _scroll(1),
            ),
          ],
        ),
        body: Container(
          height: itemHeight * visibleItemSize,
          color: Colors.black45,
          child: CustomScrollView(controller: _controller, slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                  items.map((item) => _getItem(item)).toList()),
            ),
          ]),
        ));
  }

  Widget _getItem(int item) {
    return Container(
        height: itemHeight,
        //margin: EdgeInsets.all(2.0),
        //color: Colors.greenAccent,
        alignment: Alignment.center,
        child: Text(
          '$item',
          style: TextStyle(
              fontSize: 36.0,
              color:
                  (item == selectedIndex + 1) ? Colors.white : Colors.white60),
        ));
  }

  void _scroll(int oriantation) {
    int index = selectedIndex + oriantation;

    // 选中的Index是否超出边界
    if (index < 0 || index >= items.length) {
      return;
    }

    int offset = visibleItemSize~/2;
    int topIndex = index - offset;  // 选中元素居中时,top的Index
    int bottomIndex = index + offset;

    setState(() {
      selectedIndex = index;
    });

    print("scoll:${_controller.offset}");

    if (topIndex < 0 && _controller.offset<=0) {
      return;
    }
    if (bottomIndex >= items.length && _controller.offset >= (items.length - visibleItemSize)*itemHeight) {
      return;
    }

    _controller.animateTo(topIndex * itemHeight,
        duration: Duration(seconds: 1), curve: Curves.easeInOut);

  }
}
