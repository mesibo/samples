import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(FirstMesiboApp());
}



/// Home widget to display video chat option.
class FirstMesiboApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Mesibo-Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("First Mesibo App"),
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
  static const EventChannel eventChannel = EventChannel('mesibo.flutter.io/mesiboEvents');
  String _mesiboStatus = 'Mesibo status: Not Connected.';
  TextEditingController messageController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController(text: '');
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



  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InfoTitle(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text("LOGIN AS USER-1"),
              onPressed: _loginUser1,
              textTheme: ButtonTextTheme.accent,
            ),
            RaisedButton(
              child: Text("LOGIN AS USER-2"),
              onPressed: _loginUser2,
              textTheme: ButtonTextTheme.accent,
            ),
          ],
        ),


        TextField(
          controller: messageController,
          decoration: InputDecoration(
              border:  const OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 0.0),
              ),
              hintText: 'Enter Message'
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            RaisedButton(
              child: Text("SEND"),
              onPressed: _sendMessage,
              textTheme: ButtonTextTheme.accent,
            ),
          ],
        ),
        RaisedButton(
          child: Text("LAUNCH MESSAGE UI"),
          onPressed: _launchMessagingUI,
          textTheme: ButtonTextTheme.accent,
        ),
        RaisedButton(
          child: Text("AUDIO CALL"),
          onPressed: _audioCall,
          textTheme: ButtonTextTheme.accent,
        ),
        RaisedButton(
          child: Text("VIDEO CALL"),
          onPressed: _videoCall,
          textTheme: ButtonTextTheme.accent,
        ),


        Text(_mesiboStatus),
      ],
    );
  }




  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _sendMessage() async {
    print("Send Message clicked");
    await platform.invokeMethod('sendMessage', {"message": messageController.text});
    messageController.text = "";
  }

  void _launchMessagingUI() async {
    print("LaunchMesibo clicked");
    await platform.invokeMethod("launchMessagingUI");
  }

  void _loginUser1() async {
    print("Login As user1");
    await platform.invokeMethod("loginUser1");
  }

  void _loginUser2() async {
    print("Login As user2");
    await platform.invokeMethod("loginUser2");
  }

  void _audioCall() async {
    print("AudioCall clicked");
    await platform.invokeMethod("audioCall");
  }

  void _videoCall() async {
    print("VideoCall clicked");
    await platform.invokeMethod("videoCall");
  }


}

/// Widget to display start video call title.
class InfoTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Text(
          "This is Sample Flutter App that uses Mesibo for Messaging and Audio/Video calls .",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}