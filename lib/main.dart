import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/music_controller.dart';
import 'package:flutter_music_player/utils/toast_util.dart';
import 'package:provider/provider.dart';
import 'model/color_provider.dart';
import 'model/video_controller.dart';
import 'pages/home_page.dart';

void main() => runApp(_buildProvider());

/// 遇到一个坑，一直报错：flutter Could not find the correct Provider
/// 原来是Provider要加在App上面，而不是HomePage上面。
_buildProvider() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ColorStyleProvider>.value(
          value: ColorStyleProvider()),
      ChangeNotifierProvider<MusicController>.value(value: MusicController()),
      ChangeNotifierProvider<VideoControllerProvider>.value(
          value: VideoControllerProvider()),
    ],
    child: MyApp(),
  );
}

DateTime lastBackTime;

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ColorStyle _style = ColorStyle.green;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ColorStyleProvider colorStyleProvider =
        Provider.of<ColorStyleProvider>(context);
    colorStyleProvider.initColorStyle().then((style) {
      if (style != _style) {
        setState(() {
          _style = style;
        });
      }
    });

    return MaterialApp(
        title: 'Flutter Music',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch:
                colorStyleProvider.getCurrentColor(color: 'mainColor')),
        home: WillPopScope(
          onWillPop: () => _beforePop(context),
          child: HomePage(),
        ));
  }

  Future<bool> _beforePop(BuildContext context) async {
    if (lastBackTime == null ||
        DateTime.now().difference(lastBackTime) > Duration(seconds: 2)) {
      ToastUtil.showToast(context, "再按一次退出");
      lastBackTime = DateTime.now();
      return false; // 不返回
    }

    Provider.of<MusicController>(context, listen: false).dispose();
    return true;
  }
}
