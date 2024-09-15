#!/usr/bin/python3
 
# first-app.py
#
# Usage:
# Refer to https://docs.mesibo.com/tutorials/get-started/ to learn more
# Install mesibo python package using python -m pip install mesibo
# Create an application at https://console.mesibo.com
# Create a user, and obtain the token or the user and set it
# Run the script 
#
# $ python3 mesibo-demo.py
#
# Send a message from console to the user. It should be received and printed by your python script
# Use Ctrl+Z or pkill to stop the script
#

import sys
import mesibo
from mesibo import MesiboListener

class PyMesiboListener(MesiboListener):

    def Mesibo_onConnectionStatus(self, status):
        """A status = mesibo.MESIBO_STATUS_ONLINE means the listener 
        successfully connected to the mesibo server
        """
        if(status == mesibo.MESIBO_STATUS_ONLINE):
            print("\n## Mesibo_onConnectionStatus: online")
        elif(status == mesibo.MESIBO_STATUS_OFFLINE):
            print("\n## Mesibo_onConnectionStatus: offline")
        elif(status == mesibo.MESIBO_STATUS_CONNECTING):
            print("\n## Mesibo_onConnectionStatus: connecting")
        elif(status == mesibo.MESIBO_STATUS_CONNECTFAILURE):
            print("\n## Mesibo_onConnectionStatus: connection failed")
        elif(status == mesibo.MESIBO_STATUS_AUTHFAIL):
            print("\n## Mesibo_onConnectionStatus: authfail")
        else:
            print("\n## Mesibo_onConnectionStatus: ", status)
        return 0

    def Mesibo_onMessage(self, msg):
        """Invoked on receiving a new message 
        or reading database messages
        msg: Message Object 
        """
        
        if(msg.isOutgoing()):
            print(f"\n ------------- Outgoing Message: ID: {msg.mid} ---------------");
        elif(msg.isIncoming()):
            print(f"\n ------------- Incoming Message: ID: {msg.mid} ---------------");
            
        try:
            if(msg.isRichMessage()):
                print("\n ## message:", msg.message)
                print("\n ## title:", msg.title)
                print("\n ## subtitle:", msg.subtitle)
                print("\n ## path:", msg.file.path)
                print("\n ## url:", msg.file.url)
                #print("\n ## tn:", msg.file.thumbnail)
            else:    
                print("\n ## Received text message or data:", msg.data)
        except:
            pass
        
        #print("\n ## Mesibo_onMessage: ", msg)
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
        if(msg.isSent()):
            print(f"## Mesibo_onStatus: ID: {msg.mid} status:sent\n")
        elif(msg.isDelivered()):
            print(f"## Mesibo_onStatus: ID: {msg.mid} status:delivered\n")
        elif(msg.isReadByPeer()):
            print(f"## Mesibo_onStatus: ID: {msg.mid} status:read by peer\n")
        return 0

    def Mesibo_onPresence(self, msg):
        if(msg.isTyping()):
            print(f"## Mesibo_onPresence: {msg.peer} is typing")
        elif(msg.isTypingCleared()):
            print(f"## Mesibo_onPresence: {msg.peer} has stopped typing")
        elif(msg.isOnline()):
            print(f"## Mesibo_onPresence: {msg.peer} is online")
        elif(msg.hasJoined()):
            print(f"## Mesibo_onPresence: {msg.peer} has joined")
        elif(msg.hasLeft()):
            print(f"## Mesibo_onPresence: {msg.peer} has left")
        else:
            print("## Mesibo_onPresence: ", msg.presence)
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
#e2ee.enable(1)

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

#input("Press Enter to to send a message...\n")
while 1:
    text1 = input('===> Enter your message: ').strip()
    msg = api.newMessage("18005551111")
    msg.message = text1
    #msg.setLatitude(37.4275)
    #msg.setLongitude(122.1697)
    msg.send()

#e2ee.getPublicCertificate("/root/pycert.cert")
#print("fingerPrint: " + e2ee.getFingerprint("destination"))

#Wait for the application to exit
api.wait()


