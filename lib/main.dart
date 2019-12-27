import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/music_controller.dart';
import 'package:flutter_music_player/utils/shared_preference_util.dart';
import 'package:provider/provider.dart';
import 'dao/api_cache.dart';
import 'model/color_provider.dart';
import 'model/video_controller.dart';
import 'pages/home_page.dart';

void main() {
  _initBeforeRunApp().then((re) {
    runApp(_buildProvider());
    _doSomethingInBackground();
  });
}

/// 在启动之前要做的异步任务
/// 获取主题颜色
Future<bool> _initBeforeRunApp() async {
  // 要去SharedPrefrence里面去颜色数据，但是为异步任务，修改main方法，首先完成异步任务再启动app；
  await SharedPreferenceUtil.init();
  ColorStyleProvider.initColorStyle();
  return true;
}

/// 启动时要进行的后台任务
/// 这里简单用async，如果任务比较耗时，考虑Isolate方案。
_doSomethingInBackground() async {
  // 清理缓存
  await APICache.clearCache();
}


/// 遇到一个坑，一直报错：flutter Could not find the correct Provider
/// 原来是Provider要加在App上面，而不是HomePage上面。
_buildProvider() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ColorStyleProvider>.value(value: ColorStyleProvider()),
      ChangeNotifierProvider<MusicController>.value(value: MusicController()),
      ChangeNotifierProvider<VideoControllerProvider>.value(
          value: VideoControllerProvider()),
    ],
    child: MyApp(),
  );
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    ColorStyleProvider colorStyleProvider = Provider.of<ColorStyleProvider>(context);
    return MaterialApp(
        title: 'Flutter Music',
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: colorStyleProvider.showPerformanceOverlay, // 是否打开性能测试层
        theme: ThemeData(
            brightness: Brightness.light,
            appBarTheme: AppBarTheme(
                brightness: Brightness.dark,
                iconTheme: IconThemeData(color: Colors.white),
                textTheme: TextTheme(title: TextStyle(color: Colors.white))),
            primarySwatch: colorStyleProvider.getCurrentColor(color: 'mainColor')),
        home: HomePage());
  }
}
