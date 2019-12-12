# js-popup

This repo contains the sample web app for a popup chat interface for Mesibo Javascript API.
You can find the js-messenger app [here]()

## Initializing Mesibo 
Provide the `AUTH TOKEN` & `APP ID` and initialize Mesibo as shown below in config.js. You can obtain the `AUTH TOKEN` and `APP ID` for a user from [Mesibo Console](https://mesibo.com/console/). 
Refer to the [Preparation Guide](https://mesibo.com/documentation/tutorials/first-app/#preparation) for more details. `

You can also configure a single user to send and recieve messages. The display name and picture can be configured to your choice.

```javascript
const MESIBO_ACCESS_TOKEN = "xxxxxxx";
const MESIBO_APP_ID = "xxxx";

const MESIBO_DESTINATION_USER = "xxxxx"; 
const MESIBO_DISPLAY_NAME = "Mesibo"
const MESIBO_DISPLAY_PICTURE = "images/profile/default-profile-icon.jpg"

```

