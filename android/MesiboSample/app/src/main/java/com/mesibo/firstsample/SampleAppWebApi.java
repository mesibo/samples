package com.mesibo.firstsample;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import com.google.gson.Gson;
import com.mesibo.api.Mesibo;

/**
 * Web API to communicate with your own backend server(s).
 * Note - in this example, we are not authenticating. In real app, you should authenticate user first
 * using email or phone OTP.
 *
 * When user is successfully authenticated, your server should create a mesibo auth token using
 * mesibo server side api and send it back here.
 *
 * Refer to PHP server api for code sample.
 */

public class SampleAppWebApi {
    public static final String TAG="SampleAppWebApi";
    private static SharedPreferences mSharedPref = null;
    public static final String mSharedPrefKey = "com.mesibo.samplecodeapp";
    private static Gson mGson = new Gson();
    private static String mToken = null;

    public interface DemoWebApiResponseHandler {
        void onApiResponse(boolean result);
    }

    public static class Contacts {
        public String name = "";
        public String phone = "";
        public long   gid = 0;
    }

    public static class Response {
        public String result;
        public String op;
        public String error;
        public String token;
        public Contacts[] contacts;

        Response() {
            result = null;
            op = null;
            error = null;
            token = null;
            contacts = null;
        }
    }

    public static synchronized  void init() {
        if(null != mSharedPref) return;

        mSharedPref = MainApplication.getContext().getSharedPreferences(mSharedPrefKey, Context.MODE_PRIVATE);
        mToken = getStringValue("token", null);

        if(isLoggedin())
            MainApplication.startMesibo();
    }

    public static boolean isLoggedin() {
        return !TextUtils.isEmpty(mToken);
    }

    public static String getToken() {
        return mToken;
    }

    public static void login(String name, String phone, final DemoWebApiResponseHandler handler) {

        Bundle b = new Bundle();
        b.putString("op", "login");
        b.putString("ns", SampleAppConfiguration.namespace);
        b.putString("aid", MainApplication.getContext().getPackageName());
        b.putString("name", name);
        b.putString("phone", phone);
        /* end of post data */

        Mesibo.Http http = new Mesibo.Http();

        http.url = SampleAppConfiguration.apiUrl;
        http.postBundle = b;
        http.onMainThread = true;

        http.listener = new Mesibo.HttpListener() {
            @Override
            public boolean Mesibo_onHttpProgress(Mesibo.Http config, int state, int percent) {

                if(100 == percent && Mesibo.Http.STATE_DOWNLOAD == state) {

                    //parse response
                    String respString = config.getDataString();
                    Response response = mGson.fromJson(respString, Response.class);
                    if(null == response || !response.result.equalsIgnoreCase("OK")) {
                        handler.onApiResponse(false);
                        return true;
                    }

                    setStringValue("token", response.token);
                    mToken = response.token;
                    Mesibo.reset();

                    /* start mesibo before saving contacts */
                    MainApplication.startMesibo();

                    if(null != response.contacts) {
                        for(Contacts c : response.contacts) {
                            addContact(c.name, c.phone);
                        }
                    }

                    handler.onApiResponse(true);
                    return true;
                }

                if(percent < 0)
                    handler.onApiResponse(false);

                return true;
            }
        };

        http.execute();
    }

    public static void logout() {
        Mesibo.stop(false);

        Bundle b = new Bundle();
        b.putString("op", "logout");
        b.putString("token", mToken);
        /* end of post data */

        Mesibo.Http http = new Mesibo.Http();

        http.url = SampleAppConfiguration.apiUrl;
        http.postBundle = b;

        http.listener = new Mesibo.HttpListener() {
            @Override
            public boolean Mesibo_onHttpProgress(Mesibo.Http config, int state, int percent) {
                return true;
            }
        };

        http.execute();

        mToken = null;
        setStringValue("token", "");
    }

    public static void addContact(String name, String phone) {
        if(TextUtils.isEmpty(phone)) return;

        Mesibo.UserProfile profile = new Mesibo.UserProfile();
        profile.name = name;
        profile.address = phone;
        if(TextUtils.isEmpty(name))
            profile.name = phone;

        Mesibo.setUserProfile(profile, false);
    }

    public static boolean setStringValue(String key, String value) {
        try {
            synchronized (mSharedPref) {
                SharedPreferences.Editor poEditor = mSharedPref.edit();
                poEditor.putString(key, value);
                poEditor.commit();
                //backup();
                return true;
            }
        } catch (Exception e) {
            Log.d(TAG, "Unable to set long value in RMS:" + e.getMessage());
            return false;
        }
    }

    public static String getStringValue(String key, String defaultVal) {
        try {
            synchronized (mSharedPref) {
                if (mSharedPref.contains(key))
                    return mSharedPref.getString(key, defaultVal);
                return defaultVal;
            }
        } catch (Exception e) {
            Log.d(TAG, "Unable to fet long value in RMS:" + e.getMessage());
            return defaultVal;
        }
    }
}
