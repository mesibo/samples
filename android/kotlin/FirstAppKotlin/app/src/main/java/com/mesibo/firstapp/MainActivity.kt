package com.mesibo.firstapp

import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import com.mesibo.api.Mesibo
import com.mesibo.calls.api.MesiboCall

import com.mesibo.messaging.MesiboUI


class MainActivity : AppCompatActivity(), Mesibo.ConnectionListener, Mesibo.MessageListener {

    internal inner class DemoUser(var token: String, var name: String, var address: String)

    //Refer to the Get-Started guide to create two users and their access tokens
    internal var mUser1 = DemoUser("xyz", "User-1", "123")
    internal var mUser2 = DemoUser("pqr", "User-2", "456")

    internal var mRemoteUser: DemoUser? = null

    var mProfile: Mesibo.UserProfile? = null
    var mReadSession: Mesibo.ReadDbSession? = null
    var mLoginButton1: View? = null
    var mLoginButton2: View? = null
    var mSendButton: Button? = null
    var mUiButton: View? = null
    var mAudioCallButton: View? = null
    var mVideoCallButton: View? = null
    var mMessageStatus: TextView? = null
    var mConnStatus: TextView? = null
    var mMessage: EditText? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        mLoginButton1 = findViewById(R.id.login1)
        mLoginButton2 = findViewById(R.id.login2)
        mSendButton = findViewById(R.id.send)
        mUiButton = findViewById(R.id.launchUI)
        mAudioCallButton = findViewById(R.id.audioCall)
        mVideoCallButton = findViewById(R.id.videoCall)
        mMessageStatus = findViewById(R.id.msgStatus)
        mConnStatus = findViewById(R.id.connStatus)
        mMessage = findViewById(R.id.message)

        mSendButton?.setEnabled(false)
        mUiButton?.setEnabled(false)
        mAudioCallButton?.setEnabled(false)
        mVideoCallButton?.setEnabled(false)
    }

    private fun mesiboInit(user: DemoUser, remoteUser: DemoUser) {
        val api: Mesibo = Mesibo.getInstance()
        api.init(applicationContext)
        Mesibo.addListener(this)
        Mesibo.setSecureConnection(true)
        Mesibo.setAccessToken(user.token)
        Mesibo.setDatabase("mydb", 0)
        Mesibo.start()

        mRemoteUser = remoteUser
        mProfile = Mesibo.UserProfile()
        mProfile?.address = remoteUser.address
        mProfile?.name = remoteUser.name
        Mesibo.setUserProfile(mProfile, false)

        // disable login buttons
        mLoginButton1!!.isEnabled = false
        mLoginButton2!!.isEnabled = false

        // enable buttons
        mSendButton!!.isEnabled = true
        mUiButton!!.isEnabled = true
        mAudioCallButton!!.isEnabled = true
        mVideoCallButton!!.isEnabled = true
        MesiboCall.getInstance().init(applicationContext)

        // Read receipts are enabled only when App is set to be in foreground
        Mesibo.setAppInForeground(this, 0, true)
        mReadSession = Mesibo.ReadDbSession(mRemoteUser!!.address, this)
        mReadSession?.enableReadReceipt(true)
        mReadSession?.read(100)
    }

    fun onLoginUser1(view: View?) {
        mesiboInit(mUser1, mUser2)
    }

    fun onLoginUser2(view: View?) {
        mesiboInit(mUser2, mUser1)
    }

    fun onSendMessage(view: View?) {
        val p: Mesibo.MessageParams = Mesibo.MessageParams()
        p.peer = mRemoteUser!!.address
        p.flag = Mesibo.FLAG_READRECEIPT or Mesibo.FLAG_DELIVERYRECEIPT
        Mesibo.sendMessage(p, Mesibo.random(), mMessage!!.text.toString().trim { it <= ' ' })
        mMessage!!.setText("")
    }

    fun onLaunchMessagingUi(view: View?) {
        MesiboUI.launchMessageView(this, mRemoteUser!!.address, 0)
    }

    fun onAudioCall(view: View?) {
        MesiboCall.getInstance().callUi(this, mProfile!!.address, false)
    }

    fun onVideoCall(view: View?) {
        MesiboCall.getInstance().callUi(this, mProfile!!.address, true)
    }

    override fun Mesibo_onConnectionStatus(status: Int) {
        mConnStatus!!.text = "Connection Status: $status"
    }

    override fun Mesibo_onMessage(messageParams: Mesibo.MessageParams?, data: ByteArray?): Boolean {
        try {
            val message = String(data!!)
            val toast = Toast.makeText(applicationContext,
                    message,
                    Toast.LENGTH_SHORT)
            toast.setGravity(Gravity.CENTER_VERTICAL, 0, 0)
            toast.show()
        } catch (e: Exception) {
        }
        return true
    }

    override fun Mesibo_onMessageStatus(messageParams: Mesibo.MessageParams) {
        mMessageStatus!!.text = "Message Status: " + messageParams.getStatus()
    }

    override fun Mesibo_onActivity(messageParams: Mesibo.MessageParams?, i: Int) {}
    override fun Mesibo_onLocation(messageParams: Mesibo.MessageParams?, location: Mesibo.Location?) {}
    override fun Mesibo_onFile(messageParams: Mesibo.MessageParams?, fileInfo: Mesibo.FileInfo?) {}

}
