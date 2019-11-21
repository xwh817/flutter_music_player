package xwh.lib.speech;

import android.app.Activity;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class AsrPlugin implements MethodChannel.MethodCallHandler{

    private AsrManager asrManager;
    private Activity activity;
    private MethodChannel.Result result;


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
                AsrPlugin.this.result.success(text);
            }

            @Override
            public void onError(String error) {
                AsrPlugin.this.result.error(error, null, null);
            }

            @Override
            public void onEnd() {
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
