import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/play_list.dart';
import 'pages/home_page.dart';

void main() => runApp(_buildProvider());

/// 遇到一个坑，一直报错：flutter Could not find the correct Provider
/// 原来是Provider要加在App上面，而不是HomePage上面。
  _buildProvider() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlayList>.value(value: PlayList()),
      ],
      child: MyApp(),
    );
  }
  
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Music',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(),
    );
  }
}
