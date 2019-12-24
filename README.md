# Mesibo Sample Apps Source Code
This repository has samples that demonstrate various aspects of the mesibo SDK for Android and iOS. The sample code is reasonably well-documented and we suggest you to read comments to quickly understand the code. The entire documentation for the mesibo SDK is available [here](https://mesibo.com/documentation/introduction.html).

[mesibo](https://mesibo.com) allows you to quickly add real-time messaging, voice and video calling into your mobile Apps, and Websites.
  - Enable 1-to-1 messaging, group chat, or add a chatbot in your apps or website
  - Add high quality voice chat between users
  - Adding real-time video calling in your apps

Please check out mesibo introduction video
[![Play Video](https://img.youtube.com/vi/b29TOTpmFqY/0.jpg)](https://www.youtube.com/watch?v=b29TOTpmFqY)

Please refer to README file in each folder for more specific instructions. For general issues and help, check the FAQs section

### List of Samples

* **MesiboSample** This is a sample mobile application that demonstrates how to use mesibo SDK to:
  + send and receive 1-to-1 messaging, group chat
  + make high quality voice and video calls
  
### Compiling sample code and setup
#### Requirements
* [mesibo account](https://mesibo.com) to get your own API KEY.
* For Android App - latest Android Studio or Gradle if you prefer CLI.
* For iOS App - latest xCode (10.x or later)
* For JavaScript Apps - [https://mesibo.com/mesiboapi.js](https://mesibo.com/mesiboapi.js)

### Backend Setup
Sample backend source code and database schema is available in [php](php/) folder. We recommend you to run it on your own server. However, in case you decide to use the demo API link provided in the source code (SampleAppConfiguration.java or SampleAppConfiguration.m), select a unique namespace in application configuration class to avoid conflict with other testers. 

For running backend on your own server, following steps are required
* Create your own mesibo account to get mesibo API key and App token. You may also read [tutorial](https://mesibo.com/documentation/tutorials.html) on how to get mesibo API key and App token. 
* Create database and table using schema in [php/SampleApp.sql](https://github.com/mesibo/samples/blob/master/php/sample-app.sql)
* edit config.php and enter API Key, App token, and database credentials.
* change apiUrl in respective application configuration classes.

# Mesibo Demo App
You can also try mesibo demo app from Google or Apple app store to quickly evaluate some of the mesibo functionalities without compiling or setting up the sample app source code. 

Mesibo demo app is also built using the same sample code posted on GitHub here. However, the demo app on the app store has some more screens like login, splash, settings, etc and the source of the demo app is separately available as part of our custom solutions, please [contact mesibo sales team](https://mesibo.com/contact.html). 

 

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
