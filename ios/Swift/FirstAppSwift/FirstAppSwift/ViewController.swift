//
//  ViewController.swift
//  FirstAppSwift
//
//  Copyright © 2020 Mesibo. All rights reserved.
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

    var mRemoteUser: String!
    var mProfile: MesiboUserProfile!
    var mReadSession: MesiboReadSession!
    
    //Refer to the Get-Started guide to create two users and their access tokens
    var mUser1: [String: String] = [
            "name": "User 1",
            "address": "123",
            "token": "xyz"
    ];
    
    var mUser2: [String: String] = [
            "name": "User 2",
            "address": "456",
            "token": "pqr"
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
        
        Mesibo.getInstance()!.setSecureConnection(true)
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
        mProfile = MesiboUserProfile()
        mProfile.name = name
        mProfile.address = address
        Mesibo.getInstance()!.setProfile(mProfile, refresh: false)
        
        //OPTIONAL, initialize calls
        MesiboCall.start(with: nil, name: "mesibo first app", icon: nil, callKit: true)
        
        // following code will read messages from the database and
        // will also send read receipts for db and real-time messages
        
        // set app mode in foreground for read-receipt to be sent
        Mesibo.getInstance()!.setAppInForeground(self, screenId: 0, foreground: true)
        
        mReadSession = MesiboReadSession()
        mReadSession.initSession(mRemoteUser, groupid: 0, query: nil, delegate: self)
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
               alert(message)
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
        let params = MesiboParams()
        params.peer = mRemoteUser
        params.flag = (UInt32)(MESIBO_FLAG_READRECEIPT | MESIBO_FLAG_DELIVERYRECEIPT)

        let mid = Mesibo.getInstance()!.random()
        Mesibo.getInstance()!.sendMessage(params, msgid: mid, string: mMessage.text)
        mMessage.text = ""
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
    
    
    @IBAction func onLaunchMesiboUi(_ sender: Any) {
    }
    
    @IBAction func onAudioCall(_ sender: Any) {
        MesiboCall.getInstance().callUi(self, address: mRemoteUser, video: false)

    }
    
    @IBAction func onVideoCall(_ sender: Any) {
        MesiboCall.getInstance().callUi(self, address: mRemoteUser, video: true)
    }
    
    func mesiboCall_(onNotifyIncoming type: Int32, profile: MesiboUserProfile!, video: Bool) -> Bool {
        return true
    }
    
    func mesiboCall_(onShowViewController parent: Any?, vc: Any?) {
        var parent = parent

        let uvc = vc as? UIViewController


        if uvc?.isBeingPresented ?? false {
            return
        }

        if parent == nil {
            parent = self
        }

        let p = parent as? UIViewController
        
        Mesibo.getInstance()!.run(inThread: true, handler: {
            if let uvc = uvc {
                p?.present(uvc, animated: true)
            }
        })

    }

    func mesiboCall_(onDismissViewController vc: Any?) {
    }
    
    func alert(_ message: String?) {
        let vc = UIAlertController(title: "New Message", message: message , preferredStyle: .actionSheet)
        present(vc, animated: true) {
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (_) in
                vc.dismiss(animated: true, completion: nil)})
            
        }
    }
}

