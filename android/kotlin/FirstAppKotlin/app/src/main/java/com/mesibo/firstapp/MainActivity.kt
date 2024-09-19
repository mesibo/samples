package com.mesibo.firstapp

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.mesibo.api.*
import com.mesibo.api.Mesibo.ConnectionListener
import com.mesibo.api.Mesibo.GroupListener
import com.mesibo.api.Mesibo.MessageListener
import com.mesibo.api.Mesibo.PresenceListener
import com.mesibo.api.Mesibo.ProfileListener
import com.mesibo.api.MesiboGroupProfile.*
import com.mesibo.calls.api.MesiboCall
import com.mesibo.firstapp.R
import com.mesibo.messaging.MesiboUI
import com.mesibo.messaging.MesiboUI.MesiboMessageScreenOptions
import com.mesibo.messaging.MesiboUI.MesiboUserListScreenOptions

/**************************************************************************************************
 * This demo application implements real-time messaging, calls, and conferencing capabilities in an
 * Android application. It can serve as a guide for integrating these features into your own Android
 * projects. Please refer to the tutorial link below for details on getting started, obtaining
 * authentication tokens and other implementation specifics.
 *
 * https://docs.mesibo.com/tutorials/get-started/
 *
 * You MUST create tokens and initialize them for user1 and user2 in the code below.
 *
 */
