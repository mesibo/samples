package com.mesibo.firstapp;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.mesibo.api.Mesibo;

import com.mesibo.calls.api.MesiboCall;
import com.mesibo.messaging.MesiboUI;


public class MainActivity extends AppCompatActivity implements Mesibo.ConnectionListener, Mesibo.MessageListener {

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
    DemoUser mUser1 = new DemoUser("xyz", "User-1", "123");
    DemoUser mUser2 = new DemoUser("pqr", "User-1", "456");

    DemoUser mRemoteUser;
    Mesibo.UserProfile mProfile;
    Mesibo.ReadDbSession mReadSession;

    View mLoginButton1, mLoginButton2, mSendButton, mUiButton, mAudioCallButton, mVideoCallButton;
    TextView mMessageStatus, mConnStatus;
    EditText mMessage;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mLoginButton1 = findViewById(R.id.login1);
        mLoginButton2 = findViewById(R.id.login2);
        mSendButton = findViewById(R.id.send);
        mUiButton = findViewById(R.id.launchUI);
        mAudioCallButton = findViewById(R.id.audioCall);
        mVideoCallButton = findViewById(R.id.videoCall);
        mMessageStatus = findViewById(R.id.msgStatus);
        mConnStatus = findViewById(R.id.connStatus);
        mMessage = findViewById(R.id.message);

        mSendButton.setEnabled(false);
        mUiButton.setEnabled(false);
        mAudioCallButton.setEnabled(false);
        mVideoCallButton.setEnabled(false);

    }

    private void mesiboInit(DemoUser user, DemoUser remoteUser) {
        Mesibo api = Mesibo.getInstance();
        api.init(getApplicationContext());

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

        // disable login buttons
        mLoginButton1.setEnabled(false);
        mLoginButton2.setEnabled(false);

        // enable buttons
        mSendButton.setEnabled(true);
        mUiButton.setEnabled(true);
        mAudioCallButton.setEnabled(true);
        mVideoCallButton.setEnabled(true);


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

        Mesibo.sendMessage(p, Mesibo.random(), mMessage.getText().toString().trim());
        mMessage.setText("");
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
    public void Mesibo_onConnectionStatus(int status) {
        mConnStatus.setText("Connection Status: " + status);
    }

    @Override
    public boolean Mesibo_onMessage(Mesibo.MessageParams messageParams, byte[] data) {
        try {
            String message = new String(data, "UTF-8");

            Toast toast = Toast.makeText(getApplicationContext(),
                    message,
                    Toast.LENGTH_SHORT);

            toast.setGravity(Gravity.CENTER_VERTICAL, 0, 0);

            toast.show();

        } catch (Exception e) {
        }

        return true;
    }

    @Override
    public void Mesibo_onMessageStatus(Mesibo.MessageParams messageParams) {
        mMessageStatus.setText("Message Status: " + messageParams.getStatus());
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