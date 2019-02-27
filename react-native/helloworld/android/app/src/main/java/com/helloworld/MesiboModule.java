package com.helloworld;

import com.mesibo.api.Mesibo;
import com.mesibo.messaging.MesiboUI;

import android.app.Application;
import android.util.Log;


import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import java.util.Map;
import java.util.HashMap;

public class MesiboModule extends ReactContextBaseJavaModule {

  public static final String TAG="MesiboModule";

  public MesiboModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  public String getName() {
	  return "MesiboModule";
  }

  @ReactMethod
  public void init(final String token) {

	  getCurrentActivity().runOnUiThread(new Runnable()
			      {           
			              @Override
				              public void run()
					              {
	  Mesibo api = Mesibo.getInstance();
	  api.init(getReactApplicationContext());
	  if(0 != api.setAccessToken(token)) {
	         Log.d(TAG, "bad token: ");
		 return;
          }

	  api.setDatabase("messaging.db", 0);
	  api.start();
	  }});
  }

  @ReactMethod
  public void sendMessage(String to, String message) {

	  Mesibo.MessageParams p = new Mesibo.MessageParams();
	  p.peer = to;
	  Mesibo.sendMessage(p, Mesibo.random(), message);
  }
  
  @ReactMethod
  public void launchUi(String to) {
	  MesiboUI.launchMessageView(getCurrentActivity(), to, 0);
  }

}
