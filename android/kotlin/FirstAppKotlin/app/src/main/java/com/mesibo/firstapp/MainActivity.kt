package com.mesibo.firstapp

import android.os.Bundle
import android.view.View
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.mesibo.api.*
import com.mesibo.api.Mesibo.GroupListener
import com.mesibo.api.Mesibo.ProfileListener
import com.mesibo.calls.api.MesiboCall
import com.mesibo.messaging.MesiboUI


class MainActivity : AppCompatActivity(), Mesibo.ConnectionListener, Mesibo.MessageListener,
    ProfileListener, GroupListener {

    internal inner class DemoUser(var token: String, var name: String, var address: String)

    /* Refer to the Get-Started guide to create two users and their access tokens
     * https://mesibo.com/documentation/tutorials/get-started/
     */
    internal var mUser1 = DemoUser("<token-1>>", "User-1", "123")
    internal var mUser2 = DemoUser("<token-2>", "User-2", "456")

    internal var mRemoteUser: DemoUser? = null

    lateinit var mProfile: MesiboProfile;
    var mLoginButton1: View? = null
    var mLoginButton2: View? = null

    var mMessageStatus: TextView? = null
    var mConnStatus: TextView? = null
    var mMessage: EditText? = null
    var mName: EditText? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        mLoginButton1 = findViewById(R.id.login1)
        mLoginButton2 = findViewById(R.id.login2)

        mMessageStatus = findViewById(R.id.msgStatus)
        mConnStatus = findViewById(R.id.connStatus)
        mMessage = findViewById(R.id.message)
   //     mName = findViewById(R.id.name)

    }

    private fun mesiboInit(user: DemoUser, remoteUser: DemoUser) {
        val api = Mesibo.getInstance()
        api.init(applicationContext)
        Mesibo.addListener(this)
        Mesibo.setAccessToken(user.token)
        Mesibo.setDatabase("mydb", 0)
        Mesibo.start()

        mRemoteUser = remoteUser
        mProfile = Mesibo.getProfile(remoteUser.address)
        mProfile.setName(remoteUser.name)
        mProfile.save()


        // disable login buttons
        mLoginButton1!!.isEnabled = false
        mLoginButton2!!.isEnabled = false

        // Read receipts are enabled only when App is set to be in foreground
        Mesibo.setAppInForeground(this, 0, true)
        var readSession = mProfile.createReadSession(this)
        readSession.enableReadReceipt(true)
        readSession.read(100)

        /* initialize call with custom title */

        /* initialize call with custom title */
        MesiboCall.getInstance().init(applicationContext)
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

    fun onSendMessage(view: View?) {
        if (!isLoggedIn()) return
        val msg = mProfile.newMessage();

        msg.message = mMessage!!.text.toString().trim { it <= ' ' };
        msg.send()
    }

    fun onLaunchMessagingUi(view: View?) {
        if (!isLoggedIn()) return
        MesiboUI.launchMessageView(this, mProfile)
    }

    fun onAudioCall(view: View?) {
        if (!isLoggedIn()) return
        MesiboCall.getInstance().callUi(this, mProfile, false)
    }

    fun onVideoCall(view: View?) {
        if (!isLoggedIn()) return
        MesiboCall.getInstance().callUi(this, mProfile, true)
    }

    fun onUpdateProfile(view: View?) {
        if (!isLoggedIn()) return
        val profile = Mesibo.getSelfProfile() ?: return
        val name: String = mName?.getText().toString().trim({ it <= ' ' })
        profile.name = name
        profile.status = "I am using mesibo"
        profile.save()
    }

    fun onCreateGroup(view: View?) {
        if (!isLoggedIn()) return
        var settings:MesiboGroupProfile.GroupSettings = MesiboGroupProfile.GroupSettings()
        settings.name = "My Group"
        settings.flags = 0
        Mesibo.createGroup(settings, this)
    }

    fun addGroupMembers(profile: MesiboProfile) {
        if (!isLoggedIn()) return
        val gp = profile.groupProfile
        val members = arrayOf(mRemoteUser!!.address)
        var mp: MesiboGroupProfile.MemberPermissions = MesiboGroupProfile.MemberPermissions();
        mp.flags = MesiboGroupProfile.MEMBERFLAG_ALL.toLong()
        mp.adminFlags = 0;
        gp.addMembers(members, mp)
    }

    fun isLoggedIn(): Boolean {
        if (Mesibo.STATUS_ONLINE == Mesibo.getConnectionStatus()) return true
        toast("Login with a valid token first")
        return false
    }

    fun toast(message: String?) {
        val toast = Toast.makeText(applicationContext, message, Toast.LENGTH_SHORT)
        toast.show()
    }

    override fun Mesibo_onConnectionStatus(status: Int) {
        mConnStatus!!.text = "Connection Status: $status"
    }

    override fun Mesibo_onMessage(msg: MesiboMessage) {

    }

    override fun Mesibo_onMessageUpdate(msg: MesiboMessage) {
    }

    override fun Mesibo_onMessageStatus(msg: MesiboMessage) {
        mMessageStatus!!.text = "Message Status: " + msg.getStatus()
    }

    override fun Mesibo_onProfileUpdated(profile: MesiboProfile) {
        toast(profile.getName() + " has updated profile")
    }

    override fun Mesibo_onGetProfile(profile: MesiboProfile): Boolean {
        return false;
    }

    override fun Mesibo_onGroupCreated(profile: MesiboProfile) {
        toast("New Group Created: " + profile.name)
        addGroupMembers(profile)
    }

    override fun Mesibo_onGroupJoined(profile: MesiboProfile) {
    }

    override fun Mesibo_onGroupLeft(profile: MesiboProfile) {
    }

    override fun Mesibo_onGroupMembers(
        profile: MesiboProfile,
        members: Array<out MesiboGroupProfile.Member>?
    ) {
    }

    override fun Mesibo_onGroupMembersJoined(
        profile: MesiboProfile,
        members: Array<out MesiboGroupProfile.Member>?
    ) {
    }

    override fun Mesibo_onGroupMembersRemoved(
        profile: MesiboProfile,
        members: Array<out MesiboGroupProfile.Member>?
    ) {
    }

    override fun Mesibo_onGroupSettings(
        p0: MesiboProfile?,
        p1: MesiboGroupProfile.GroupSettings?,
        p2: MesiboGroupProfile.MemberPermissions?,
        p3: Array<out MesiboGroupProfile.GroupPin>?
    ) {

    }

    override fun Mesibo_onGroupError(p0: MesiboProfile?, p1: Long) {

    }
}
