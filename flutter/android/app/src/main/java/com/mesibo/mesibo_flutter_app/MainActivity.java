/** Copyright (c) 2019 Mesibo
 * https://mesibo.com
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the terms and condition mentioned on https://mesibo.com
 * as well as following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this list
 * of conditions, the following disclaimer and links to documentation and source code
 * repository.
 *
 * Redistributions in binary form must reproduce the above copyright notice, this
 * list of conditions and the following disclaimer in the documentation and/or other
 * materials provided with the distribution.
 *
 * Neither the name of Mesibo nor the names of its contributors may be used to endorse
 * or promote products derived from this software without specific prior written
 * permission.
 *
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * Documentation
 * https://mesibo.com/documentation/
 *
 * Source Code Repository
 * https://github.com/mesibo/messenger-app-android
 *
 */


package com.mesibo.mesibo_flutter_app;

import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
import com.mesibo.api.Mesibo;
import com.mesibo.calls.MesiboCall;
import java.util.ArrayList;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements  Mesibo.ConnectionListener, Mesibo.MessageListener, Mesibo.MessageFilter {
    private static final String MESIBO_MESSAGING_CHANNEL = "mesibo.flutter.io/messaging";
    private static final String MESIBO_ACTIVITY_CHANNEL = "mesibo.flutter.io/mesiboEvents";
    private static final String MesiboErrorMessage = "Mesibo has not started yet, Check Credentials";
    private static MesiboCall mCall = null;
    EventSink mEventsSink;
    private static String mUserAccessToken;
    private static String mPeer;
    Mesibo.MessageParams mParameter;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        //mesiboInit();


        new EventChannel(getFlutterView(), MESIBO_ACTIVITY_CHANNEL).setStreamHandler(
                new StreamHandler() {
                    //private BroadcastReceiver chargingStateChangeReceiver;

                    Mesibo.ConnectionListener messageListener;

                    @Override
                    public void onListen(Object arguments, EventSink events) {
                        mEventsSink = events;
                    }

                    @Override
                    public void onCancel(Object arguments) {
                    }
                }
        );


        new MethodChannel(getFlutterView(), MESIBO_MESSAGING_CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {

                        if(call.method.equals("setAccessToken")){
                            //get credentials from flutter
                            ArrayList credentials = call.argument("Credentials");
                            if (credentials != null) {
                                mUserAccessToken = credentials.get(0).toString();
                                mPeer = credentials.get(1).toString();

                                //start mesibo here
                                mesiboInit();

                                // set Mesibo MessageParams
                                mParameter = new Mesibo.MessageParams(mPeer, 0, Mesibo.FLAG_DEFAULT, 0);

                            }

                        }else if (call.method.equals("sendMessage")) {

                            if(null != mPeer) {
                                //send message to desired user added in mParameter
                                Mesibo.sendMessage(mParameter, Mesibo.random(), "Hello from Mesibo Flutter");
                                mEventsSink.success("Message Sent to "+mPeer);
                            }else{
                                mEventsSink.success(MesiboErrorMessage);
                            }

                        } else if (call.method.equals("launchMesiboUI")) {
                            if(null != mPeer) {
                                //Launch Mesibo Custom UI
                                Intent i = new Intent(MainActivity.this, MessagingActivity.class);
                                i.putExtra("peer", mParameter.peer);
                                startActivity(i);
                            }else{
                                mEventsSink.success(MesiboErrorMessage);
                            }
                        } else if (call.method.equals("audioCall")) {
                            if(null != mPeer) {
                                //make audio call
                                MesiboCall.getInstance().call(MainActivity.this, Mesibo.random(), mParameter.profile, false);
                            }else{
                                mEventsSink.success(MesiboErrorMessage);
                            }
                        } else if (call.method.equals("videoCall")) {
                            if(null != mPeer) {
                                //make Video Call
                                MesiboCall.getInstance().call(MainActivity.this, Mesibo.random(), mParameter.profile, true);
                            }else{
                                mEventsSink.success(MesiboErrorMessage);
                            }
                        } else {
                            result.notImplemented();
                        }
                    }
                }
        );
    }


    private void mesiboInit() {

        Mesibo mesibo = Mesibo.getInstance();

        mesibo.init(this);

        /** [OPTIONAL] Initializa calls if used  */
        mCall = MesiboCall.getInstance();
        mCall.init(this);


        /** [Optional] add listener for file transfer handler
         * you only need if you plan to send and receive files using mesibo
         * */
//        MesiboFileTransferHelper fileTransferHelper = new MesiboFileTransferHelper();
//        Mesibo.addListener(fileTransferHelper);

        /** add other listener - you can add any number of listeners */
        Mesibo.addListener(this);

        /** [Optional] enable to disable secure connection */
        Mesibo.setSecureConnection(true);

        /** Initialize web api to communicate with your own backend servers */
        //* set user access token
        Mesibo.setAccessToken(mUserAccessToken);

        // set path for storing DB and messaging files
        Mesibo.setPath(Environment.getExternalStorageDirectory().getAbsolutePath());

        /* * [OPTIONAL] set up database to save and restore messages
         * Note: if you call this API before setting an access token, mesibo will
         * create a database exactly as you named it. However, if you call it
         * after setting Access Token like in this example, it will be uniquely
         * named for each user [Preferred].
         * */
        Mesibo.setDatabase("myAppDb.db", 0);

        // start mesibo
        Mesibo.start();
        /** add other listener - you can add any number of listeners */




    }


    @Override
    public void Mesibo_onConnectionStatus(int i) {
        if (i == Mesibo.STATUS_ONLINE) {
            mEventsSink.success("Mesibo Connection Status : Online");
        }
    }


    @Override
    public boolean Mesibo_onMessage(Mesibo.MessageParams messageParams, byte[] bytes) {

        String message = "";
        try {
            message = new String(bytes, "UTF-8");

            if(!message.isEmpty())
            mEventsSink.success("Mesibo Message Received : "+message);
            //Toast.makeText(this, ""+message, Toast.LENGTH_SHORT).show();
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

    @Override
    public boolean Mesibo_onMessageFilter(Mesibo.MessageParams messageParams, int i, byte[] bytes) {
        return true;
    }
}
