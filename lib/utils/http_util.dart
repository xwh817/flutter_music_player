import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_music_player/dao/api_cache.dart';

class HttpUtil {
  /// 获取api接口json数据
  /// useCache：是否使用缓存，默认使用。但对于经常变化和容易过期的资源，例如视频播放地址，不要使用。
  /// checkCacheTimeout：是否检查缓存过期，默认检查，如果过期重新获取。对于不变的资源例如歌词，可以设置false，减少不必要的请求。
  static Future getJsonData(String url,
      {bool useCache: true, checkCacheTimeout: true}) async {
    var data;
    if (useCache) {
      // 有些资源是动态的,如播放地址，会过期不能使用缓存。
      String cache =
          await APICache.getCache(url, checkCacheTimeout: checkCacheTimeout);
      if (cache != null) {
        try {
          data = jsonDecode(cache);
        } catch (e) {
          APICache.deleteCache(url);
          print(e);
        }
      }
    }
    // 缓存没取到，就请求网络。
    if (data == null) {
      /// options:请求参数
      /// 这儿文本要缓存处理，所以ResponseType不用默认的json格式
      /// 或者使用 jsonEncode将Map对象转为json字符串，不要用toString，会丢掉符号信息。
      BaseOptions options = new BaseOptions();
      options.responseType = ResponseType.plain;
      options.connectTimeout = 10000; // 连接超时

      try {
        Response response = await Dio(options).get(url);
        if (response.statusCode == HttpStatus.ok) {
          var text = response.data;
          data = jsonDecode(text);

          if (useCache) {
            // 缓存到本地
            bool re = await APICache.saveCache(url, text);
            print('saveCache $url result: $re');
          }
        } else {
          throw Exception('Request failed, errorCode: ${response.statusCode}');
        }
      } catch (e) {
        /// 如果网络超时，会报 DioErrorType.CONNECT_TIMEOUT
        print(e);
        if (e == DioErrorType.connectTimeout ||
            e == DioErrorType.sendTimeout ||
            e == DioErrorType.receiveTimeout) {
          print('网络请求超时');
        }
      }
    }

    return data;
  }

  static void download(String url, String savePath) {
    print('download $url to $savePath');
    File localFile = File(savePath);
    localFile.exists().then((exists) {
      if (!exists) {
        localFile.createSync(recursive: true);
      }
      return Dio().download(url, savePath);
    }).then((response) {
      if (response.statusCode == 200) {
        print('下载成功');
      } else {
        print('下载失败：${response.statusCode}');
      }
    });
  }
}