class MainActivity : AppCompatActivity(), ConnectionListener, MessageListener, PresenceListener,
    ProfileListener, GroupListener {
    inner class DemoUser(var token: String, var name: String, var address: String)

    /**************************************************************************************************
     * Please refer to the tutorial link below for details on obtaining user authentication tokens.
     *
     * https://mesibo.com/documentation/tutorials/get-started/
     */
    var mUser1:DemoUser = DemoUser(
        "Token-1",
        "User-1",
        "123"
    )
    var mUser2:DemoUser = DemoUser("Token-2", "User-2", "456")
    var mRemoteUser:DemoUser? = null
    var mProfile: MesiboProfile? = null
    var mReadSession: MesiboReadSession? = null
    var mLoginButton1: View? = null
    var mLoginButton2: View? = null
    var mConnStatus: TextView? = null
    var mLoginPrompt = "Login with a valid token first"
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        mLoginButton1 = findViewById(R.id.login1)
        mLoginButton2 = findViewById(R.id.login2)
        mConnStatus = findViewById(R.id.connStatus)
    }

    private fun mesiboInit(user: MainActivity.DemoUser, remoteUser: MainActivity.DemoUser) {
        val api = Mesibo.getInstance()
        api.init(applicationContext)
        Mesibo.addListener(this)
        Mesibo.setAccessToken(user.token)
        Mesibo.setDatabase("mydb")
        Mesibo.start()
        mRemoteUser = remoteUser
        mProfile = Mesibo.getProfile(remoteUser.address)


        // disable login buttons
        mLoginButton1!!.isEnabled = false
        mLoginButton2!!.isEnabled = false

        // Read receipts are enabled only when App is set to be in foreground
        Mesibo.setAppInForeground(this, 0, true)
        mReadSession = mProfile?.createReadSession(this)
        mReadSession?.enableReadReceipt(true)
        val count = mReadSession?.read(100)
        Log.d(MainActivity.Companion.TAG, "first read result: $count")
        if (0 == count) {
            sendTextMessage("Hello from Android")
        }

        /* OPTIONAL - initialize Messaging UI customization listener */MesiboUI.setListener(
            UIListener()
        )
        /**************************************************************************************************
         * override default UI text, colors, etc.Refer to the documentation
         *
         * https://mesibo.com/documentation/ui-modules/
         *
         * Also refer to the header file for complete list of parameters (applies to both Android/iOS)
         * https://github.com/mesibo/mesiboframeworks/blob/main/mesiboui.framework/Headers/MesiboUI.h#L170
         */
        val defs = MesiboUI.getUiDefaults()
        defs.showMissedCalls = true
        defs.enableBackButton = true

        /* initialize call with custom title */MesiboCall.getInstance().init(this)
        val cp = MesiboCall.getInstance().createCallProperties(true)
        cp.ui.title = "First App"
        MesiboCall.getInstance().setDefaultUiProperties(cp.ui)
    }

    fun onLoginUser1(view: View?) {
        mesiboInit(mUser1, mUser2)
    }

    fun onLoginUser2(view: View?) {
        mesiboInit(mUser2, mUser1)
    }

    fun sendTextMessage(message: String?) {
        val msg = mProfile!!.newMessage()
        msg.message = message
        msg.send()
    }

    fun sendRichMessage() {
        val msg = MesiboMessage(mProfile)
        msg.message = "Hello from mesibo"
        msg.setContent("https://www.youtube.com/watch?v=b29TOTpmFqY") // file path, URL or Bitmap
        msg.send()
    }

    fun sendRichMessageWithLocation() {
        val msg = MesiboMessage(mProfile)
        msg.message = "Hello from mesibo"
        msg.title = "Message Title"
        msg.latitude = 1.3521
        msg.longitude = 103.8198
        msg.send()
    }

    fun sendRichMessageWithCustomFields() {
        val msg = MesiboMessage(mProfile)
        msg.message = "Hello from mesibo"
        msg.title = "Message Title"
        msg.setString("Custom1", "some string value")
        msg.setInt("Custom2", 123)
        msg.send()
    }

    fun sendBinaryMessage(data: ByteArray?) {
        val msg = MesiboMessage(mProfile)
        msg.data = data
        msg.send()
    }

    fun sendTyping() {
        mProfile!!.sendTyping()
    }

    fun onSendMessage(view: View?) {
        if (!isLoggedIn) return
        sendTextMessage("Hello from Android")
        val session = mProfile!!.createReadSession(this)
        session.enableReadReceipt(true)
        val result = session.read(100)
        Log.d(MainActivity.Companion.TAG, "after message read result: $result")
    }

    fun onShowUsersList(view: View?) {
        if (!isLoggedIn) return
        val opts = MesiboUserListScreenOptions()
        MesiboUI.launchUserList(this, opts)
    }

    fun onShowMessages(view: View?) {
        if (!isLoggedIn) return
        val opts = MesiboMessageScreenOptions()
        opts.profile = mProfile
        MesiboUI.launchMessaging(this, opts)
    }

    fun onAudioCall(view: View?) {
        if (!isLoggedIn) return
        MesiboCall.getInstance().callUi(this, mProfile, false)
    }

    fun onVideoCall(view: View?) {
        if (!isLoggedIn) return
        MesiboCall.getInstance().callUi(this, mProfile, true)
    }

    fun onGroupCall(view: View?) {
        if (!isLoggedIn) return
        val groupId = 0 // set appropriate group id
        if (0 == groupId) return
        MesiboCall.getInstance()
            .groupCallUi(this, Mesibo.getProfile(groupId.toLong()), true, true, true, true)
    }

    fun onSetProfile(view: View?) {
        if (!isLoggedIn) return
        val profile = Mesibo.getSelfProfile() ?: return
        val name = "Joe from Android"
        profile.reset();
        profile.setName(name);
        profile.setString("status", "I am using mesibo");
        profile.save()
    }

    /* Group Management - https://mesibo.com/documentation/api/group-management/ */
    fun onCreateGroup(view: View?) {
        if (!isLoggedIn) return
        val settings = GroupSettings()
        settings.name = "My Group"
        settings.flags = 0
        Mesibo.createGroup(settings, this)
    }

    fun addGroupMembers(profile: MesiboProfile) {
        if (!isLoggedIn) return
        val gp = profile.groupProfile
        val members = arrayOf(mRemoteUser!!.address)
        val mp = MemberPermissions()
        mp.flags = MesiboGroupProfile.MEMBERFLAG_ALL.toLong()
        mp.adminFlags = 0
        gp.addMembers(members, mp)
    }

    fun onSyncContacts(view: View?) {
        if (!isLoggedIn) return
        if(ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) ==
            PackageManager.PERMISSION_GRANTED)  {
            Mesibo.getPhoneContactsManager().start()
            return;
        }

        toast("You MUST request read contact permission before accessing phone contacts")

    }

    fun onPhoneNumberInfo(view: View?) {
        if (!isLoggedIn) return
        val contact =
            Mesibo.getPhoneContactsManager().getPhoneNumberInfo("+18005551234", null, true)
        val name = contact.name
        val phone = contact.formattedPhoneNumber
        val country = contact.country
    }

    val isLoggedIn: Boolean
        get() {
            if (Mesibo.STATUS_ONLINE == Mesibo.getConnectionStatus()) return true
            toast(mLoginPrompt)
            return false
        }

    fun initLocation() {
        val locationConfig = MesiboLocationConfig();
        locationConfig.minDistance = 250;

        val locationManager = MesiboLocationManager.getInstance()
        //locationManager.addListener(this)
        locationManager.start(locationConfig)
    }

    fun getLocation() {
        val profile:MesiboProfile = MesiboProfile.getProfile(mRemoteUser?.address);
        val profileLocation = profile.location();

        val location:MesiboLocation = profileLocation.get();

    }

    fun searchLocation() {
        val profileSearch:MesiboProfileSearch = MesiboProfileSearch();
        profileSearch.setListener(null);
        profileSearch.setDistance(1000); // 1000 meters
        profileSearch.setMaxAge(3600); // 1 hour
        profileSearch.search();
    }


    fun toast(message: String?) {
        val toast = Toast.makeText(applicationContext, message, Toast.LENGTH_LONG)
        //toast.setGravity(Gravity.CENTER_VERTICAL, 0, 0);
        toast.show()
    }

    override fun Mesibo_onConnectionStatus(status: Int) {
        mConnStatus!!.text = "Connection Status: $status"
        if (Mesibo.STATUS_AUTHFAIL == status) {
            mLoginPrompt =
                "The token is invalid. Ensure that you have used appid \"" + Mesibo.getAppIdForAccessToken() + "\" to generate Mesibo user access token"
            toast(mLoginPrompt)
        }
    }

    override fun Mesibo_onMessage(msg: MesiboMessage) {

        /* Messaging documentation https://mesibo.com/documentation/api/messaging/ */
        if (msg.isIncoming) {

            /* Profile documentation https://mesibo.com/documentation/api/users-and-profiles/ */
            val sender = msg.profile

            // check if this message belongs to a group
            /* Group Management - https://mesibo.com/documentation/api/group-management/ */
            if (msg.isGroupMessage) {
                val group = msg.groupProfile
            }

            // check if this message is realtime or read from the database
            if (msg.isRealtimeMessage) {
                toast("You have got a message from " + sender.nameOrAddress + ": " + msg.message)
            }
        } else if (msg.isOutgoing) {

            /* messages you sent */
        } else if (msg.isMissedCall) {
        }
        return
    }

    override fun Mesibo_onMessageStatus(msg: MesiboMessage) {}
    override fun Mesibo_onMessageUpdate(msg: MesiboMessage) {
        toast("You have got a message update: " + msg.message)
    }

    override fun Mesibo_onPresence(presence: MesiboPresence) {
        val name = presence.profile.nameOrAddress
        val typing = if (presence.profile.isTyping) "Typing" else "Not Typing"
        toast("User $name is $typing")
    }

    override fun Mesibo_onPresenceRequest(presence: MesiboPresence) {}

    /* Mesibo Group Listener */
    override fun Mesibo_onGroupCreated(profile: MesiboProfile) {
        toast("New Group Created: " + profile.name)
        addGroupMembers(profile)
    }

    override fun Mesibo_onGroupJoined(profile: MesiboProfile) {}
    override fun Mesibo_onGroupLeft(profile: MesiboProfile) {}
    override fun Mesibo_onGroupMembers(
        profile: MesiboProfile,
        members: Array<MesiboGroupProfile.Member>
    ) {
    }

    override fun Mesibo_onGroupMembersJoined(
        profile: MesiboProfile,
        members: Array<MesiboGroupProfile.Member>
    ) {
    }

    override fun Mesibo_onGroupMembersRemoved(
        profile: MesiboProfile,
        members: Array<MesiboGroupProfile.Member>
    ) {
    }

    override fun Mesibo_onGroupSettings(
        mesiboProfile: MesiboProfile,
        groupSettings: GroupSettings,
        memberPermissions: MemberPermissions,
        groupPins: Array<GroupPin>?
    ) {
    }

    override fun Mesibo_onGroupError(mesiboProfile: MesiboProfile, l: Long) {}

    /* Mesibo Profile Listener */
    override fun Mesibo_onProfileUpdated(profile: MesiboProfile) {
        toast(profile.name + " has updated profile")
    }

    companion object {
        const val TAG = "MesiboFirstApp"
    }
}
