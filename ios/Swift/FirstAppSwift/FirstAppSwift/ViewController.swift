//
//  ViewController.swift
//  FirstAppSwift
//
//  Copyright © 2023 Mesibo. All rights reserved.
//

import UIKit
import mesibo
import MesiboUI
import MesiboCall

class ViewController: UIViewController, MesiboDelegate {
    
    
    @IBOutlet weak var mMessage: UITextField!
    @IBOutlet weak var mLoginUser1: UIButton!
    @IBOutlet weak var mLoginUser2: UIButton!
    @IBOutlet weak var mConnectionStatus: UILabel!
    
    var mRemoteUser: String!
    var mProfile: MesiboProfile!
    var mGroupProfile: MesiboProfile!
    var mUiListener: UIListener!
    var mOnline: Bool!
    
    //Refer to the Get-Started guide to create two users and their access tokens
    var mUser1: [String: String] = [
        "name": "User 1",
        "address": "123",
        "token": "<token-1>"
    ];
    
    var mUser2: [String: String] = [
        "name": "User 2",
        "address": "456",
        "token": "<token-2>"
    ];
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mOnline = false;
        Mesibo.getInstance();
    }
    
    func mesiboInit(_ token: String?, remoteUserAddress address: String?, remoteUserName name: String?) {
        
        Mesibo.getInstance().addListener(self)
        
        // set user authentication token obtained by creating user
        Mesibo.getInstance().setAccessToken(token)
        Mesibo.getInstance().setDatabase("mydb")
        Mesibo.getInstance().e2ee().enable(true)
        Mesibo.getInstance().start()
                
        mLoginUser1.isEnabled = false
        mLoginUser2.isEnabled = false

        // save address for sending messages
        mRemoteUser = address
        
        //set profile which is required by UI
        mProfile = Mesibo.getInstance().getProfile(address, groupid: 0)
        
        /* OPTIONAL - initialize Messaging UI customization listener */
        mUiListener = UIListener();
        MesiboUI.setListener(mUiListener);
        
        /* OPTIONAL - customize various UI defaults */
        let defs = MesiboUI.getUiDefaults()
        defs.emptyUserListMessage = "No messages!"
        defs.enableBackButton = true;
        
        //OPTIONAL, initialize calls
        MesiboCall.start(with: nil, name: "mesibo first app", icon: nil, callKit: true)
        
        // following code will read messages from the database and
        // will also send read receipts for db and real-time messages
        
        // set app mode in foreground for read-receipt to be sent
        Mesibo.getInstance().setAppInForeground(self, screenId: 0, foreground: true)
        
        var session: MesiboReadSession = mProfile.createReadSession(self)
        session.enableReadReceipt(true)
        session.read(100)

    }
    
    func Mesibo_onConnectionStatus(status: Int) {

        // You will receive the connection status here
        
        print("Connection status: \(status)")
        
        let str = "Connection Status: \(status)"
        
        mConnectionStatus.text = str

        if MESIBO_STATUS_AUTHFAIL == status {
            let message = "The token is invalid. Ensure that you have used appid \"\(Mesibo.getInstance().getAppIdForAccessToken())\" to generate Mesibo user access token"

            alert("Invalid Token", message: message, dismiss: false)
        }
        
    }
    
    func Mesibo_onMessage(message: MesiboMessage) {
        
        // A simple example of message processing
        /* Messaging documentation https://mesibo.com/documentation/api/messaging/ */
        if(message.isIncoming()) {
            
            /* Profile documentation https://mesibo.com/documentation/api/users-and-profiles/ */
            var sender: MesiboProfile = message.profile!;
            
            /* Group Management - https://mesibo.com/documentation/api/group-management/ */
            // check if this message belongs to a group
            if(message.isGroupMessage()) {
                var group: MesiboProfile = message.groupProfile!;
            }
            
            // check if this message is realtime or read from the database
            if (message.isRealtimeMessage()) {
                alert("New Message", message: message.message)
            }
        }
    }
    
    func Mesibo_onMessageUpdate(message: MesiboMessage) {
        
    }
    
    func Mesibo_onMessageStatus(message: MesiboMessage) {
        
        let status = message.getStatus()
    }
    
    @IBAction func onSendMessage(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        let msg = mProfile.newMessage();
        msg.message = "Hello from iOS, Swift"
        msg.send()
        
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
    
    @IBAction func onShowUsersList(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        
        var opts:MesiboUserListScreenOptions = MesiboUserListScreenOptions();
        MesiboUI.launchUserList(self, opts:opts)
    }

    
    @IBAction func onShowMessages(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        
        var opts:MesiboMessageScreenOptions = MesiboMessageScreenOptions();
        opts.profile = mProfile;
        opts.navigation = true;
        MesiboUI.launchMessaging(self, opts:opts)
        
    }
    
    @IBAction func onAudioCall(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        MesiboCall.getInstance().callUi(self, profile: mProfile, video: false)
        
    }
    
    @IBAction func onVideoCall(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        MesiboCall.getInstance().callUi(self, profile: mProfile, video: true)
    }
    
    @IBAction func onSetProfile(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        let sp = Mesibo.getInstance().getSelfProfile()
        sp.setName("Joe from Swift")
        sp.setString("status", value:"I am using mesibo iOS first app")
        sp.save()
    }
    
    /* Group Management - https://mesibo.com/documentation/api/group-management/ */
    @IBAction func onCreateGroup(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        
        let gs:MesiboGroupSettings = MesiboGroupSettings();
        gs.name = "My First Group";
        gs.flags = 0;
        
        Mesibo.getInstance().createGroup(gs, listener: self)
        
    }
    
    func addMembers(_ profile: MesiboProfile?) {
        var members: [AnyHashable] = []
        members.append(mRemoteUser)
        
        let gp = profile?.getGroupProfile()
        let mp:MesiboMemberPermissions = MesiboMemberPermissions();
        mp.flags = UInt32(MESIBO_MEMBERFLAG_ALL);
        mp.adminFlags = 0;
        gp?.addMembers(members, permissions:mp)
    }
    
    @IBAction func GetGroupMembers(_ sender: Any) {
        //var profile = Mesibo.getInstance()?.getGroupProfile(2340288);
        //mGroupProfile = profile;
        if(mGroupProfile == nil) {
            return;
        }
        
        mGroupProfile.getGroupProfile()?.getMembers(100, restart: false, listener: self)
    }
    
    @IBAction func LeaveGroup(_ sender: Any) {
        if(mGroupProfile == nil) {
            return;
        }
        
        mGroupProfile.getGroupProfile()?.leave();
    }
    
    @IBAction func onGroupCall(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        
        var groupId: UInt32 = 0; // set appropriate groupId
        if(0 == groupId) {
            return;
        }
        
        var groupProfile:MesiboProfile = Mesibo.getInstance().getGroupProfile(groupId);
        
        MesiboCall.getInstance().groupCallUi(self, profile: groupProfile, video: true, audio: true, videoMute: true, audioMute: true, publish: true);
    }
    
    
    func mesibo_(onGroupCreated profile: MesiboProfile?) {
        alert("New Group Created", message: profile?.getName())
        
        mGroupProfile = profile
        // add members to the group
        addMembers(profile)
    }
    
    func mesibo_(onGroupJoined groupProfile: MesiboProfile!) {
        
    }
    
    func mesibo_(onGroupLeft groupProfile: MesiboProfile!) {
        alert("New Group Left", message: groupProfile?.getName())
    }

    
    func mesibo_(onGroupError groupProfile: MesiboProfile!, error: UInt32) {
        
    }
    
    
    func mesibo_(onGroupMembers groupProfile: MesiboProfile!, members: [Any]!) {
        alert("members", message: "something")
    }
        
    
    func mesibo_(onProfileUpdated profile: MesiboProfile) {
        alert("Profile Updated", message: profile.getName())
    }
    
    @IBAction func onPhoneContactsSync(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        Mesibo.getInstance().getPhoneContactsManager().start();
    }
    
    @IBAction func onPhoneNumberInfo(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        var contact: MesiboPhoneContact = Mesibo.getInstance().getPhoneContactsManager().getPhoneNumberInfo("+18005551234", code: nil, format: true);
        var name: String = contact.name ?? "";
        var phone: String = contact.formattedPhoneNumber ?? "";
        var country: String = contact.country ?? "";
        
    }
    
    func alert(_ title: String?, message: String?, dismiss: Bool) {

        let avc = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

        present(avc, animated: true)

        if !dismiss {
            return
        }

        let duration = 2

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Double(duration) * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
            avc.dismiss(animated: true)
        })
    }

    func alert(_ title: String?, message: String?) {
        alert(title, message: message, dismiss: true)
    }
    
}

