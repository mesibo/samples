package com.mesibo.firstapp;

import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import com.mesibo.api.Mesibo;

import com.mesibo.api.MesiboProfile;
import com.mesibo.calls.api.MesiboCall;
import com.mesibo.flutter.MesiboFlutterPlugin;


public class MainActivity extends FlutterActivity implements Mesibo.InitListener, MesiboCall.IncomingListener {

    static final String TAG = "MainActivity";
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // OPTIONAL - to invoke Mesibo_onInit after initialization to perform additional custom
        // initialization, if requires. For example, call customization, UI customization listener, etc
	// Uncomment, if requires
        // Mesibo.addListener(this);
    }

    /* The code below is OPTIONAL for any additional mesibo initialization */
    /* Mesibo_onInit will be called before and after mesibo starts */
    @Override
    public void Mesibo_onInit(boolean start) {
        if(!start) return;

        // Initializing mesibo call and set listener to customize call
        MesiboCall.getInstance().init(getApplicationContext());
        MesiboCall.getInstance().setListener(this);
    }

    @Override
    public MesiboCall.CallProperties MesiboCall_OnIncoming(MesiboProfile profile, boolean video, boolean waiting) {
        MesiboCall.CallProperties cc = MesiboCall.getInstance().createCallProperties(video);
        cc.parent = getApplicationContext();
        cc.user = profile;

        // customize CallProperties here and return
        // OR, return null to reject an incoming call

        return cc;
    }

    @Override
    public boolean MesiboCall_OnShowUserInterface(MesiboCall.Call call, MesiboCall.CallProperties callProperties) {
        return false;
    }

    @Override
    public void MesiboCall_OnError(MesiboCall.CallProperties callProperties, int error) {

    }

    @Override
    public boolean MesiboCall_onNotify(int i, MesiboProfile mesiboProfile, boolean video) {
        return false;
    }
}
