import 'package:flutter/material.dart';
import 'package:flutter_music_player/pages/play_list_tab_page.dart';

class PlayList extends StatefulWidget {
  PlayList({Key key}) : super(key: key);

  _PlayListState createState() => _PlayListState();
}

const List<String> types = [
  "全部",
  "流行",
  "华语",
  "民谣",
  "摇滚",
  "古风",
  "欧美",
  "影视原声",
  "清新",
  "儿童",
  "浪漫",
  "电子",  
  "校园",
  "放松"
];

class _PlayListState extends State<PlayList>
    with SingleTickerProviderStateMixin {
  TabController tabController; //tab控制器

  @override
  void initState() {
    super.initState();
    //初始化controller并添加监听
    tabController = TabController(length: types.length, vsync: this);
    tabController.addListener(() => _onTabChanged());
  }

  state

  void _onTabChanged() {
    if (tabController.index.toDouble() == tabController.animation.value) {
    }
  }

  Widget mWidget;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: types.length,
        child: SafeArea(child:Scaffold(
          appBar: TabBar(
            controller: tabController, //控制器
            labelColor: Colors.green,
            unselectedLabelColor: Colors.black45,
            labelStyle: TextStyle(fontSize: 16), //选中的样式
            unselectedLabelStyle: TextStyle(fontSize: 14), //未选中的样式
            isScrollable: true, //是否可滑动
            //tab标签
            tabs: types.map((item) {
              return new Tab(
                text: item,
              );
            }).toList(),
            //点击事件
            onTap: (int i) {
              tabController.animateTo(i);
            },
          ),
          body: new TabBarView(
            controller: tabController,
            children: types.map((item) {
              return PlayListTabPage(type: item);
            }).toList(),
          ),
        )));
  }
}
