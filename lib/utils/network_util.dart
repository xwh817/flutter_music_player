import 'package:connectivity/connectivity.dart';

class NetworkUtil {

  /// 单例对象的写法
  // 私有静态instance
  static NetworkUtil _instance;

  // 对外访问点，指向私有静态方法
  factory NetworkUtil() {
    if (_instance == null) {
      _instance = NetworkUtil._();
    }
    return _instance;
  }

  // 将默认构造函数私有化
  NetworkUtil._();


  static ConnectivityResult networkState;

  var subscription;

  initNetworkListener(){
    //监测网络变化
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
          networkState = result;
          print('当前网络状态: $networkState');
          /* if (result == ConnectivityResult.mobile) {  // 手机网络

          } else if (result == ConnectivityResult.wifi) { // wifi

          } else {  // 无网络

          } */
    });
  }

  ConnectivityResult getNetworkState(){
    return networkState;
  }

  bool isNetworkAvailable(){
    return networkState != ConnectivityResult.none;
  }

  void dispose() {
    //在页面销毁的时候一定要取消网络状态的监听
    subscription?.cancle();
  }
  
}