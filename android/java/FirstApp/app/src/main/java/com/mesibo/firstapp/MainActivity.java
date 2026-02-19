package com.mesibo.firstapp;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;

import com.mesibo.api.Mesibo;
import com.mesibo.api.MesiboGroupProfile;
import com.mesibo.api.MesiboLocation;
import com.mesibo.api.MesiboLocationConfig;
import com.mesibo.api.MesiboLocationListener;
import com.mesibo.api.MesiboLocationManager;
import com.mesibo.api.MesiboMessage;
import com.mesibo.api.MesiboPhoneContact;
import com.mesibo.api.MesiboPresence;
import com.mesibo.api.MesiboProfile;
import com.mesibo.api.MesiboProfileLocation;
import com.mesibo.api.MesiboProfileSearch;
import com.mesibo.api.MesiboProfileSearchListener;
import com.mesibo.api.MesiboReadSession;
import com.mesibo.api.MesiboSelfProfile;
import com.mesibo.calls.api.MesiboCall;
import com.mesibo.messaging.MesiboUI;
import com.mesibo.messaging.MesiboUiDefaults;

/**************************************************************************************************
 This demo application implements real-time messaging, calls, and conferencing capabilities in an
 Android application. It can serve as a guide for integrating these features into your own Android
 projects. Please refer to the tutorial link below for details on getting started, obtaining
 authentication tokens and other implementation specifics.

 https://docs.mesibo.com/tutorials/get-started/

 You MUST create tokens and initialize them for user1 and user2 in the code below.

 **************************************************************************************************/


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

    /**************************************************************************************************
     Please refer to the tutorial link below for details on obtaining user authentication tokens.

     https://mesibo.com/documentation/tutorials/get-started/
     **************************************************************************************************/

    DemoUser mUser1 = new DemoUser("Token-1", "User-1", "123");
    DemoUser mUser2 = new DemoUser("Token-2", "User-2", "456");

    DemoUser mRemoteUser;
    MesiboProfile mProfile;
    MesiboReadSession mReadSession;

    View mLoginButton1, mLoginButton2;
    TextView mConnStatus;
    String mLoginPrompt = "Login with a valid token first";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mLoginButton1 = findViewById(R.id.login1);
        mLoginButton2 = findViewById(R.id.login2);

        mConnStatus = findViewById(R.id.connStatus);
    }

    private void mesiboInit(DemoUser user, DemoUser remoteUser) {
        Mesibo api = Mesibo.getInstance();
        api.init(getApplicationContext());

        Mesibo.addListener(this);
        Mesibo.setAccessToken(user.token);
        Mesibo.setDatabase("mydb");
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
        int count = mReadSession.read(100);
        Log.d(TAG, "first read result: " + count);

        if(0 == count) {
            sendTextMessage("Hello from Android");
        }

        /* OPTIONAL - initialize Messaging UI customization listener */
        MesiboUI.setListener(new UIListener());

        /**************************************************************************************************
         override default UI text, colors, etc.Refer to the documentation

         https://mesibo.com/documentation/ui-modules/

         Also refer to the header file for complete list of parameters (applies to both Android/iOS)
         https://github.com/mesibo/mesiboframeworks/blob/main/mesiboui.framework/Headers/MesiboUI.h#L170
         **************************************************************************************************/
        MesiboUiDefaults defs = MesiboUI.getUiDefaults();
        defs.showMissedCalls = true;
        defs.enableBackButton = true;

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
        msg.message = "Hello from mesibo";
        msg.setContent("https://www.youtube.com/watch?v=b29TOTpmFqY"); // file path, URL or Bitmap
        msg.send();
    }

    public void sendRichMessageWithLocation() {
        MesiboMessage msg = new MesiboMessage(mProfile);
        msg.message = "Hello from mesibo";
        msg.title = "Message Title";
        msg.latitude = 1.3521;
        msg.longitude = 103.8198;
        msg.send();
    }

    public void sendRichMessageWithCustomFields() {
        MesiboMessage msg = new MesiboMessage(mProfile);
        msg.message = "Hello from mesibo";
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
        sendTextMessage("Hello from Android");

        MesiboReadSession session = mProfile.createReadSession(this);
        session.enableReadReceipt(true);
        int result = session.read(100);
        Log.d(TAG, "after message read result: " + result);
    }

    public void onShowUsersList(View view) {
        if(!isLoggedIn()) return;

        MesiboUI.MesiboUserListScreenOptions opts = new MesiboUI.MesiboUserListScreenOptions();
        MesiboUI.launchUserList(this, opts);
    }

    public void onShowMessages(View view) {
        if(!isLoggedIn()) return;
        MesiboUI.MesiboMessageScreenOptions opts = new MesiboUI.MesiboMessageScreenOptions();
        opts.profile = mProfile;
        MesiboUI.launchMessaging(this, opts);
    }

    public void onAudioCall(View view) {
        if(!isLoggedIn()) return;
        MesiboCall.getInstance().callUi(this, mProfile, false);
    }

    public void onVideoCall(View view) {
        if(!isLoggedIn()) return;
        MesiboCall.getInstance().callUi(this, mProfile, true);
    }

    public void onGroupCall(View view) {
        if(!isLoggedIn()) return;
        int groupId = 0; // set appropriate group id
        if(0 == groupId)
            return;

        MesiboCall.getInstance().groupCallUi(this, Mesibo.getProfile(groupId), true, true, true, true);
    }

    public void onSetProfile(View view) {
        if(!isLoggedIn()) return;
        MesiboSelfProfile profile = Mesibo.getSelfProfile();
        if(null == profile) return;
        profile.reset();
        String name = "Joe from Android";
        profile.setName(name);
        profile.setString("status", "I am using mesibo");
        profile.save();
    }

    /* Group Management - https://mesibo.com/documentation/api/group-management/ */
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

    private int REQUEST_CODE = 111;
    public void onSyncContacts(View view) {
        if(!isLoggedIn()) return;
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) ==
                PackageManager.PERMISSION_GRANTED) {
            Mesibo.getPhoneContactsManager().start();
            return;
        }

        toast("You MUST request read contact permission before accessing phone contacts");

    }

    public void onPhoneNumberInfo(View view) {
        if(!isLoggedIn()) return;
        MesiboPhoneContact contact = Mesibo.getPhoneContactsManager().getPhoneNumberInfo("+18005551234", null, true);
        String name = contact.name;
        String phone = contact.formattedPhoneNumber;
        String country = contact.country;
    }

    public void initLocation() {
        MesiboLocationConfig locationConfig = new MesiboLocationConfig();
        locationConfig.minDistance = 250;

        MesiboLocationManager locationManager = MesiboLocationManager.getInstance();
        //locationManager.addListener(this);
        locationManager.start(locationConfig);
    }

    public void getLocation() {
        MesiboProfileLocation profileLocation = mProfile.location();
        MesiboLocation location = profileLocation.get();
    }

    public void searchLocation() {
        MesiboProfileSearch profileSearch = new MesiboProfileSearch();
        profileSearch.setListener(null);
        profileSearch.setDistance(1000); // 1000 meters
        profileSearch.setMaxAge(3600); // within last hour
        profileSearch.search();
    }

    boolean isLoggedIn() {
        if(Mesibo.STATUS_ONLINE == Mesibo.getConnectionStatus()) return true;
        toast(mLoginPrompt);
        return false;
    }

    void toast(String message) {
        Toast toast = Toast.makeText(getApplicationContext(), message, Toast.LENGTH_LONG);
        //toast.setGravity(Gravity.CENTER_VERTICAL, 0, 0);
        toast.show();
    }

    @Override
    public void Mesibo_onConnectionStatus(int status) {
        mConnStatus.setText("Connection Status: " + status);
        if(Mesibo.STATUS_AUTHFAIL == status) {
            mLoginPrompt = "The token is invalid. Ensure that you have used appid \"" + Mesibo.getAppIdForAccessToken() + "\" to generate Mesibo user access token";
            toast(mLoginPrompt);
        }
    }

    @Override
    public void Mesibo_onMessage(MesiboMessage msg) {

        /* Messaging documentation https://mesibo.com/documentation/api/messaging/ */
        if(msg.isIncoming()) {

            /* Profile documentation https://mesibo.com/documentation/api/users-and-profiles/ */
            MesiboProfile sender = msg.profile;

            // check if this message belongs to a group
            /* Group Management - https://mesibo.com/documentation/api/group-management/ */
            if(msg.isGroupMessage()) {
                MesiboProfile group = msg.groupProfile;
            }

            // check if this message is realtime or read from the database
            if(msg.isRealtimeMessage()) {
                toast("You have got a message from " + sender.getNameOrAddress() + ": " + msg.message);
            }

        } else if(msg.isOutgoing()) {

            /* messages you sent */

        } else if(msg.isMissedCall()) {

        }

        return;
    }

    @Override
    public void Mesibo_onMessageStatus(MesiboMessage msg) {

    }

    @Override
    public void Mesibo_onMessageUpdate(MesiboMessage msg) {
        toast("You have got a message update: " + msg.message);
    }

    @Override
    public void Mesibo_onPresence(MesiboPresence presence) {
        String name = presence.profile.getNameOrAddress();
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

}
