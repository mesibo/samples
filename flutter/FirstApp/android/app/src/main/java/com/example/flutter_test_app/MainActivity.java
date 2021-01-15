package com.example.flutter_test_app;

import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import com.mesibo.api.Mesibo;
import com.mesibo.calls.api.MesiboCall;
import com.mesibo.messaging.MesiboUI;

public class MainActivity extends FlutterActivity implements Mesibo.ConnectionListener, Mesibo.MessageListener{
    private static final String MESIBO_MESSAGING_CHANNEL = "mesibo.flutter.io/messaging";
    private static final String MESIBO_ACTIVITY_CHANNEL = "mesibo.flutter.io/mesiboEvents";
    private static final String MesiboErrorMessage = "Mesibo has not started yet, Check Credentials";
    
    EventChannel.EventSink mEventsSink;

    class DemoUser {
        public String token;
        public String name;
        public String address;

        DemoUser(String token, String name, String address) {
            this.token = token;
            this.name = name;
            this.address = address;
        }
    }

    //Refer to the Get-Started guide to create two users and their access tokens
    DemoUser mUser1 = new DemoUser("xyz", "User-1", "flutter_demo_1");
    DemoUser mUser2 = new DemoUser("abc", "User-2", "flutter_demo_2");

    DemoUser mRemoteUser;
    Mesibo.UserProfile mProfile;
    Mesibo.ReadDbSession mReadSession;

    private String mMessage = null;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine){
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), MESIBO_ACTIVITY_CHANNEL)
                .setStreamHandler(
                        new EventChannel.StreamHandler() {

                            Mesibo.ConnectionListener messageListener;

                            @Override
                            public void onListen(Object arguments, EventChannel.EventSink events) {
                                mEventsSink = events;
                            }

                            @Override
                            public void onCancel(Object arguments) {

                            }
                        }
                );

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), MESIBO_MESSAGING_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("loginUser1")) {
                                mEventsSink.success("Login As User1");
                                onLoginUser1(null);
                            }
                            else if (call.method.equals("loginUser2")) {
                                mEventsSink.success("Login As User2");
                                onLoginUser2(null);
                            }
                            else if (call.method.equals("sendMessage")) {
                                mMessage = call.argument("message");
                                onSendMessage(null);
                            }
                            else if (call.method.equals("audioCall")) {
                                onAudioCall(null);
                            }
                            else if (call.method.equals("videoCall")) {
                                onVideoCall(null);
                            }
                            else if (call.method.equals("launchMessagingUI")) {
                                onLaunchMessagingUi(null);
                            }

                            else {
                                result.notImplemented();
                            }

                        }
                );

    }

        private void mesiboInit(DemoUser user, DemoUser remoteUser) {
        Mesibo api = Mesibo.getInstance();
        api.init(getApplicationContext());

        Mesibo.addListener(this);
//        Mesibo.setSecureConnection(true);
        Mesibo.setAccessToken(user.token);
        Mesibo.setDatabase("mydb", 0);
        Mesibo.start();

        mRemoteUser = remoteUser;
        mProfile = new Mesibo.UserProfile();
        mProfile.address = remoteUser.address;
        mProfile.name = remoteUser.name;
        Mesibo.setUserProfile(mProfile, false);

        MesiboCall.getInstance().init(getApplicationContext());

        // Read receipts are enabled only when App is set to be in foreground
        Mesibo.setAppInForeground(this, 0, true);
        mReadSession = new Mesibo.ReadDbSession(mRemoteUser.address, this);
        mReadSession.enableReadReceipt(true);
        mReadSession.read(100);

    }

    public void onLoginUser1(View view) {
        mesiboInit(mUser1, mUser2);
    }

    public void onLoginUser2(View view) {
        mesiboInit(mUser2, mUser1);
    }

    public void onSendMessage(View view) {
        Mesibo.MessageParams p = new Mesibo.MessageParams();
        p.peer = mRemoteUser.address;
        p.flag = Mesibo.FLAG_READRECEIPT | Mesibo.FLAG_DELIVERYRECEIPT;

        if(mMessage.isEmpty()){
            mEventsSink.success("Invalid Message");
            return;
        }

        Mesibo.sendMessage(p, Mesibo.random(), mMessage.toString().trim());
    }

    public void onLaunchMessagingUi(View view) {
        MesiboUI.launchMessageView(this, mRemoteUser.address, 0);
    }

    public void onAudioCall(View view) {
        MesiboCall.getInstance().callUi(this, mProfile.address, false);
    }

    public void onVideoCall(View view) {
        MesiboCall.getInstance().callUi(this, mProfile.address, true);
    }



    @Override
    public void Mesibo_onConnectionStatus(int i) {
        if (i == Mesibo.STATUS_ONLINE) {
            mEventsSink.success("Mesibo Connection Status : Online");
        }
        Log.d("mesibo","Mesibo_onConnectionStatus: " + i);
    }

    @Override
    public boolean Mesibo_onMessage(Mesibo.MessageParams messageParams, byte[] bytes) {
        String message = "";
        try {
            message = new String(bytes, "UTF-8");

            if(!message.isEmpty())
                mEventsSink.success("Mesibo Message Received : "+message);
            Toast.makeText(this, ""+message, Toast.LENGTH_SHORT).show();
        } catch (Exception e) {
            // return false;
        }
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
}
