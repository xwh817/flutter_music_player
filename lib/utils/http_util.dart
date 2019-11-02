import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_music_player/dao/api_cache.dart';

class HttpUtil {

  static Future getJsonData(String url, {bool useCache: true}) async {
    var data;
    if (useCache) { // 有些资源是动态的,如播放地址，会过期不能使用缓存。
      String cache = await APICache.getCache(url);
      if (cache != null) {
        try {
          data = jsonDecode(cache);
        } catch(e) {
          APICache.deleteCache(url);
          print(e);
        }
      }
    }
    // 缓存没取到，就请求网络。
    if (data == null) {
      /* var httpClient = new HttpClient();
      print("http request: $url");
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        String json = await response.transform(utf8.decoder).join();
        if (useCache) {
          bool re = await APICache.saveCache(url, json);
          print('saveCache $url result: $re');
        }
        
        try {
          data = jsonDecode(json);
        } catch(e) {
          print(e);
        }
        
      } else {
        throw Exception(
            'Request failed, errorCode: ${response.statusCode}');
      } */

      // options:请求参数
      // 这儿文本要缓存，所以ResponseType不用默认的json
      BaseOptions options = new BaseOptions();
      options.responseType = ResponseType.plain;  
      Response response = await Dio(options).get(url);
      if (response.statusCode == HttpStatus.ok) {
        var text = response.data;

        try {
          data = jsonDecode(text);
        } catch(e) {
          print(e);
        }

        if (useCache) { // 缓存到本地
          bool re = await APICache.saveCache(url, text);
          print('saveCache $url result: $re');
        }
      } else {
        throw Exception(
            'Request failed, errorCode: ${response.statusCode}');
      }
      
    }
    
    return data;
  }


  static void download(String url, String savePath) {
    print('download $url to $savePath');
    File localFile = File(savePath);
    localFile.exists().then((exists){
      if (!exists) {
        localFile.createSync(recursive: true);
      }
      return Dio().download(url, savePath);
    }).then((response){
        if (response.statusCode == 200) {
          print('下载成功');
        } else {
          print('下载失败：${response.statusCode}');
        }
    });
  }

}