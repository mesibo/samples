//
//  ViewController.swift
//  FirstAppSwift
//
//  Copyright © 2026 Mesibo. All rights reserved.
//
//  This demo application implements real-time messaging, calls, and conferencing in an iOS
//  application. Please refer to the tutorial for details on getting started and obtaining the
//  user tokens:
//
//  https://docs.mesibo.com/tutorials/get-started/
//

import UIKit
import mesibo
import MesiboUI
import MesiboCall

/*************************************************************************************************
 Set the tokens of the two users here: create the users in the mesibo console with the addresses
 below and the App ID com.mesibo.firstapp (the bundle id of this app), and copy their tokens.
 Install the app on two devices, and log in as User-1 on one and as User-2 on the other.
 *************************************************************************************************/
let USER1_TOKEN = "<token-1>"
let USER1_ADDRESS = "123"
let USER2_TOKEN = "<token-2>"
let USER2_ADDRESS = "456"

let TUTORIAL_URL = "https://docs.mesibo.com/tutorials/get-started/"


// MARK: - welcome screen

/* What this demo does and what to do before using it; shown until the tokens are set. */
class WelcomeViewController: UIViewController {

    private func label(_ text: String, size: CGFloat, bold: Bool = false) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.textColor = .label
        label.font = bold ? .boldSystemFont(ofSize: size) : .systemFont(ofSize: size)
        return label
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // the tutorial link
        let tutorialLink = UIButton(type: .system)
        tutorialLink.setTitle(TUTORIAL_URL, for: .normal)
        tutorialLink.contentHorizontalAlignment = .left
        tutorialLink.titleLabel?.font = .systemFont(ofSize: 16)
        tutorialLink.addTarget(self, action: #selector(onTutorial), for: .touchUpInside)

        let continueButton = UIButton(type: .system)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        continueButton.addTarget(self, action: #selector(onContinue), for: .touchUpInside)

        // the texts, the link and the button, top to bottom
        let tutorialLabel = label("Refer to the tutorial for instructions:", size: 16)

        let stack = UIStackView(arrangedSubviews: [
            label("Welcome to your first mesibo app", size: 24, bold: true),
            label("This demo shows you how to add messaging, voice and video calls to your apps in just a few lines of code.", size: 16),
            label("To use this demo, log in to the mesibo console, create two users, set their tokens in ViewController, and run the app on two phones.", size: 16),
            tutorialLabel,
            tutorialLink,
            continueButton,
        ])

        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(4, after: tutorialLabel)
        stack.setCustomSpacing(32, after: tutorialLink)

        // scrollable, for small screens and large text sizes
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        view.addSubview(scrollView)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 40),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),
        ])
    }

    @objc private func onTutorial() {
        guard let url = URL(string: TUTORIAL_URL) else { return }
        UIApplication.shared.open(url)
    }

    @objc private func onContinue() {
        // nothing to do in the demo without the tokens
        if !ViewController.areTokensSet() {
            MesiboDialogs.alert(self, title: "Tokens not set",
                                message: "You have not set the tokens in the code yet. Set USER1_TOKEN and USER2_TOKEN in ViewController, and run the app again.")
            return
        }

        dismiss(animated: true)
    }
}


// MARK: - demo screen

