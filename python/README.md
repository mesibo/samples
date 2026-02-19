## mesibo Python Package 

mesibo offers everything to make your app real-time and scalable. It's modular, lightweight, and easy to integrate.

mesibo supports almost all popular platforms and languages for you to quickly build your applications. Whether you are developing mobile apps (Android, iOS, Java, Objective-C, C++), web apps (Javascript), integrating with backend (Linux, macOS, Windows, Python, C++), or creating cool devices using Raspberry Pi, mesibo has APIs for you.

mesibo's high-performance Python library enables you to interface your chat clients with various scientific computing and machine learning systems on your backend like TensorFlow, Matlab, Octave, NumPy, etc to create a powerful chat experience and analysis.

- **Website:** https://mesibo.com
- **Documentation:** https://mesibo.com/documentation/
- **Tutorials:** https://mesibo.com/documentation/tutorials/get-started

### Supported Platforms
Mesibo Python Package supports the following platforms.

- RedHat 7.x or above (also, Rocky Linux, CentOS)
- Debian / Ubuntu
- Mac OS - both x86_64 and arm64 (M1) versions
- Microsoft Windows 10 and above (64-bit)
- Raspberry Pi 3 and 4 (64-bit)

Note that, Mesibo is no longer supporting or offering 32-bit versions.

## Example
Below are some examples of typical usage. For more examples, see the [examples](https://github.com/mesibo/python/tree/master/examples) directory on the GitHub repo.

### Sending and Receiving Messages
```python
#!/usr/bin/python3
import mesibo
from mesibo import MesiboListener

class PyMesiboListener(MesiboListener):

    def Mesibo_onConnectionStatus(self, status):
        """A status = mesibo.MESIBO_STATUS_ONLINE means the listener 
        successfully connected to the mesibo server
        """
        print("## Mesibo_onConnectionStatus: ", status)
        if(status == mesibo.MESIBO_STATUS_AUTHFAIL):
            exit(1) 
        return 0

    def Mesibo_onMessage(self, msg):
        """Invoked on receiving a new message 
        or reading database messages
        msg: Message Object 
        """
        try:
            if(msg.isRichMessage()):
                print("\n ## message:", msg.message)
                print("\n ## title:", msg.title)
                print("\n ## subtitle:", msg.subtitle)
                print("\n ## path:", msg.file.path)
                print("\n ## url:", msg.file.url)
                #print("\n ## tn:", msg.file.thumbnail)
            else:    
                print("\n ## Received data:", msg.data)
        except:
            pass
        
        print("\n ## Mesibo_onMessage: ", msg)
        return 0

    def Mesibo_onMessageUpdate(self, msg):
        """Invoked on receiving a message update
        """
        print("\n ## Mesibo_onMessageUpdate: ", msg)
        return 0

    def Mesibo_onMessageStatus(self, msg):
        """Invoked when the status 
        of an outgoing or sent message is changed.
        """
        print("## Mesibo_onMessageStatus", msg)
        return 0

    def Mesibo_onPresence(self, msg):
        print("## Mesibo_onPresence", msg)
        return 0 


# Get access token and app id by creating a mesibo user
# See https://mesibo.com/documentation/tutorials/get-started/
ACCESS_TOKEN = "<use your user token>"
APP_ID = "com.mesibo.python"

# Create a Mesibo Instance
api = mesibo.getInstance()

# if you are sending or receiving binary/signalling data, set the format. By default, mesibo
# auto detects and sets to Unicode string or bytes[]
# You can override it by setting mesibo.MESIBO_READAS_BYTES or mesibo.MESIBO_READAS_UNICODE
# mesibo.readDataAs(mesibo.MESIBO_READAS_AUTO)


# Enable or disable End-to-end-encryption
e2ee = api.e2ee();
e2ee.enable(1)

# Set Listener
listener = PyMesiboListener()
api.addListener(listener)

# Set your AUTH_TOKEN obtained while creating the user 
if(mesibo.MESIBO_RESULT_FAIL == api.setAccessToken(ACCESS_TOKEN)):
    print("===> Invalid ACCESS_TOKEN: ", ACCESS_TOKEN)
    print("See https://mesibo.com/documentation/tutorials/get-started/")
    exit(1) 

# Set APP_ID which you used to create AUTH_TOKEN
api.setAppName(APP_ID)

# Set the name of the database
api.setDatabase("mesibo", 0)

# Start mesibo, 
api.start()

input("Press Enter to to send a message...\n")
msg = api.newMessage("destination")
msg.title = "Hello"
msg.message = "Hello message"
#msg.setContent("pic1.jpg")
#msg.setContent("https://mesibo.com")
msg.send()

#e2ee.getPublicCertificate("/root/pycert.cert")
#print("fingerPrint: " + e2ee.getFingerprint("destination"))

#Wait for the application to exit
api.wait()

```

## Installing using pip
See [requirements](https://mesibo.com/documentation/install/python/#requirements) to learn about installation requirements before you continue.

```
$ sudo python -m pip install mesibo
```

## Tutorial
[Write your First mesibo Enabled Application - Python](https://mesibo.com/documentation/tutorials/get-started/python)

## Troubleshooting
If you are facing issues installing the package, execute the following to print verbose logs. 
```
$ sudo python -m pip install mesibo -v
```
Then, raise an issue [here](https://github.com/mesibo/python/issues) with the complete logs.

If you get a run-time error like
```
Unable to load: ... Platform not supported ...  
```
then mesibo does not support this platform. Contact us at [https://mesibo.com/support/](https://mesibo.com/support/) with your platform details, python version, installation logs, etc and we will help you out.
