//
//  ViewController.swift
//  FirstAppSwift
//
//  Copyright © 2021 Mesibo. All rights reserved.
//

import UIKit
import mesibo
import MesiboUI
import MesiboCall

class ViewController: UIViewController, MesiboDelegate {
    
    
    @IBOutlet weak var mMessage: UITextField!
    @IBOutlet weak var mLoginUser1: UIButton!
    @IBOutlet weak var mLoginUser2: UIButton!
    @IBOutlet weak var mAudioCallButton: UIButton!
    @IBOutlet weak var mConnectionStatus: UILabel!
    @IBOutlet weak var mMessageStatus: UILabel!
    @IBOutlet weak var mUiButton: UIButton!
    @IBOutlet weak var mVideoCallButton: UIButton!
    @IBOutlet weak var mName: UITextField!
    
    var mRemoteUser: String!
    var mProfile: MesiboProfile!
    var mReadSession: MesiboReadSession!
    
    //Refer to the Get-Started guide to create two users and their access tokens
    var mUser1: [String: String] = [
        "name": "User 1",
        "address": "123",
        "token": "<token-1>"
    ];
    
    var mUser2: [String: String] = [
        "name": "User 2",
        "address": "456",
        "token": "<token-1>"
    ];
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mAudioCallButton.isEnabled = false;
        mVideoCallButton.isEnabled = false;
        mUiButton.isEnabled = false;
    }
    
    func mesiboInit(_ token: String?, remoteUserAddress address: String?, remoteUserName name: String?) {
        
        Mesibo.getInstance()!.addListener(self)
        
        // set user authentication token obtained by creating user
        Mesibo.getInstance()!.setAccessToken(token)
        Mesibo.getInstance()!.setDatabase("mydb", resetTables: 0)
        Mesibo.getInstance()!.start()
        
        
        mLoginUser1.isEnabled = false
        mLoginUser2.isEnabled = false
        
        mUiButton.isEnabled = true
        mAudioCallButton.isEnabled = true
        mVideoCallButton.isEnabled = true
        
        // save address for sending messages
        mRemoteUser = address
        
        //set profile which is required by UI
        mProfile = Mesibo.getInstance()?.getProfile(address, groupid: 0)
        
        var name: String = mProfile.getName();
        var image: UIImage = mProfile.getThumbnail()
        
        
        //OPTIONAL, initialize calls
        MesiboCall.start(with: nil, name: "mesibo first app", icon: nil, callKit: true)
        
        // following code will read messages from the database and
        // will also send read receipts for db and real-time messages
        
        // set app mode in foreground for read-receipt to be sent
        Mesibo.getInstance()!.setAppInForeground(self, screenId: 0, foreground: true)
        
        mReadSession = mProfile.createReadSession(self)
        mReadSession.enableReadReceipt(true)
        mReadSession.read(100)
    }
    
    public func mesibo_(onConnectionStatus status: Int32) {
        // You will receive the connection status here
        
        print("Connection status: \(status)")
        
        let str = "Connection Status: \(status)"
        
        mConnectionStatus.text = str
        
    }
    
    func mesibo_(onMessage params: MesiboParams?, data: Data?) {
        
        // You will receive messages here
        var message: String? = nil
        if let data = data {
            message = String(data: data, encoding: .utf8)
        }
        
        if MESIBO_ORIGIN_REALTIME == params?.origin && 0 == params?.type {
            alert("New Message", message: message)
        }
        
    }
    
    func mesibo_(on message: MesiboMessage?) {
    }
    
    func mesibo_(onMessageStatus params: MesiboParams?) {
        
        var str: String? = nil
        if let status = params?.status {
            str = "Message Status: \(status)"
        }
        
        mMessageStatus.text = str
        
    }
    
    @IBAction func onSendMessage(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        let mid = Mesibo.getInstance()!.random()
        mProfile!.sendMessage(mid, string: mMessage.text)
        mMessage.text = ""
        mMessage.resignFirstResponder()
    }
    
    @IBAction func onLaunchMessagingUIModule(_ sender: Any) {
        //requires pod mesibo-ui
        MesiboUI.launchMessageViewController(self, profile: mProfile)
    }
    
    // login as user-1 and take user-2 as the destination
    @IBAction func onLoginUser1(_ sender: Any) {
        mesiboInit(mUser1["token"], remoteUserAddress: mUser2["address"], remoteUserName: mUser2["name"])
    }
    
    // login as user-2 and take user-1 as the destination
    @IBAction func onLoginUser2(_ sender: Any) {
        mesiboInit(mUser2["token"], remoteUserAddress: mUser1["address"], remoteUserName: mUser1["name"])
    }
    
    func isLoggedIn() -> Bool {
        if MESIBO_STATUS_ONLINE == Mesibo.getInstance().getConnectionStatus() {
            return true
        }
        alert("Not Logged-In", message: "Login with a valid token first")
        return false
    }
    
    
    @IBAction func onLaunchMesiboUi(_ sender: Any) {
    }
    
    @IBAction func onAudioCall(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        MesiboCall.getInstance().callUi(self, address: mRemoteUser, video: false)
        
    }
    
    @IBAction func onVideoCall(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        MesiboCall.getInstance().callUi(self, address: mRemoteUser, video: true)
    }
    
    @IBAction func onProfileUpdate(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        let sp = Mesibo.getInstance().getSelfProfile()
        sp?.setName(mName.text)
        sp?.setStatus("I am using mesibo iOS first app")
        sp?.save()
        mName.text = ""
        mName.resignFirstResponder()
    }
    
    @IBAction func onCreateGroup(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        Mesibo.getInstance().createGroup("My First Group", flags: 0, listener: self)
        
    }
    
    func addMembers(_ profile: MesiboProfile?) {
        var members: [AnyHashable] = []
        members.append(mRemoteUser)
        
        let gp = profile?.getGroupProfile()
        gp?.addMembers(members, permissions: UInt32(MESIBO_MEMBERFLAG_ALL), adminPermissions: 0)
    }
    
    func mesibo_(onGroupCreated profile: MesiboProfile?) {
        alert("New Group Created", message: profile?.getName())
        
        // add members to the group
        addMembers(profile)
    }
    
    func mesibo_(onProfileUpdated profile: MesiboProfile?) {
        alert("Profile Updated", message: profile?.getName())
    }
    
    
    func alert(_ title: String?, message: String?) {
        
        let avc = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        present(avc, animated: true)
        
        let duration = 2
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Double(duration) * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
            avc.dismiss(animated: true)
        })
    }
}

