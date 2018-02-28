package com.mesibo.firstsample;

import android.app.Application;
import android.content.Context;

import com.mesibo.api.Mesibo;
import com.mesibo.calls.MesiboCall;
import com.mesibo.mediapicker.MediaPicker;
import com.mesibo.messaging.MesiboUI;

/**
 * Here is basic mesibo initialization. Depending on application need, you can do it at other places
 * too. However, Application is an ideal place for one time initialization
 */

public class MainApplication extends Application {
    public static final String TAG = "MesiboDemoApplication";
    private static Context mContext = null;
    private static MesiboCall mCall = null;
    private static Mesibo mesibo = null;

    @Override
    public void onCreate() {
        super.onCreate();
        mContext = getApplicationContext();

        /** Mesibo one-time initialization */
        mesiboInit();

        /** [OPTIONAL] Customize look and feel of Mesibo UI */
        MesiboUI.Config opt = MesiboUI.getConfig();
        opt.mToolbarColor = 0xff00868b;
        opt.emptyUserListMessage = "Ask your family and friends to download so that you can try out Mesibo functionalities";
        MediaPicker.setToolbarColor(opt.mToolbarColor);
    }

    private void mesiboInit() {

        mesibo = Mesibo.getInstance();

        mesibo.init(getApplicationContext());

        /** [OPTIONAL] Initializa calls if used  */
        mCall = MesiboCall.getInstance();
        mCall.init(this);


        /** [Optional] add listener for file transfer handler
         * you only need if you plan to send and receive files using mesibo
         * */
        MesiboFileTransferHelper fileTransferHelper = new MesiboFileTransferHelper();
        Mesibo.addListener(fileTransferHelper);

        /** add other listener - you can add any number of listeners */
        Mesibo.addListener(new MesiboListener());

        /** [Optional] enable to disable secure connection */
        Mesibo.setSecureConnection(true);

        /** Initialize web api to communicate with your own backend servers */
        SampleAppWebApi.init();

    }

    /**
     * Start mesibo only after you have a user access token
     */
    public static void startMesibo() {
        /** set user access token  */
        Mesibo.setAccessToken(SampleAppWebApi.getToken());

        /** [OPTIONAL] set up database to save and restore messages
         * Note: if you call this API before setting an access token, mesibo will
         * create a database exactly as you named it. However, if you call it
         * after setting Access Token like in this example, it will be uniquely
         * named for each user [Preferred].
         * */
        Mesibo.setDatabase("myAppDb.db", 0);

        /** start mesibo */
        Mesibo.start();
    }

    public static Context getContext() {
        return mContext;
    }
}
