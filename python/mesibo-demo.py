#!/usr/bin/python3
 
# first-app.py
#
# Usage:
# Refer to https://mesibo.com/documentation/tutorials/get-started/ to learn more
# Install mesibo python package using python -m pip install mesibo
# Create an application at https://mesibo.com/console
# Create a user and Obtain the token and app id for the user and set it
# Run the script 
#
# $ python3 mesibo-demo.py
#
# Send a message from console to the user. It should be received and printed by your python script
# Use Ctrl+Z or pkill to stop the script
#

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
ACCESS_TOKEN = "<user-access-token>"
APP_ID = "com.mesibo.firstapp"

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


