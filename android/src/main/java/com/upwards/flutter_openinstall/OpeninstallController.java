package com.upwards.flutter_openinstall;

import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.fm.openinstall.OpenInstall;
import com.fm.openinstall.listener.AppWakeUpAdapter;
import com.fm.openinstall.model.AppData;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.FlutterNativeView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class OpeninstallController {
    private final PluginRegistry.Registrar registrar;

    public static OpeninstallController instance;

    private final MethodChannel channel;

    public OpeninstallController(PluginRegistry.Registrar registrar, MethodChannel channel) {
        this.registrar = registrar;

        this.channel = channel;

        if (isMainProcess()) {
            OpenInstall.init(registrar.context());
        }
        registrar.addViewDestroyListener(new PluginRegistry.ViewDestroyListener() {
            @Override
            public boolean onViewDestroy(FlutterNativeView flutterNativeView) {
                wakeUpAdapter = null;
                return false;
            }
        });
        registrar.addNewIntentListener(new PluginRegistry.NewIntentListener() {
            @Override
            public boolean onNewIntent(Intent intent) {
                OpenInstall.getWakeUp(intent, wakeUpAdapter);
                return true;
            }
        });
        registrar.addActivityResultListener(new PluginRegistry.ActivityResultListener() {
            @Override
            public boolean onActivityResult(int i, int i1, Intent intent) {
                OpenInstall.getWakeUp(intent, wakeUpAdapter);
                return true;
            }
        });

        instance = this;
    }

    AppWakeUpAdapter wakeUpAdapter = new AppWakeUpAdapter() {
        @Override
        public void onWakeUp(AppData appData) {
            //获取渠道数据
            String channelCode = appData.getChannel();
            //获取绑定数据
            String bindData = appData.getData();
            Log.d("OpenInstall", "getWakeUp : wakeupData = " + appData.toString());
            Log.d("OpenInstall", "getWakeUp : bindData = " + bindData);
            //  接收到参数
            Map<String, Object> notification= new HashMap<>();
            try {
                notification = JsonHelper.toMap(new JSONObject(bindData));
            } catch (JSONException e) {
                Log.d("OpenInstall", "error = " + e);
            }
            OpeninstallController.instance.channel.invokeMethod("onWakeupNotification", notification);
        }
    };

    public boolean isMainProcess() {
        int pid = android.os.Process.myPid();
        ActivityManager activityManager = (ActivityManager) registrar.context().getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningAppProcessInfo appProcess : activityManager.getRunningAppProcesses()) {
            if (appProcess.pid == pid) {
                return registrar.context().getApplicationInfo().packageName.equals(appProcess.processName);
            }
        }
        return false;
    }
}