class ViewController: UIViewController, MesiboDelegate, MesiboCallIncomingListener,
                      MesiboLocationListener, MesiboProfileSearchListener {

    @IBOutlet weak var mLoginUser1: UIButton!
    @IBOutlet weak var mLoginUser2: UIButton!
    @IBOutlet weak var mConnectionStatus: UILabel!

    private var remoteUser: String?
    private var profile: MesiboProfile?
    private var groupProfile: MesiboProfile?
    private var uiListener: UIListener?
    private var readSession: MesiboReadSession?
    private var welcomeShown = false

    // the group for the group call button (0: not set)
    private var groupCallId: UInt32 = 0

    /** true when USER1_TOKEN and USER2_TOKEN are set */
    static func areTokensSet() -> Bool {
        return !USER1_TOKEN.hasPrefix("<") && !USER2_TOKEN.hasPrefix("<")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // what to do before using the demo
        if !welcomeShown && !ViewController.areTokensSet() {
            welcomeShown = true

            let welcome = WelcomeViewController()
            welcome.modalPresentationStyle = .fullScreen
            present(welcome, animated: false)
        }
    }


    // MARK: - start

    func mesiboInit(token: String, remoteUserAddress address: String) {
        if !ViewController.areTokensSet() {
            alert("Tokens not set", message: "Set USER1_TOKEN and USER2_TOKEN in ViewController first", dismiss: false)
            return
        }

        Mesibo.getInstance().addListener(self)

        // set the user's access token, obtained when creating the user
        Mesibo.getInstance().setAccessToken(token)
        Mesibo.getInstance().setDatabase("mydb")
        Mesibo.getInstance().e2ee().enable(true)
        Mesibo.getInstance().start()

        mLoginUser1.isEnabled = false
        mLoginUser2.isEnabled = false

        // the other user, to send messages and calls to
        remoteUser = address
        profile = Mesibo.getInstance().getProfile(address, groupid: 0)

        // OPTIONAL - the messaging UI customization listener
        uiListener = UIListener()

        // OPTIONAL - customize the UI defaults
        let defaults = MesiboUI.getUiDefaults()
        defaults.emptyUserListMessage = "No messages!"
        defaults.enableBackButton = true

        // OPTIONAL - calls; self: incoming calls go to the MesiboCallIncomingListener methods below
        MesiboCall.start(with: self, name: "mesibo first app", icon: nil, callKit: true)

        // Read messages from the database; this also sends read receipts for database and
        // real-time messages. Read receipts are sent only while the app is in the foreground.
        Mesibo.getInstance().setAppInForeground(self, screenId: 0, foreground: true)
        readSession = profile?.createReadSession(self)
        readSession?.enableReadReceipt(true)
        readSession?.read(100)
    }

    // login as user 1, and send messages and calls to user 2
    @IBAction func onLoginUser1(_ sender: Any) {
        mesiboInit(token: USER1_TOKEN, remoteUserAddress: USER2_ADDRESS)
    }

    // login as user 2, and send messages and calls to user 1
    @IBAction func onLoginUser2(_ sender: Any) {
        mesiboInit(token: USER2_TOKEN, remoteUserAddress: USER1_ADDRESS)
    }

    private func isLoggedIn() -> Bool {
        if Mesibo.getInstance().getConnectionStatus() == MESIBO_STATUS_ONLINE {
            return true
        }
        alert("Not Logged-In", message: "Login with a valid token first")
        return false
    }


    // MARK: - MesiboDelegate

    func Mesibo_onConnectionStatus(status: Int) {
        print("Connection status: \(status)")
        mConnectionStatus.text = "Connection Status: \(status)"

        if status == MESIBO_STATUS_AUTHFAIL {
            let message = "The token is invalid. Ensure that you have used appid \"\(Mesibo.getInstance().getAppIdForAccessToken())\" to generate Mesibo user access token"
            alert("Invalid Token", message: message, dismiss: false)
        }
    }

    /* Messaging documentation: https://mesibo.com/documentation/api/messaging/ */
    func Mesibo_onMessage(message: MesiboMessage) {
        if !message.isIncoming() {
            return
        }

        /* Profile documentation: https://mesibo.com/documentation/api/users-and-profiles/ */
        if let sender = message.profile {
            print("Message from \(sender.getNameOrAddress())")
        }

        /* Group management: https://mesibo.com/documentation/api/group-management/ */
        if message.isGroupMessage(), let group = message.groupProfile {
            print("in the group \(group.getName() ?? "")")
        }

        // a real-time message, not one read from the database
        if message.isRealtimeMessage() {
            alert("New Message", message: message.message)
        }
    }

    func Mesibo_onMessageUpdate(message: MesiboMessage) {
    }

    func Mesibo_onMessageStatus(message: MesiboMessage) {
        print("Message \(message.mid) status: \(message.getStatus())")
    }

    func Mesibo_onProfileUpdated(profile: MesiboProfile) {
        alert("Profile Updated", message: profile.getName())
    }


    // MARK: - messages, profile, UI and calls

    @IBAction func onSendMessage(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        guard let message = profile?.newMessage() else { return }
        message.message = "Hello from iOS, Swift"
        message.send()
    }

    @IBAction func onSetProfile(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        let me = Mesibo.getInstance().getSelfProfile()
        me.setName("Joe from Swift")
        me.setString("status", value: "I am using mesibo iOS first app")
        me.save()
    }

    @IBAction func onShowUsersList(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        MesiboUI.launchUserList(self, opts: MesiboUserListScreenOptions())
    }

    @IBAction func onShowMessages(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        // pushed when this screen is in a navigation controller, else presented
        let options = MesiboMessageScreenOptions()
        options.profile = profile
        MesiboUI.launchMessaging(self, opts: options)
    }

    /* ensure to grant the background mode and microphone permissions */
    @IBAction func onAudioCall(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        guard let profile = profile else { return }
        MesiboCall.getInstance().callUi(self, profile: profile, video: false)
    }

    @IBAction func onVideoCall(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        guard let profile = profile else { return }
        MesiboCall.getInstance().callUi(self, profile: profile, video: true)
    }

    @IBAction func onGroupCall(_ sender: Any) {
        if !isLoggedIn() {
            return
        }

        // set groupCallId (top of this class) to the group to call
        if groupCallId == 0 {
            alert("Group Call", message: "Set groupCallId to the group to call")
            return
        }

        let group = Mesibo.getInstance().getGroupProfile(groupCallId)
        MesiboCall.getInstance().groupCallUi(self, profile: group, video: true, audio: true,
                                             videoMute: true, audioMute: true, publish: true)
    }


    // MARK: - groups (https://mesibo.com/documentation/api/group-management/)

    @IBAction func onCreateGroup(_ sender: Any) {
        if !isLoggedIn() {
            return
        }

        let settings = MesiboGroupSettings()
        settings.name = "My First Group"
        settings.flags = 0

        // Mesibo_onGroupCreated is called when the group is created
        Mesibo.getInstance().createGroup(settings, listener: self)
    }

    private func addMembers(_ group: MesiboProfile) {
        guard let remoteUser = remoteUser else { return }

        let permissions = MesiboMemberPermissions()
        permissions.flags = UInt32(MESIBO_MEMBERFLAG_ALL)
        permissions.adminFlags = 0
        group.getGroupProfile()?.addMembers([remoteUser], permissions: permissions)
    }

    func Mesibo_onGroupCreated(groupProfile: MesiboProfile) {
        alert("New Group Created", message: groupProfile.getName())
        self.groupProfile = groupProfile
        addMembers(groupProfile)
    }

    func Mesibo_onGroupJoined(groupProfile: MesiboProfile) {
    }

    func Mesibo_onGroupLeft(groupProfile: MesiboProfile) {
        alert("Group Left", message: groupProfile.getName())
    }

    func Mesibo_onGroupError(groupProfile: MesiboProfile, error: UInt32) {
        print("Group error \(error) for \(groupProfile.getName() ?? "")")
    }

    func Mesibo_onGroupMembers(groupProfile: MesiboProfile, members: [MesiboGroupMember]) {
        alert("Group Members", message: "\(groupProfile.getName() ?? "") has \(members.count) members")
    }

    @IBAction func GetGroupMembers(_ sender: Any) {
        groupProfile?.getGroupProfile()?.getMembers(100, restart: false, listener: self)
    }

    @IBAction func LeaveGroup(_ sender: Any) {
        groupProfile?.getGroupProfile()?.leave()
    }


    // MARK: - MesiboCallIncomingListener

    /** an incoming call: return its properties (customize them here), or nil to reject it */
    func MesiboCall_OnIncoming(profile: MesiboProfile, video: Bool, waiting: Bool) -> MesiboCallProperties? {
        return MesiboCall.getInstance().createCallProperties(video)
    }

    /** return true to show your own call screen instead of mesibo's */
    func MesiboCall_OnShowUserInterface(call: Any?, properties cp: MesiboCallProperties?) -> Bool {
        return false
    }

    /** a call notification (e.g. MESIBOCALL_NOTIFY_MISSED); return true to show the default one */
    func MesiboCall_OnNotify(type: Int32, profile: MesiboProfile, video: Bool, ts: MesiboDateTime) -> Bool {
        return true
    }

    func MesiboCall_OnError(cp: MesiboCallProperties, error: Int32) {
    }


    // MARK: - phone contacts

    @IBAction func onPhoneContactsSync(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        Mesibo.getInstance().getPhoneContactsManager().start()
    }

    @IBAction func onPhoneNumberInfo(_ sender: Any) {
        if !isLoggedIn() {
            return
        }
        let contact = Mesibo.getInstance().getPhoneContactsManager().getPhoneNumberInfo("+18005551234", code: nil, format: true)
        print("Phone number info: \(contact.name ?? ""), \(contact.formattedPhoneNumber ?? ""), \(contact.country ?? "")")
    }


    // MARK: - location

    func initLocation() {
        let config = MesiboLocationConfig()
        config.minDistance = 250

        let locationManager = MesiboLocationManager.getInstance()
        _ = locationManager.add(self)
        locationManager.start(config)
    }

    func getLocation() {
        // nil until the profile has shared a location
        guard let profile = profile, let location = profile.location().get() else { return }
        print("Location of \(profile.getNameOrAddress()): \(location.latitude), \(location.longitude)")
    }

    func Mesibo_onDeviceLocation(location: MesiboLocation) {
        print("Device location: \(location.latitude), \(location.longitude)")
    }

    func Mesibo_onLocationReceived(profile: MesiboProfile) {
        print("Location received from \(profile.getNameOrAddress())")
    }

    func Mesibo_onLocationRequest(profile: MesiboProfile, duration: UInt32) {
        print("\(profile.getNameOrAddress()) requests your location for \(duration) seconds")
    }

    func Mesibo_onLocationShared(profile: MesiboProfile, duration: UInt32) {
        print("\(profile.getNameOrAddress()) shares their location for \(duration) seconds")
    }

    func Mesibo_onLocationError(profile: MesiboProfile, error: Int32) {
        print("Location error \(error) for \(profile.getNameOrAddress())")
    }

    // MARK: - profile search (profiles nearby)

    func searchLocation() {
        let search = MesiboProfileSearch()
        search.setListener(self)
        search.setDistance(1000)
        search.setMaxAge(3600)
        search.search()
    }

    func Mesibo_onProfileSearchResults(profiles: [MesiboProfile], search: MesiboProfileSearch) {
        print("Profiles nearby: \(profiles.count)")
    }

    func Mesibo_onProfileSearchUpdate(profiles: [MesiboProfile], search: MesiboProfileSearch) {
        print("Profiles nearby changed: \(profiles.count)")
    }


    // MARK: - alerts

    /** an alert; dismiss: closes itself after 2 seconds */
    func alert(_ title: String?, message: String?, dismiss: Bool = true) {
        // an alert, not an action sheet: an action sheet needs an anchor on iPad
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // one that does not close itself needs a button to close it
        if !dismiss {
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
        }

        present(alertController, animated: true)

        if !dismiss {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            alertController.dismiss(animated: true)
        }
    }
}
