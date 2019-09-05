# Mesibo Flutter Sample App
This repo contains the source code for a Mesibo sample App using Flutter

[mesibo](https://mesibo.com) allows you to quickly add real-time messaging, voice and video calling into your mobile Apps, and Websites.
  - Enable 1-to-1 messaging, group chat, or add a chatbot in your apps or website
  - Add high quality voice chat between users
  - Adding real-time video calling in your apps

[Flutter](https://flutter.io/) by Google is a new framework that allows us to build beautiful native Apps on iOS and Android from a single codebase. It provides Fast Development, Expressive and Flexible UI, and Native Performance.

Mesibo provides real time APIs for messaging,voice and video call which can be easily integrated into any application on Android or iOS platforms. In this sample app, the user interface is developed using flutter which interacts with Mesibo to send messages and make audio/video calls. To achieve this we have used flutter method channels.

- The Flutter portion of the app sends commands to  its host to perform actions.Here ,the host is Mesibo which controls ,the iOS or Android portion of the app, over a platform channel.For example ,to send a message you just need to enter the access token for your application and the destination user address.

- Mesibo listens on the platform channel, and recieves the information about the action to be performed. In the case of sending a message, it will recieve a "Send Message" command from flutter ,upon which Mesibo calls into any number of platform-specific APIs—using the native programming language to send a message to the destination user address entered—and sends a response back to the client, the Flutter portion of the app.

![flutter-mesibo-channel](https://flutter.dev/images/PlatformChannels.png)

For more information about the use  of platform channels you can refer to [flutter documentation](https://flutter.dev/docs/development/platform-integration/platform-channels)


Please check out mesibo introduction video
[![Play Video](https://img.youtube.com/vi/imHA4kBRSH0/0.jpg)](https://www.youtube.com/watch?v=imHA4kBRSH0)

Please refer to README file in each folder for more specific instructions. For general issues and help, check the FAQs section

### List of Samples

* **MesiboSample** This is a sample mobile application that demonstrates how to use mesibo SDK with flutter to:
  + send and receive 1-to-1 messaging, group chat
  + make high quality voice and video calls

### Compiling sample code and setup
#### Requirements
* [mesibo account](https://mesibo.com) to get your own API KEY.
* For Android App - latest Android Studio or Gradle if you prefer CLI.
* For iOS App - latest xCode (10.x or later)
* For JavaScript Apps - [https://mesibo.com/mesiboapi.js](https://mesibo.com/mesiboapi.js)
* To install flutter [refer](https://flutter.dev/docs/get-started/install)

### Backend Setup
Sample backend source code and database schema is available in [php](php/) folder. We recommend you to run it on your own server. However, in case you decide to use the demo API link provided in the source code (SampleAppConfiguration.java or SampleAppConfiguration.m), select a unique namespace in application configuration class to avoid conflict with other testers.

For running backend on your own server, following steps are required
* Create your own mesibo account to get mesibo API key and App token. You may also read [tutorial](https://mesibo.com/documentation/tutorials.html) on how to get mesibo API key and App token.
* Create database and table using schema in [php/SampleApp.sql](https://github.com/mesibo/samples/blob/master/php/sample-app.sql)
* edit config.php and enter API Key, App token, and database credentials.
* change apiUrl in respective application configuration classes.

# Mesibo Flutter Sample App Source Code
This repository has contains the sample app that demonstrate various aspects of the mesibo SDK for Android with FLUTTER. The sample code is reasonably well-documented and we suggest you to read comments to quickly understand the code. The entire documentation for the mesibo SDK is available [here](https://mesibo.com/documentation/introduction.html).

[![App Store](http://imgur.com/y8PTxr9.png "App Store")](https://itunes.apple.com/us/app/mesibo-realtime-messaging-voice-video/id1222921751)   [![Play Store](http://imgur.com/utWa1co.png "Play Store")](https://play.google.com/store/apps/details?id=com.mesibo.mesiboapplication)

# Features!

  - One-on-one messaging and Group chat
  - High quality voice and video calling
  - Rich messaging (text, picture, video, audio, other files)
  - Location sharing
  - Message status and typing indicators
  - Online status (presence) and real-time profile update
  - Push notifications and many more...

## Community
- [Facebook](https://www.facebook.com/mesiboapi)
- [Twitter](https://twitter.com/mesiboapi)
- [LinkedIn](https://www.linkedin.com/company/mesibo)
- [YouTube](https://www.youtube.com/channel/UCxpcg-RSf2-lK4uyysWSsKQ)

### Want to contribute or need to see some improvements?
We would love that, please create an issue or send a PR.
