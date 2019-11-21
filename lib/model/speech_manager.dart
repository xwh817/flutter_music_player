import 'package:flutter/services.dart';

class AsrManager {
  static const MethodChannel _channel = const MethodChannel('speech_plugin');

  /// 初始化
  static Future<void> init() async {
    return await _channel.invokeMethod('init');
  }

  /// 开始录音
  static Future<String> start({Map params}) async {
    return await _channel.invokeMethod('start', params ?? {});
  }

  /// 停止录音
  static Future<String> stop() async {
    return await _channel.invokeMethod('stop');
  }

  /// 取消录音
  static Future<String> cancel() async {
    return await _channel.invokeMethod('cancel');
  }
}