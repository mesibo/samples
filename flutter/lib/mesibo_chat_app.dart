import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Home widget to display video chat option.
class VideoChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Mesibo_FLUTTER',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("MESIBO"),
        ),
        body: Center(
          child: HomeWidget(),
        ),
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

class _HomeWidgetState extends State<HomeWidget> {
  static const platform = const MethodChannel("mesibo.flutter.io/messaging");
  static const EventChannel eventChannel =
      EventChannel('mesibo.flutter.io/mesiboEvents');
  String _mesiboStatus = 'Mesibo status: Not Connected.';
  final userAccessTokenController = new TextEditingController();
  final destinationController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  void _onEvent(Object event) {
    setState(() {
      _mesiboStatus = "" + event.toString();
    });
  }

  void _onError(Object error) {
    setState(() {
      _mesiboStatus = 'Mesibo status: unknown.';
    });
  }

  void _setCredentials() async {
    print("Set Credentials clicked");
    //get AccessToken and Destination From TextField and add it in a list then send it to native mesibo activity where these can be used to start mesibo
    final List list = new List();
    list.add(userAccessTokenController.text);
    list.add(destinationController.text);

    await platform.invokeMethod("setAccessToken", {"Credentials": list});
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InfoTitle(),
        accessTokenLayoutWidget(userAccessTokenController),
        destinationLayoutWidget(destinationController),
        RaisedButton(
          child: Text("Set Credentials"),
          onPressed: _setCredentials,
          textTheme: ButtonTextTheme.accent,
        ),
        RaisedButton(
          child: Text("Send Message"),
          onPressed: _sendMessage,
          textTheme: ButtonTextTheme.accent,
        ),
        RaisedButton(
          child: Text("Make Audio Call"),
          onPressed: _makeAudioCall,
          textTheme: ButtonTextTheme.accent,
        ),
        RaisedButton(
          child: Text("Make Video Call"),
          onPressed: _makeVideoCall,
          textTheme: ButtonTextTheme.accent,
        ),
        RaisedButton(
          child: Text("Launch Mesibo UI"),
          onPressed: _launchMesiboUI,
          textTheme: ButtonTextTheme.accent,
        ),
        Text(_mesiboStatus),
      ],
    );
  }




  @override
  void dispose() {
    userAccessTokenController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    print("Send Message clicked");
    await platform.invokeMethod('sendMessage');
  }

  void _launchMesiboUI() async {
    print("LaunchMesibo clicked");
    await platform.invokeMethod("launchMesiboUI");
  }

  void _makeAudioCall() async {
    print("AudioCall clicked");
    await platform.invokeMethod("audioCall");
  }

  void _makeVideoCall() async {
    print("VideoCall clicked");
    await platform.invokeMethod("videoCall");
  }


}

Widget accessTokenLayoutWidget(TextEditingController controller) {
  return Container(
    margin: EdgeInsets.only(left: 15.0, right: 15.0),
    padding: EdgeInsets.all(5.0),
    alignment: Alignment.center,
    child: TextField(
      controller: controller,
      decoration: new InputDecoration(
          contentPadding: const EdgeInsets.all(15.0),
          border: new OutlineInputBorder(
              borderSide: new BorderSide(color: Colors.teal)),
          hintText: 'Enter your access token',
          helperText: 'You can find it in Mesibo Console',
          labelText: 'Access Token'),
    ),
  );
}

Widget destinationLayoutWidget(TextEditingController controller) {
  return Container(
    margin: EdgeInsets.only(left: 15.0, right: 15.0),
    padding: EdgeInsets.all(5.0),
    alignment: Alignment.center,
    //width: 200,
    height: 100,
    child: TextField(
      controller: controller,
      decoration: new InputDecoration(
          contentPadding: const EdgeInsets.all(15.0),
          border: new OutlineInputBorder(
              borderSide: new BorderSide(color: Colors.teal)),
          hintText: 'Enter destination',
          helperText: 'Address where you want your message to be delivered',
          labelText: 'Destination'),
    ),
  );
}

/// Widget to display start video call title.
class InfoTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Text(
          "This is Sample Flutter App that uses Android Native Mesibo Library for Messaging and Audio/Video calls .",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
