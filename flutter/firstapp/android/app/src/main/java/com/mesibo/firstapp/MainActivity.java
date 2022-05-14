package com.mesibo.firstapp;

import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import com.mesibo.api.Mesibo;
import com.mesibo.api.MesiboProfile;
import com.mesibo.calls.api.MesiboCall;
import com.mesibo.messaging.MesiboUI;

import java.util.Map;
import java.util.HashMap;

public class MainActivity extends FlutterActivity implements FlutterPlugin, MesiboPlugin.MesiboPluginApi, Mesibo.ConnectionListener, Mesibo.MessageListener{

    MethodChannel channel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine){
        super.configureFlutterEngine(flutterEngine);
        //GeneratedPluginRegistrant.registerWith(flutterEngine);
        MesiboPlugin.MesiboPluginApi.setup(flutterEngine.getDartExecutor().getBinaryMessenger(), this);
        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "mesibo.com/callbacks");
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
        MesiboPlugin.MesiboPluginApi.setup(flutterPluginBinding.getBinaryMessenger(), this);
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding flutterPluginBinding) {
        MesiboPlugin.MesiboPluginApi.setup(flutterPluginBinding.getBinaryMessenger(), null);
    }


    public void setup(String token) {
        Log.d("setup", token);
        Mesibo api = Mesibo.getInstance();
        api.init(getApplicationContext());

        Mesibo.addListener(this);
        Mesibo.setAccessToken(token);
        Mesibo.setDatabase("mesibo", 0);
        Mesibo.start();

        MesiboCall.getInstance().init(getApplicationContext());
    }

    public void sendMessage(@NonNull String peer, @NonNull String message) {
        Log.d("sendMessage", peer + ":" + message);
    }

    public void showUserList() {
        MesiboUI.launch(this, 0, false, false);
    }

    public void showMessages(@NonNull String peer) {
        MesiboUI.launchMessageView(this, peer, 0);
    }

    public void audioCall(String peer) {
        MesiboCall.getInstance().callUi(this, peer, false);
    }

    public void videoCall(String peer) {
        MesiboCall.getInstance().callUi(this, peer, true);
    }

    @Override
    public void Mesibo_onConnectionStatus(int status) {
        Map<String, Object> args = new HashMap<>();
        try {
            args.put("status", status);
        } catch (Error | RuntimeException exception) {
            args.put("error", "error");
        }

        invokeCallback("Mesibo_onConnectionStatus", args);
    }

    @Override
    public boolean Mesibo_onMessage(Mesibo.MessageParams messageParams, byte[] bytes) {


        String message = "";
        try {
            message = new String(bytes, "UTF-8");

            if(!message.isEmpty()) {
                //mEventsSink.success("Mesibo Message Received : " + message);
            }
            //Toast.makeText(this, ""+message, Toast.LENGTH_SHORT).show();
        } catch (Exception e) {
            // return false;
        }

        Map<String, Object> args = new HashMap<>();
        try {
            args.put("from", messageParams.peer);
            args.put("message", message);
        } catch (Error | RuntimeException exception) {
            args.put("error", "error");
        }

        invokeCallback("Mesibo_onMessage", args);

        return false;

    }

    @Override
    public void Mesibo_onMessageStatus(Mesibo.MessageParams messageParams) {

    }

    @Override
    public void Mesibo_onActivity(Mesibo.MessageParams messageParams, int i) {

    }

    @Override
    public void Mesibo_onLocation(Mesibo.MessageParams messageParams, Mesibo.Location location) {

    }

    @Override
    public void Mesibo_onFile(Mesibo.MessageParams messageParams, Mesibo.FileInfo fileInfo) {

    }

    void invokeCallback(String name, Object args) {
        channel.invokeMethod(name, args, new MethodChannel.Result() {
            @Override
            public void success(Object o) {
                Log.d("Results", o.toString());
            }
            @Override
            public void error(String s, String s1, Object o) {
            }
            @Override
            public void notImplemented() {
            }

        });
    }
}
