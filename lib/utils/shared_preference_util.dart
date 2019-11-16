import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceUtil {
  static SharedPreferences instance;
  
  /// SharedPreferences的初始化是异步的，很多地方要同步的方式使用很麻烦。
  /// 这里在启动时统一初始化一次，后面直接用。
  static init() async {
    instance = await SharedPreferences.getInstance();
  }

  static SharedPreferences getInstance() {
    return instance;
  }

  
}