import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mesibo_flutter_sdk/mesibo.dart';

import 'dart:developer';
      
/**************************************************************************************************
 This demo application implements real-time messaging, calls, and conferencing capabilities in a 
 Flutter application. It can serve as a guide for integrating these features into your own Flutter 
 projects. Please refer to the tutorial link below for details on getting started, obtaining 
 authentication tokens and other implementation specifics.

 https://mesibo.com/documentation/tutorials/get-started/

 You MUST create tokens and initialize them for user1 and user2 in the code below.

 **************************************************************************************************/

class DemoUser {
  String token = "";
  String address = "";

  DemoUser(String t, String a) {
    token = t;
    address = a;
  }
}

void main() {
  runApp(FirstMesiboApp());
}

/// Home widget to display video chat option.
class FirstMesiboApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mesibo Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("First Mesibo App"),
        ),
        body:  HomeWidget(),

      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Widget to display start video call layout.
class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> implements MesiboConnectionListener, MesiboMessageListener, MesiboGroupListener {
  static Mesibo _mesibo = Mesibo();
  static MesiboUI _mesiboUi = MesiboUI();
  String _mesiboStatus = 'Mesibo status: Not Connected.';
  Text? mStatusText;
  bool authFail = false;
  String mAppId = "";

 /**************************************************************************************************
   Please refer to the tutorial link below for details on obtaining user authentication tokens.

   https://mesibo.com/documentation/tutorials/get-started/
 **************************************************************************************************/
  DemoUser user1 = DemoUser("user-access-token-for-user-1", 'user-1-address');
  DemoUser user2 = DemoUser("user-access-token-for-user-2", 'user-2-address');


  String remoteUser = "";
  bool mOnline = false, mLoginDone = false;
  ElevatedButton? loginButton1, loginButton2;

  @override
  void initState() {
    super.initState();
  }

  @override
  void Mesibo_onConnectionStatus(int status) {
    print('Mesibo_onConnectionStatus: ' + status.toString());

    if(authFail) return;  // to prevent overwriting displayed status
    String statusText = status.toString();
    if(status == Mesibo.MESIBO_STATUS_ONLINE) {
        statusText = "Online";
    } else if(status == Mesibo.MESIBO_STATUS_CONNECTING) {
        statusText = "Connecting";
    } else if(status == Mesibo.MESIBO_STATUS_CONNECTFAILURE) {
        statusText = "Connect Failed";
    } else if(status == Mesibo.MESIBO_STATUS_NONETWORK) {
        statusText = "No Network";        
    } else if(status == Mesibo.MESIBO_STATUS_AUTHFAIL) {
        authFail = true;
        String warning = "The token is invalid. Ensure that you have used appid \"" + mAppId + "\" to generate Mesibo user access token";
        statusText = warning;
        print(warning);
        showAlert("Auth Fail", warning);
    } 

    _mesiboStatus = 'Mesibo status: ' + statusText;
    setState(() {});

    if(1 == status) mOnline = true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InfoTitle(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            loginButton1 = ElevatedButton(
              child: Text("Login as User-1"),
              onPressed: _loginUser1,
            ),
            loginButton2 = ElevatedButton(
              child: Text("Login as User-2"),
              onPressed: _loginUser2,
            ),
          ],
        ),

        Container(
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
          border: Border.all(color: Colors.grey)
        ),
        child: Text(_mesiboStatus, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ), 

