## Using Flutter with Mesibo 
You can use mesibo with all the cross-platform tools like Flutter, React-Native, Ionic, etc. mesibo APIs are provided as a Native SDK for Android, iOS, and Web. Since all the cross-platform tools offer a way to access native APIs, you can use mesibo from your chosen platform.

This section explains how to use Mesibo with Flutter by creating [Platform Channels](https://flutter.dev/docs/development/platform-integration/platform-channels). A sample project is available for Android, which you can build and run. You can follow similar steps to use method channels for using Mesibo in iOS on Flutter. 

### Prerequisites

- Read the [Preparation Guide](/documentation/tutorials/first-app/)

- Read the [Anatomy of a Mesibo Application](/documentation/tutorials/first-app/anatomy/) 

- Basic knowledge of creating applications in Flutter 

### Using Flutter Platform Channels  

- The Flutter portion of the app sends commands to its host to perform actions. Here, the host is Mesibo which controls, the iOS or Android portion of the app over a platform channel. 

- Mesibo listens on the platform channel and receives the information about the action to be performed. For example, to send a message, your Android/iOS portion receives a "Send Message" command from Flutter through the method channel. Your app can then invoke mesibo's platform-specific APIs—using the native programming language to send a message to the destination user address entered—and sends a response back to the client, the Flutter portion of the app.

For more information, refer to [Flutter Platform Channels](https://flutter.dev/docs/development/platform-integration/platform-channels)

Follow the steps below to use mesibo in Flutter (For Android):

### 1. Create a new Flutter project
Create a `New Flutter Project` on Android Studio. Open the Android project of your flutter app in a new window.

### 2. Add Mesibo SDK

   - Add Mesibo SDK to your Android host project by adding Gradle dependency and performing Gradle sync as explained in our [First Android App tutorial] (https://mesibo.com/documentation/tutorials/first-app/android/)
   - Import mesibo API 

```java
import com.mesibo.api.mesibo;
```
 
### 3a. Create the Flutter platform client
 
Create Method channels to connect flutter UI and Mesibo inside `main.dart`
 
 First, construct the channel. Use a MethodChannel with a single platform method that returns the `message` from Mesibo
```java
 class _HomeWidgetState extends State<HomeWidget> {
   static const platform = const MethodChannel("mesibo.flutter.io/messaging");
   static const EventChannel eventChannel = EventChannel('mesibo.flutter.io/mesiboEvents'); 
    
    ...
```
Next, invoke the Mesibo API method that you need on the method channel. For example, in the sample App we will be using the following API methods ,which will be called from the Method channel.
```java
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
```
Finally, replace the build method from the template to contain a small user interface that displays the buttons which perform the required functionality. In the Sample App we have,
```java
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

// Define methods here //

```
### 3b. Add an Android platform-specific implementation 
Start by opening the Android portion of your Flutter app in Android Studio:

- Start Android Studio
- Select the menu item File > Open…
- Navigate to the directory holding your Flutter app, and select the android folder inside it. Click OK.
- Open the MainActivity.java file located in the java folder in the Project view.

Extend your MainActivity Class to implement `Mesibo.ConnectionListener`, and `Mesibo.MessageListener``

Next, create a MethodChannel and set a MethodCallHandler inside the `configureFlutterEngine` method. Make sure to use the same channel name as was used on the Flutter client side. Call your API methods in this Method Channel.

 ```java
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine){
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), MESIBO_ACTIVITY_CHANNEL)
                .setStreamHandler(
                        new EventChannel.StreamHandler() {

                            Mesibo.ConnectionListener messageListener;

                            @Override
                            public void onListen(Object arguments, EventChannel.EventSink events) {
                                mEventsSink = events;
                            }

                            @Override
                            public void onCancel(Object arguments) {

                            }
                        }
                );

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), MESIBO_MESSAGING_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("loginUser1")) {
                                mEventsSink.success("Login As User1");
                                onLoginUser1(null);
                            }
                            else if (call.method.equals("loginUser2")) {
                                mEventsSink.success("Login As User2");
                                onLoginUser2(null);
                            }
                            else if (call.method.equals("sendMessage")) {
                                mMessage = call.argument("message");
                                onSendMessage(null);
                            }
                            else if (call.method.equals("audioCall")) {
                                onAudioCall(null);
                            }
                            else if (call.method.equals("videoCall")) {
                                onVideoCall(null);
                            }
                            else if (call.method.equals("launchMessagingUI")) {
                                onLaunchMessagingUi(null);
                            }

                            else {
                                result.notImplemented();
                            }

                        }
                );

    } 
```
Define mesibo users as follows
```java
//Refer to the Get-Started guide to create two users and their access tokens
DemoUser mUser1 = new DemoUser("deb4b3969975eb6f461f06d047eed647a0a34a2b76ea2e551792de", "User-1", "flutter_demo_1");
DemoUser mUser2 = new DemoUser("c085e11940ab171b45d2105e345104e5a8dd8a9a1edd8567eff1792df", "User-2", "flutter_demo_2");
```

### Running the sample application
From Android Studio, run your application by connecting a mobile device/Emulator. 
Now, In the Sample Android application 
1. Click on login as User-1  
2. Launch Message UI and send a message 
3. Click on login as User-2 and launch message UI. You should now receive the message from User-1.
4. You can install the app on multiple devices a try exchanging messages and making calls. 





