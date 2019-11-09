import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/music_controller.dart';
import 'package:flutter_music_player/utils/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'model/play_list.dart';
import 'model/video_controller.dart';
import 'pages/home_page.dart';

void main() => runApp(_buildProvider());

/// 遇到一个坑，一直报错：flutter Could not find the correct Provider
/// 原来是Provider要加在App上面，而不是HomePage上面。
_buildProvider() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<PlayList>.value(value: PlayList()),
      ChangeNotifierProvider<MusicController>.value(value: MusicController()),
      ChangeNotifierProvider<VideoControllerProvider>.value(value: VideoControllerProvider()),
    ],
    child: MyApp(),
  );
}

DateTime lastBackTime;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Music',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.green),
        home: WillPopScope(
          onWillPop: _beforePop,
          child: HomePage(),
        ));
  }

  Future<bool> _beforePop() async {
    if (lastBackTime == null ||
        DateTime.now().difference(lastBackTime) > Duration(seconds: 2)) {
      Fluttertoast.showToast(
          msg: "再按一次退出",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: AppColors.toastBackground,
          textColor: Colors.white,
          fontSize: 14.0);

      lastBackTime = DateTime.now();
      return false; // 不返回
    }
    return true;
  }

  
}