        mStatusText = Text(""),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            loginButton1 = ElevatedButton(
              child: Text("Send a Message"),
              onPressed: _sendMessage,
            ),
            loginButton2 = ElevatedButton(
              child: Text("Set Profile Info"),
              onPressed: _setProfileInfo,
            ),
          ],
        ),

      Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ElevatedButton(
              child: Text("Show Messages"),
              onPressed: _showMessages,
            ),
            ElevatedButton(
               child: Text("Show User List"),
                onPressed: _showUserList,
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ElevatedButton(
              child: Text("Video Call"),
              onPressed: _videoCall,
            ),
            ElevatedButton(
              child: Text("Audio Call"),
              onPressed: _audioCall,
            ),
          ],
        ),

        ElevatedButton(
          child: Text("Group Call"),
          onPressed: _groupCall,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ElevatedButton(
              child: Text("Sync Phone Contacts"),
              onPressed: _syncPhoneContacts,
            ),
            ElevatedButton(
               child: Text("Get Phone Contact"),
                onPressed: _getPhoneContacts,
            ),
          ],
        ),

      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showAlert(String title, String body) {
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(body),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  bool isOnline() {
    if(mOnline) return true;
    showAlert("Not Online", "First login with a valid token");
    return false;
  }

  void initMesibo(String token) async {
      // optional - only to show alert in AUTHFAIL case
      Future<String> asyncAppId = _mesibo.getAppIdForAccessToken();
      asyncAppId.then((String appid) { mAppId = appid; });

      // initialize mesibo
      _mesibo.setAccessToken(token);
      _mesibo.setListener(this);
      _mesibo.start();

      /**************************************************************************************************
         override default UI text, colors, etc.Refer to the documentation 

	 https://mesibo.com/documentation/ui-modules/ 

	 Also refer to the header file for complete list of parameters (applies to both Android/iOS)
	 https://github.com/mesibo/mesiboframeworks/blob/main/mesiboui.framework/Headers/MesiboUI.h#L170
      **************************************************************************************************/

      _mesiboUi.getUiDefaults().then((MesiboUIOptions options) {
        options.enableBackButton = true;
        options.appName = "My First App";
        options.toolbarColor = 0xff00868b;
        _mesiboUi.setUiDefaults(options);
      });

      /**************************************************************************************************
         The code below enables basic UI customization. 
	
         However, you can customize entire user interface by implementing MesiboUIListner for Android and 
         iOS. Refer to 

	https://mesibo.com/documentation/ui-modules/customizing/
      **************************************************************************************************/

      MesiboUIButtons buttons = MesiboUIButtons();
      buttons.message = true;
      buttons.audioCall = true;
      buttons.videoCall = true;
      buttons.groupAudioCall = true;
      buttons.groupVideoCall = true;
      buttons.endToEndEncryptionInfo = false; // e2ee should be enabled 
      _mesiboUi.setupBasicCustomization(buttons, null);
  }

  void _loginUser1() {
    if(null == _mesibo) {
      showAlert("Mesibo NULL", "mesibo null");
      return;
    }
    if(mLoginDone) {
      showAlert("Failed", "You have already initiated login. If the connection status is not 1, check the token and the package name/bundle ID");
      return;
    }
    mLoginDone = true;
    initMesibo(user1.token);
    remoteUser = user2.address;
  }

  void _loginUser2() {
    if(mLoginDone) {
      showAlert("Failed", "You have already initiated login. If the connection status is not 1, check the token and the package name/bundle ID");
      return;
    }
    mLoginDone = true;
    initMesibo(user2.token);
    remoteUser = user1.address;
  }


  void _setProfileInfo() async {
    if(!isOnline()) return;
    MesiboProfile profile = await _mesibo.getSelfProfile() as MesiboProfile;
    
    profile.name = "Joe";
    profile.save();
    
  }

  void _sendMessage() async {
    if(!isOnline()) return;
    MesiboProfile profile = await _mesibo.getUserProfile(remoteUser) as MesiboProfile;
    
    MesiboMessage m = profile.newMessage();
    m.message = "Hello from Flutter";
    m.send();
  }

  void _showMessages() async {
    if(!isOnline()) return;
    MesiboProfile profile = await _mesibo.getUserProfile(remoteUser) as MesiboProfile;
    
    _mesiboUi.launchMessaging(profile);
  }

  void _showUserList() {
    if(!isOnline()) return;
    _mesiboUi.launchUserList();
  }

  void _audioCall() async {
    if(!isOnline()) return;
    MesiboProfile profile = await _mesibo.getUserProfile(remoteUser) as MesiboProfile;
    _mesiboUi.call(profile, false);
  }

  void _videoCall() async {
    if(!isOnline()) return;
    MesiboProfile profile = await _mesibo.getUserProfile(remoteUser) as MesiboProfile;
    _mesiboUi.call(profile, true);
  }

  void _groupCall() async {
    if(!isOnline()) return;
    int groupid = 0; // create group first, add memmbers and then execute the following. 

    // disabled by defaut
    if(0 == groupid) {
      showAlert("No group defined", "Refer to the group management documentation to create a group and add members before using group call function");
      return;
    }

    MesiboProfile profile = await _mesibo.getGroupProfile(groupid) as MesiboProfile;
    _mesiboUi.groupCall(profile, true, true, false, false);
  }

  void _syncPhoneContacts() async {
    _mesibo.getPhoneContactsManager().start();
  }

  void _getPhoneContacts() async {
    MesiboPhoneContact contact = (await _mesibo.getPhoneContactsManager().getPhoneNumberInfo("+18005551234", null, true))! as MesiboPhoneContact;

    print("Mesibo Contact: name ${contact.name} phone ${contact.phoneNumber} formatted ${contact.formattedPhoneNumber} country ${contact.country}");
  }

  void __createGroup() async {
    MesiboGroupSettings settings = MesiboGroupSettings();
    settings.name = "My Group";
  }
  
  @override
  void Mesibo_onMessage(MesiboMessage message) {
    String groupName = "";
    if(null != message.groupProfile)
      groupName = message.groupProfile!.name!;

    print('Mesibo_onMessage: from: (' + message.profile!.name! + ") group: (" + groupName + ") Message: " + message.message!);
  }
  
  @override
  void Mesibo_onMessageStatus(MesiboMessage message) {
    print('Mesibo_onMessageStatus: ' + message.status.toString());
  }
  
  @override
  void Mesibo_onMessageUpdate(MesiboMessage message) {
    print('Mesibo_onMessageUpdate: ' + message.message!);
  }

  @override
  void Mesibo_onGroupCreated(MesiboProfile profile) {

  }

  @override
  void Mesibo_onGroupJoined(MesiboProfile profile) {
      print("Mesibo Group Joined: " + profile.name! + " group id: " + profile.groupId.toString());
      MesiboMessage m = profile.newMessage();
      m.message = "Hey, I have joined this group from Flutter";
      m.send();

      MesiboGroupProfile? groupProfile = profile.getGroupProfile();
      if(groupProfile == null) return;
      groupProfile.getMembers(10, false, this);
  }

  @override
  void Mesibo_onGroupLeft(MesiboProfile profile) {
    print("Mesibo Group left: " + profile.name! + " group id: " + profile.groupId.toString());
  }

  @override
  void Mesibo_onGroupMembers(MesiboProfile profile, List<MesiboGroupMember?> members) {
    print("Mesibo Group members: " + profile.name! + " group id: " + profile.groupId.toString());

    for(final m in members) {
        String? name = m?.getProfile()!.getNameOrAddress();
        print("Mesibo group member: " + name!);
    }
  }

  @override
  void Mesibo_onGroupMembersJoined(MesiboProfile profile, List<MesiboGroupMember?> members) {
    print("Mesibo Group members joined: " + profile.name! + " group id: " + profile.groupId.toString());
  }

  @override
  void Mesibo_onGroupMembersRemoved(MesiboProfile profile, List<MesiboGroupMember?> members) {

  }

  @override
  void Mesibo_onGroupSettings(MesiboProfile profile, MesiboGroupSettings? groupSettings, MesiboMemberPermissions? memberPermissions, List<MesiboGroupPin?> groupPins) {

  }

  @override
  void Mesibo_onGroupError(MesiboProfile profile, int error) {

  }


}

/// Widget to display start video call title.
class InfoTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Text(
          "Login as User-1 from one device and as User-2 from another!",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
