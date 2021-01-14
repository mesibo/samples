package com.firstapp;

import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.mesibo.api.Mesibo;
import com.mesibo.calls.api.MesiboCall;
import com.mesibo.messaging.MesiboUI;

import java.util.Map;
import java.util.HashMap;

public class MesiboModule extends ReactContextBaseJavaModule implements Mesibo.MessageListener, Mesibo.ConnectionListener{
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
    DemoUser mUser1 ;
    DemoUser mUser2 ;

    DemoUser mRemoteUser;
    Mesibo.UserProfile mProfile;
    Mesibo.ReadDbSession mReadSession;


    MesiboModule(ReactApplicationContext context) {
        super(context);
    }

    @NonNull
    @Override
    public String getName() {
        return "MesiboModule";
    }

    @ReactMethod
    public void setUser1(String token, String name, String address) {
        mUser1 = new DemoUser(token, name, address);
    }

    @ReactMethod
    public void setUser2(String token, String name, String address) {
        mUser2 = new DemoUser(token, name, address);
    }

    @ReactMethod
    public void onLoginUser1() {
        mesiboInit(mUser1, mUser2);
    }

    @ReactMethod
    public void onLoginUser2() {
        mesiboInit(mUser2, mUser1);
    }


    private void mesiboInit(final DemoUser user, final DemoUser remoteUser) {
        Mesibo api = Mesibo.getInstance();
        api.init(getReactApplicationContext());

        Mesibo.addListener(this);
        Mesibo.setSecureConnection(true);
        Mesibo.setAccessToken(user.token);
        Mesibo.setDatabase("mydb", 0);
        Mesibo.start();

        mRemoteUser = remoteUser;
        mProfile = new Mesibo.UserProfile();
        mProfile.address = remoteUser.address;
        mProfile.name = remoteUser.name;
        Mesibo.setUserProfile(mProfile, false);

        MesiboCall.getInstance().init(getReactApplicationContext());

        // Read receipts are enabled only when App is set to be in foreground
        Mesibo.setAppInForeground(getReactApplicationContext(), 0, true);
        mReadSession = new Mesibo.ReadDbSession(mRemoteUser.address, this);
        mReadSession.enableReadReceipt(true);
        mReadSession.read(100);
    }

    @ReactMethod
    public void onSendMessage(final String mMessage) {
        Mesibo.MessageParams p = new Mesibo.MessageParams();
        p.peer = mRemoteUser.address;
        p.flag = Mesibo.FLAG_READRECEIPT | Mesibo.FLAG_DELIVERYRECEIPT;

        if(mMessage.isEmpty()){
            return;
        }

        Mesibo.sendMessage(p, Mesibo.random(), mMessage.toString().trim());
    }


    @ReactMethod
    public void onLaunchMessagingUi() {
        MesiboUI.launchMessageView(getCurrentActivity(), mRemoteUser.address, 0);
    }

    @ReactMethod
    public void onAudioCall() {
        MesiboCall.getInstance().callUi(getReactApplicationContext(), mProfile.address, false);
    }

    @ReactMethod
    public void onVideoCall() {
        MesiboCall.getInstance().callUi(getReactApplicationContext(), mProfile.address, true);
    }

    private void sendReactEvent(String listener, String value) {
        WritableMap params = Arguments.createMap();
        params.putString("event", listener);
        params.putString("value", value);
        getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("mesiboListener", params);
    }

    @Override
    public void Mesibo_onConnectionStatus(int status) {
        Log.d("mesibo", "Connection Status: "+ status);
        sendReactEvent("onConnectionStatus", ""+ status);
    }

    @Override
    public boolean Mesibo_onMessage(Mesibo.MessageParams messageParams, byte[] data) {
        try {
            String message = new String(data, "UTF-8");
            Toast toast = Toast.makeText(getReactApplicationContext(),
                    "Message: " + message,
                    Toast.LENGTH_SHORT);
            toast.show();
            sendReactEvent("onMessage", message);

        } catch (Exception e) {
        }

        return true;
    }


    @Override
    public void Mesibo_onMessageStatus(Mesibo.MessageParams messageParams) {
        try {
            sendReactEvent("onMessageStatus", ""+messageParams.getStatus());
        } catch (Exception e) {
        }
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
