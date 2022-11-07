package com.mesibo.firstapp;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.mesibo.api.Mesibo;

import com.mesibo.api.MesiboGroupProfile;
import com.mesibo.api.MesiboMessage;
import com.mesibo.api.MesiboPresence;
import com.mesibo.api.MesiboProfile;
import com.mesibo.api.MesiboReadSession;
import com.mesibo.api.MesiboSelfProfile;
import com.mesibo.calls.api.MesiboCall;
import com.mesibo.calls.api.MesiboCallActivity;
import com.mesibo.messaging.MesiboUI;

import java.security.Permission;


public class MainActivity extends AppCompatActivity implements Mesibo.ConnectionListener,
        Mesibo.MessageListener, Mesibo.PresenceListener,
        Mesibo.ProfileListener, Mesibo.GroupListener {

    final static String TAG="MesiboFirstApp";
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
    MesiboReadSession mReadSession;

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
        int result = mReadSession.read(100);
        Log.d(TAG, "first read result: " + result);

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

    public void sendTextMessage(String message) {
        MesiboMessage msg = mProfile.newMessage();
        msg.message = message;
        msg.send();
    }

    public void sendRichMessage() {
        MesiboMessage msg = new MesiboMessage(mProfile);
        msg.message = "Hello from mesibo 2.0.0";
        msg.title = "Message Title";
        msg.setContent("https://www.youtube.com/watch?v=b29TOTpmFqY"); // file path, URL or Bitmap
        msg.send();
    }

    public void sendRichMessageWithLocation() {
        MesiboMessage msg = new MesiboMessage(mProfile);
        msg.message = "Hello from mesibo 2.0.0";
        msg.title = "Message Title";
        msg.latitude = 1.3521;
        msg.longitude = 103.8198;
        msg.send();
    }

    public void sendRichMessageWithCustomFields() {
        MesiboMessage msg = new MesiboMessage(mProfile);
        msg.message = "Hello from mesibo 2.0.0";
        msg.title = "Message Title";
        msg.setString("Custom1", "some string value");
        msg.setInt("Custom2", 123);
        msg.send();
    }

    public void sendBinaryMessage(byte[] data) {
        MesiboMessage msg = new MesiboMessage(mProfile);
        msg.data = data;
        msg.send();
    }

    public void sendTyping() {
        mProfile.sendTyping();
    }

    public void onSendMessage(View view) {
        if(!isLoggedIn()) return;
        String message = mMessage.getText().toString().trim();
        sendTextMessage(message);
        mMessage.setText("");

        MesiboReadSession session = mProfile.createReadSession(this);
        session.enableReadReceipt(true);
        int result = session.read(100);
        Log.d(TAG, "after message read result: " + result);
    }

    public void onLaunchMessagingUi(View view) {
        if(!isLoggedIn()) return;
        MesiboUI.launchMessageView(this, mProfile);
    }

    public void onAudioCall(View view) {
        if(!isLoggedIn()) return;
        MesiboCall.getInstance().callUi(this, mProfile, false);
    }

    public void onVideoCall(View view) {
        if(!isLoggedIn()) return;
        MesiboCall.getInstance().callUi(this, mProfile, true);
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
        MesiboGroupProfile.GroupSettings settings = new MesiboGroupProfile.GroupSettings();
        settings.name = "My Group";
        settings.flags = 0;
        Mesibo.createGroup(settings, this);
    }

    public void addGroupMembers(MesiboProfile profile) {
        if(!isLoggedIn()) return;
        MesiboGroupProfile gp = profile.getGroupProfile();
        String[] members = {mRemoteUser.address};
        MesiboGroupProfile.MemberPermissions mp = new MesiboGroupProfile.MemberPermissions();
        mp.flags = MesiboGroupProfile.MEMBERFLAG_ALL;
        mp.adminFlags = 0;
        gp.addMembers(members, mp);

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
    public void Mesibo_onMessage(MesiboMessage msg) {
        toast("You have got a message: " + msg.message);

        return;
    }

    @Override
    public void Mesibo_onMessageStatus(MesiboMessage msg) {
        mMessageStatus.setText("Message Status: " + msg.getStatus());
    }

    @Override
    public void Mesibo_onMessageUpdate(MesiboMessage msg) {
        toast("You have got a message update: " + msg.message);
    }

    @Override
    public void Mesibo_onPresence(MesiboPresence presence) {
        String name = presence.profile.getNameOrAddress("");
        String typing = presence.profile.isTyping()?"Typing":"Not Typing";
        toast("User " + name + " is " + typing);
    }

    @Override
    public void Mesibo_onPresenceRequest(MesiboPresence presence) {

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

    @Override
    public void Mesibo_onGroupSettings(MesiboProfile mesiboProfile, MesiboGroupProfile.GroupSettings groupSettings, MesiboGroupProfile.MemberPermissions memberPermissions, MesiboGroupProfile.GroupPin[] groupPins) {

    }

    @Override
    public void Mesibo_onGroupError(MesiboProfile mesiboProfile, long l) {

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