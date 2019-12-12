# Javascript Messenger 
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

### Known issues:
- Scroll out of alignment when files are sent
- Sent status for file not updated in side-panel

## Instructions

Edit `config.js` and provide the `AUTH TOKEN` & `APP ID`. 

You can obtain the `AUTH TOKEN` and `APP ID` for a user from [Mesibo Console](https://mesibo.com/console/). You can also generate the token for the Web app from [Mesibo Demo App Token Geneartor](https://app.mesibo.com/gentoken/). Provide `APP ID` as `console`. 

Refer to the [Preparation Guide](https://mesibo.com/documentation/tutorials/first-app/#preparation) to learn about basic of mesibo.

```javascript
const MESIBO_ACCESS_TOKEN = "xxxxxxx";
const MESIBO_APP_ID = "xxxx";
const MESIBO_API_URL = "https://app.mesibo.com/api.php"
```
If you are hosting mesibo-backend on your own server, you need to change the API url to point to your server.  

## Local Storage
`MesiboStorage` class defined in `appstorage.js` provides a set of functions to store your messages, profile info, etc into local storage. Create a storage object during initialization.

Message history is retrieved and loaded from local storage through `read` API

## UI
`app_ui.js` provides a set of functions to modify and update the application UI.

