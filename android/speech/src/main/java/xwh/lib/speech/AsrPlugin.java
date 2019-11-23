package xwh.lib.speech;

import android.app.Activity;
import android.util.Log;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class AsrPlugin implements MethodChannel.MethodCallHandler{

    private AsrManager asrManager;
    private Activity activity;
    private MethodChannel.Result result;    // 注意result对象时一次性的。
    private boolean isFinished = false;

    public static void registerWith(PluginRegistry.Registrar registrar) {
        MethodChannel methodChannel = new MethodChannel(registrar.messenger(), "speech_plugin");
        AsrPlugin instance = new AsrPlugin(registrar);
        methodChannel.setMethodCallHandler(instance);
    }

    public AsrPlugin(PluginRegistry.Registrar registrar) {
        activity = registrar.activity();
        asrManager = AsrManager.getInstance();
        asrManager.setSpeechListener(new AsrManager.SpeechListener() {
            @Override
            public void onResult(String text) {
                if (isFinished) {   // result对象不能重复回复，不然报错
                    return;
                }
                isFinished = true;
                Log.d("AsrPlugin", "onResult: " + text);
                AsrPlugin.this.result.success(text);
            }

            @Override
            public void onError(String error) {
                if (isFinished) {
                    return;
                }
                isFinished = true;
                Log.d("AsrPlugin", "onError: " + error);
                AsrPlugin.this.result.error(error, null, null);
            }

            @Override
            public void onEnd() {
                if (!isFinished) {
                    isFinished = true;
                    AsrPlugin.this.result.error("未识别到内容", null, null);
                }
                Log.d("AsrPlugin", "onEnd");
            }
        });
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "init":
                asrManager.init(activity);
                break;
            case "start":
                this.result = result;
                isFinished = false;
                asrManager.start();
                break;
            case "stop":
                asrManager.stop();
                break;
            case "cancel":
                asrManager.cancel();
                break;
        }
    }
}
