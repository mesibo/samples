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

import com.mesibo.api.MesiboGroupProfile;
import com.mesibo.api.MesiboProfile;
import com.mesibo.api.MesiboSelfProfile;
import com.mesibo.calls.api.MesiboCall;
import com.mesibo.calls.api.MesiboCallActivity;
import com.mesibo.messaging.MesiboUI;

import java.security.Permission;


public class MainActivity extends AppCompatActivity implements Mesibo.ConnectionListener,
        Mesibo.MessageListener,
        Mesibo.ProfileListener, Mesibo.GroupListener {

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

    /* Refer to the Get-Started guide to create two users and their access tokens
     * https://mesibo.com/documentation/tutorials/get-started/
     */
    DemoUser mUser1 = new DemoUser("<token-1>", "User-1", "123");
    DemoUser mUser2 = new DemoUser("<token-2>", "User-1", "456");

    DemoUser mRemoteUser;
    MesiboProfile mProfile;
    Mesibo.ReadDbSession mReadSession;

    View mLoginButton1, mLoginButton2;
    TextView mMessageStatus, mConnStatus;
    EditText mMessage, mName;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mLoginButton1 = findViewById(R.id.login1);
        mLoginButton2 = findViewById(R.id.login2);

        mMessageStatus = findViewById(R.id.msgStatus);
        mConnStatus = findViewById(R.id.connStatus);
        mMessage = findViewById(R.id.message);
        mName = findViewById(R.id.name);

    }

    private void mesiboInit(DemoUser user, DemoUser remoteUser) {
        Mesibo api = Mesibo.getInstance();
        api.init(getApplicationContext());

        Mesibo.addListener(this);
        Mesibo.setAccessToken(user.token);
        Mesibo.setDatabase("mydb", 0);
        Mesibo.start();

        mRemoteUser = remoteUser;
        mProfile = Mesibo.getProfile(remoteUser.address);


        // disable login buttons
        mLoginButton1.setEnabled(false);
        mLoginButton2.setEnabled(false);

        // Read receipts are enabled only when App is set to be in foreground
        Mesibo.setAppInForeground(this, 0, true);
        mReadSession = mProfile.createReadSession(this);
        mReadSession.enableReadReceipt(true);
        mReadSession.read(100);

        /* initialize call with custom title */
        MesiboCall.getInstance().init(this);
        MesiboCall.CallProperties cp = MesiboCall.getInstance().createCallProperties(true);
        cp.ui.title = "First App";
        MesiboCall.getInstance().setDefaultUiProperties(cp.ui);
    }


    public void onLoginUser1(View view) {
        mesiboInit(mUser1, mUser2);
    }

    public void onLoginUser2(View view) {
        mesiboInit(mUser2, mUser1);
    }

    public void onSendMessage(View view) {
        if(!isLoggedIn()) return;
        String message = mMessage.getText().toString().trim();
        mProfile.sendMessage(Mesibo.random(), message);
        mMessage.setText("");
    }

    public void onLaunchMessagingUi(View view) {
        if(!isLoggedIn()) return;
        MesiboUI.launchMessageView(this, mProfile.getAddress(), 0);
    }

    public void onAudioCall(View view) {
        if(!isLoggedIn()) return;
        MesiboCall.getInstance().callUi(this, mProfile.getAddress(), false);
    }

    public void onVideoCall(View view) {
        if(!isLoggedIn()) return;
        MesiboCall.getInstance().callUi(this, mProfile.getAddress(), true);
    }

    public void onUpdateProfile(View view) {
        if(!isLoggedIn()) return;
        MesiboSelfProfile profile = Mesibo.getSelfProfile();
        if(null == profile) return;
        String name = mName.getText().toString().trim();
        profile.setName(name);
        profile.setStatus("I am using mesibo");
        profile.save();
    }

    public void onCreateGroup(View view) {
        if(!isLoggedIn()) return;
        Mesibo.createGroup("My Group", 0, this);
    }

    public void addGroupMembers(MesiboProfile profile) {
        if(!isLoggedIn()) return;
        MesiboGroupProfile gp = profile.getGroupProfile();
        String[] members = {mRemoteUser.address};
        gp.addMembers(members, MesiboGroupProfile.MEMBERFLAG_ALL, 0);

    }

    boolean isLoggedIn() {
        if(Mesibo.STATUS_ONLINE == Mesibo.getConnectionStatus()) return true;
        toast("Login with a valid token first");
        return false;
    }

    void toast(String message) {
        Toast toast = Toast.makeText(getApplicationContext(), message, Toast.LENGTH_SHORT);
        //toast.setGravity(Gravity.CENTER_VERTICAL, 0, 0);
        toast.show();
    }

    @Override
    public void Mesibo_onConnectionStatus(int status) {
        mConnStatus.setText("Connection Status: " + status);
    }

    @Override
    public boolean Mesibo_onMessage(Mesibo.MessageParams messageParams, byte[] data) {
        try {
            String message = new String(data, "UTF-8");
            toast("You have got a message: " + message);
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

    /* Mesibo Group Listener */
    @Override
    public void Mesibo_onGroupCreated(MesiboProfile profile) {
        toast("New Group Created: " + profile.getName());
        addGroupMembers(profile);
    }

    @Override
    public void Mesibo_onGroupJoined(MesiboProfile profile) {

    }

    @Override
    public void Mesibo_onGroupLeft(MesiboProfile profile) {

    }

    @Override
    public void Mesibo_onGroupMembers(MesiboProfile profile, MesiboGroupProfile.Member[] members) {

    }

    @Override
    public void Mesibo_onGroupMembersJoined(MesiboProfile profile, MesiboGroupProfile.Member[] members) {

    }

    @Override
    public void Mesibo_onGroupMembersRemoved(MesiboProfile profile, MesiboGroupProfile.Member[] members) {

    }

    /* Mesibo Profile Listener */
    @Override
    public void Mesibo_onProfileUpdated(MesiboProfile profile) {
        toast(profile.getName() + " has updated profile");
    }

    @Override
    public boolean Mesibo_onGetProfile(MesiboProfile profile) {
        return false;
    }
}