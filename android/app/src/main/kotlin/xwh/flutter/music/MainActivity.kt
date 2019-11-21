package xwh.flutter.music

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import xwh.lib.speech.AsrPlugin

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    this.registerMyPlugins()
  }


  // 注册自定义的插件
  private fun registerMyPlugins() {
    AsrPlugin.registerWith(registrarFor("xwh.lib.speech.AsrPlugin"))
  }
}
