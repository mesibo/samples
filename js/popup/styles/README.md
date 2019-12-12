# mesibo-web-mini

This repo contains the web demo app for a popup chat interface for Mesibo Javascript API.
You can also find the full view demo app [here]()
 
### Features currently in development:
- Offline Message handling
- Sending files: Video, document, etc and custom thumbnail for each file type


## Initializing Mesibo 
Provide the `AUTH TOKEN` & `APP ID` and initialize Mesibo as shown below in config.js. You can obtain the `AUTH TOKEN` and `APP ID` for a user from [Mesibo Console](https://mesibo.com/console/). 
Refer to the [Preparation Guide](https://mesibo.com/documentation/tutorials/first-app/#preparation) for more details. `

You can also configure a single user to send and recieve messages.

```javascript
const MESIBO_ACCESS_TOKEN = "xxxxxxx";
const MESIBO_APP_ID = "xxxx";
const MESIBO_DESTINATION_USER = "xxxxx"; 
```

