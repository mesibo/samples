#js-messenger 
This repository contains the source code for the Mesibo Sample Web app using Mesibo Javascript API

> Please note that this is currently **under development** and will be continously updated. 

## Features:
- One-to-One messaging, Voice and Video Call
- Typing indicators and Online status
- Read receipts
- Sending Images 
- Local storage and chat history


### Features currently in development:
- Implement ReadSession API (similar to Mesibo Android/iOS/C++/Python etc)
- Implement setCustomMessage 
- Group Messaging
- Show image/file in last sent status
- Sending files: Video, document, etc and custom thumbnail for each file type
- Edit self profile details

Known issues:
- Scroll out of alignment when files are sent
- Sent status for file not updated in side-panel

## Installing Mesibo Javascript SDK

The easiest way to install Mesibo Javascript SDK is to just include following in your code:
```html
<script type="text/javascript" src="https://api.mesibo.com/mesibo.js"></script>
```

You can also use `async` and `defer` attributes inside script tag if required.

## Initializing Mesibo 
Provide the `AUTH TOKEN` & `APP ID` and initialize Mesibo as shown below in config.js. You can obtain the `AUTH TOKEN` and `APP ID` for a user from [Mesibo Console](https://mesibo.com/console/). You can also generate the token for the Web app from [Mesibo Demo App Token Geneartor](https://app.mesibo.com/gentoken/). Provide `APP ID` as `console`. 
Refer to the [Preparation Guide](https://mesibo.com/documentation/tutorials/first-app/#preparation) for more details. `

If you are hosting mesibo-backend on your own server/ an on-premise installation configure the API url.  

```javascript
const MESIBO_ACCESS_TOKEN = "xxxxxxx";
const MESIBO_APP_ID = "xxxx";
const MESIBO_API_URL = "https://app.mesibo.com/api.php"
```
## Local Storage
`MesiboStorage` class defined in `appstorage.js` provides a set of functions to store your messages, profile info, etc into local storage. Create a storage object during initialization.

Message history is retrieved and loaded from local storage through `read` API

## UI
`app_ui.js` provides a set of functions to modify and update the application UI.

## Mesibo Listeners
Mesibo listener functions are callback functions that provide status and information like status of message sent, receiving a message, typing indiction, presence information(Online or Offline), etc . 

Based on this status, the application UI and the local storage data is updated. For example, the status for a sent message is recieved through `Mesibo_onMessageStatus`based on which the status tick is updated. The status of the sent message is also updated in local storage.

```javascript
MesiboNotify.prototype.Mesibo_OnMessageStatus = function(m) {

        MesiboLog("MesiboNotify.prototype.Mesibo_OnMessageStatus: from " + m.peer +
                " status: " + m.status);

        this.AppContext.getStorage().onMessageStatus(m);
        MesiboUI_onMessageStatus(m);

}
```
## Sending Messages and Files
To [send a message](https://mesibo.com/documentation/tutorials/first-app/js/#sending-messages)
use the `sendMessage` API function and update local storage & UI to display it accordingly.

To send a file, you can use the `sendFile` API function similarly by passing the file url in message parameters. For an example on uploading your file and getting a URL refer  `files.js`.

