package com.mesibo.firstsample;

import android.app.Application;
import android.content.Context;

import com.mesibo.api.Mesibo;
import com.mesibo.calls.MesiboCall;
import com.mesibo.mediapicker.MediaPicker;
import com.mesibo.messaging.MesiboUI;

/**
 * Created by root on 2/22/18.
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

        mesiboInit();


        MesiboUI.Config opt = MesiboUI.getConfig();
        opt.mToolbarColor = 0xff00868b;
        opt.emptyUserListMessage = "Ask your family and friends to download so that you can try out Mesibo functionalities";
        MediaPicker.setToolbarColor(opt.mToolbarColor);
    }

    private void mesiboInit() {

        mesibo = Mesibo.getInstance();

        mesibo.init(getApplicationContext());

        //config.listener = this;
        mCall = MesiboCall.getInstance();
        mCall.init(this);


        /* set user access token  */
        Mesibo.setAccessToken(SampleAppConfiguration.mesiboAuthToken);

        /* [Optional] set up database to save and restore messages */
        Mesibo.setDatabase("myAppDb.db", 0);

        /* [Optional] add listener for file transfer handler */
        MesiboFileTransferHelper fileTransferHelper = new MesiboFileTransferHelper();
        Mesibo.addListener(fileTransferHelper);

        /* add listener for UI helper functions */
        Mesibo.addListener(new MesiboListener());

        /* [Optional] enable to disable secure connection */
        Mesibo.setSecureConnection(true);

        /* start mesibo */
        Mesibo.start();

        /* add Some contacts - usually you fetch matching contacts from your server */
        /* Note: ensure that contacts are valid for your app in mesibo network */
        Mesibo.UserProfile u1 = new Mesibo.UserProfile();
        u1.name = "Joe";
        u1.address = "18005551234";
        u1.status = "Joe's Status";
        Mesibo.setUserProfile(u1, false);

        Mesibo.UserProfile u2 = new Mesibo.UserProfile();
        u2.name = "Angel";
        u2.address = "18005552345";
        u2.status = "Angel's Status";
        Mesibo.setUserProfile(u2, false);
    }
}
