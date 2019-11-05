import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/pages/mv_tab_page.dart';

class MVPage extends StatefulWidget {
   MVPage({Key key}) : super(key: key);

  _MVPageState createState() => _MVPageState();
}

const types = {
  "最新": MusicDao.URL_MV_FIRST,
  "Top": MusicDao.URL_MV_TOP,
};

class _MVPageState extends State<MVPage>
    with SingleTickerProviderStateMixin {
  TabController tabController; //tab控制器

  @override
  void initState() {
    super.initState();
    //初始化controller并添加监听
    tabController = TabController(length: types.length, vsync: this);
    tabController.addListener(() => _onTabChanged());
  }


  void _onTabChanged() {
    if (tabController.index.toDouble() == tabController.animation.value) {}
  }

  Widget mWidget;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0x07000000),
        elevation: 0,
        title: TabBar(
          controller: tabController, //控制器
          indicatorColor: Colors.orange,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.black45,
          labelStyle: TextStyle(fontWeight: FontWeight.w600), //选中的样式
          unselectedLabelStyle: TextStyle(fontSize: 14), //未选中的样式
          isScrollable: true, //是否可滑动
          //tab标签
          tabs: types.keys.map((name) {
            return Tab(
              text: name,
            );
          }).toList(),
          //点击事件
          onTap: (int i) {
            tabController.animateTo(i);
          },
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: types.values.map((url) {
          return  MVTabPage(url: url);
        }).toList(),
      ),
    );
  }
}
