#!/bin/bash

#===========================================
# mesibo UAC (User Access Control) Configuration Script
#===========================================
# 
# This script helps you create and manage UAC configurations for mesibo.
# UAC allows you to assign different feature sets to different user segments
# (free/premium users, doctors/patients, etc.) instead of managing each user individually.
#
# Documentation: https://docs.mesibo.com/api/backend-api/user-access-control-uac/
#
# SETUP:
# 1. Change API_URL below to point to your on-premise backend API URL
#    For cloud, use: https://api.mesibo.com/backend
#    For on-premise, use: http://your-server-ip/backend
#
# 2. Set APP_TOKEN to your application token from mesibo console
#
# 3. Configure the parameters below according to your requirements
#
# 4. Run: ./uac.sh
#
#===========================================

# Configuration
# IMPORTANT: Update these values before running the script
# If on-premise, Change to your on-premise backend URL
API_URL="https://api.mesibo.com/backend"       
APP_TOKEN="APP TOKEN"  # Your app token from mesibo console

#===========================================
# EDIT PARAMETERS BELOW
#===========================================

# Basic Settings
UAC_ID=10
UAC_NAME="Test UAC"
UAC_UPDATE=0           # Set to 1 to update existing
PEERS=0                # 0=All, 1=Specific peers, 2=Contacts only, 3=Favorites only

# Platform Settings (optional - leave empty to apply to all platforms)
# You can either use UAC_PLATFORMS string OR individual platform flags, not both
# Example: UAC_PLATFORMS="android,ios" OR UAC_ANDROID=1 and UAC_IOS=1
# When updating UAC, only single platform or no platform can be specified
UAC_PLATFORMS=""       # e.g., "android,ios" or "android,ios,javascript"
UAC_ANDROID=0          # 1=Apply to Android, 0=Not applicable
UAC_IOS=0              # 1=Apply to iOS, 0=Not applicable
UAC_JAVASCRIPT=0       # 1=Apply to JavaScript/Web, 0=Not applicable
UAC_CPP=0              # 1=Apply to C++, 0=Not applicable
UAC_PYTHON=0           # 1=Apply to Python, 0=Not applicable
UAC_SFU=0              # 1=Apply to SFU/Live, 0=Not applicable

# App Data
APP_NAME="My App 2"
APP_DATA=""            # Custom JSON data

# Features (Master Switches)
FEATURE_GROUP=1
FEATURE_E2EE=1
FEATURE_MESSAGE=1
FEATURE_PRESENCE=1
FEATURE_CALL=1
FEATURE_SYNC=1
FEATURE_PUSH=1        
FEATURE_LOCATION=1
FEATURE_FILES=1        

# Message Settings
MSG_INCOMING=1
MSG_OUTGOING=1
MSG_RICH=1
MSG_BROADCAST=0
MSG_READ_RECEIPTS=1
MSG_DELIVERY_RECEIPTS=1
MSG_STORAGE=1
MSG_URL_PREVIEW=1
MSG_WEBHOOK=0

# Presence Settings
# Control presence notifications and privacy
# PRESENCE_ONLINE_AUDIENCE controls who can see online status:
#   0=All users, 1=Contacts only, 2=Subscribers only, 3=Favorites only, 4+=Specific group ID
# PRESENCE_CAN_OVERRIDE allows users to change these settings via client API (setOnlineStatusAudience)
PRESENCE_INCOMING=1
PRESENCE_OUTGOING=1
PRESENCE_TYPING=1
PRESENCE_ONLINE=1
PRESENCE_JOINED=1
PRESENCE_LASTSEEN=1
PRESENCE_LASTSEEN_RESOLUTION=300    # Resolution in seconds (0=exact, 300=5min, 3600=1hour)
PRESENCE_LOGIN=1                    # Enable login/logout notifications
PRESENCE_REQUEST=1                  # Enable presence request notifications
PRESENCE_ONLINE_AUDIENCE=0          # 0=All, 1=Contacts, 2=Subscribers, 3=Favorites, 4+=GroupID
PRESENCE_CAN_OVERRIDE=1             # Allow clients to override presence settings

# Call Settings (one-to-one)
CALL_INCOMING=1
CALL_OUTGOING=1
CALL_VIDEO=1
CALL_AUDIO=1
CALL_TURN=1
CALL_HD=1
CALL_FHD=0
CALL_LOG=1              # Save call history in database (on-premise only)
CALL_MAXDUR=0           # Max duration in seconds, 0=unlimited
#CALL_TURN_SERVER="turn.test.com:3478"
CALL_TURN_SERVER=""

# Conference Settings (group calls)
CONF_VIDEO=1
CONF_AUDIO=1
CONF_SCREEN=1
CONF_HD=1
CONF_FHD=0
CONF_MAXDUR=0           # Max duration in seconds, 0=unlimited

# Group Settings
GROUP_CREATE=1
GROUP_MEMBER=1  
GROUP_MESSAGE=1
GROUP_PRESENCE=1
GROUP_CALL=1               # Group conferencing (use "call" not "conf")
GROUP_LOCATION=1
GROUP_MAX_GROUPS=100

# File Settings
# Simplified file upload control - file type filtering handled at application level
# Profile picture uploads are always allowed regardless of FILE_UPLOAD setting
FILE_UPLOAD=1              # Allow file uploads for messaging
FILE_SIGNED=0              # Enable signed (protected) uploads requiring download authentication
FILE_MAX_SIZE=50           # Max file size in MB, 0=unlimited
FILE_UPLOAD_URL=""         # Custom file upload URL (leave empty to use mesibo default)

# Location Settings - General
LOC_EMULATOR=0             # Allow emulator locations
LOC_MOCK=0                 # Allow mock locations
LOC_SEND_REAL=1            # Send real or obfuscated location
LOC_SEND_AGE=300           # Max age of location to send (seconds)
LOC_CAN_SUB=1              # Allow subscribing to others' locations
LOC_ANTI_TRIANG=0          # Anti-triangulation (obfuscation)

# Location Settings - User
LOC_USER_REACH=5000        # meters
LOC_USER_ACCURACY=100      # meters
LOC_USER_FUZZINESS=0
LOC_USER_MAXAGE=3600       # seconds

# Location Settings - Group
LOC_GROUP_REACH=10000      # meters
LOC_GROUP_MAXAGE=3600      # seconds

# Location Settings - Subscriptions
LOC_SUBS_COUNT=4         # max subscriptions
LOC_SUBS_DURATION=86400    # seconds
LOC_SUBS_SENDREAL=1        # Send real location in subscriptions

# Proximity Search Settings - User
SEARCH_USER_MIN_RADIUS=100     # meters
SEARCH_USER_MAX_RADIUS=50000   # meters
SEARCH_USER_MAXAGE=3600        # seconds
SEARCH_USER_REACH=50000        # meters
SEARCH_USER_BOUNDS=1

# Proximity Search Settings - Group
SEARCH_GROUP_MIN_RADIUS=100    # meters
SEARCH_GROUP_MAX_RADIUS=50000  # meters
SEARCH_GROUP_MAXAGE=3600       # seconds
SEARCH_GROUP_REACH=50000       # meters
SEARCH_GROUP_BOUNDS=1

# Rate Limit Settings
# Format: "window:limit,window:limit,..." where window is in seconds
# Example: "60:30" means 30 messages per 60 seconds
RATELIMIT_MESSAGE="60:30,600:60,10800:1200,86400:3600"
RATELIMIT_FAILURE="60:5,600:10"        # NEW: Rate limit for failures
RATELIMIT_CALL="60:5,600:60,10800:1200,86400:3600"
RATELIMIT_LOCATION="60:10,600:60"      # NEW: Rate limit for location updates
RATELIMIT_LOGIN="60:3,600:10"          # NEW: Rate limit for login attempts
RATELIMIT_UPLOAD="60:5,600:20"         # NEW: Rate limit for file uploads

#===========================================
# BUILD AND SEND REQUEST
#===========================================

JSON_PAYLOAD=$(cat <<EOF
{
  "op": "uacset",
  "token": "${APP_TOKEN}",
  "uac": {
    "id": ${UAC_ID},
    "name": "${UAC_NAME}",
    "update": ${UAC_UPDATE},
    "peers": ${PEERS},
    "platforms": "${UAC_PLATFORMS}",
    "android": ${UAC_ANDROID},
    "ios": ${UAC_IOS},
    "javascript": ${UAC_JAVASCRIPT},
    "cpp": ${UAC_CPP},
    "python": ${UAC_PYTHON},
    "sfu": ${UAC_SFU},
    "app": {
      "name": "${APP_NAME}",
      "data": "${APP_DATA}"
    },
    "features": {
      "group": ${FEATURE_GROUP},
      "e2ee": ${FEATURE_E2EE},
      "message": ${FEATURE_MESSAGE},
      "presence": ${FEATURE_PRESENCE},
      "call": ${FEATURE_CALL},
      "sync": ${FEATURE_SYNC},
      "push": ${FEATURE_PUSH},
      "location": ${FEATURE_LOCATION},
      "files": ${FEATURE_FILES}
    },
    "message": {
      "incoming": ${MSG_INCOMING},
      "outgoing": ${MSG_OUTGOING},
      "rich": ${MSG_RICH},
      "broadcast": ${MSG_BROADCAST},
      "read_receipts": ${MSG_READ_RECEIPTS},
      "delivery_receipts": ${MSG_DELIVERY_RECEIPTS},
      "storage": ${MSG_STORAGE},
      "url_preview": ${MSG_URL_PREVIEW},
      "webhook": ${MSG_WEBHOOK}
    },
    "presence": {
      "incoming": ${PRESENCE_INCOMING},
      "outgoing": ${PRESENCE_OUTGOING},
      "typing": ${PRESENCE_TYPING},
      "online": ${PRESENCE_ONLINE},
      "joined": ${PRESENCE_JOINED},
      "lastseen": ${PRESENCE_LASTSEEN},
      "lastseen_resolution": ${PRESENCE_LASTSEEN_RESOLUTION},
      "login": ${PRESENCE_LOGIN},
      "request": ${PRESENCE_REQUEST},
      "online_audience": ${PRESENCE_ONLINE_AUDIENCE},
      "can_override": ${PRESENCE_CAN_OVERRIDE}
    },
    "call": {
      "incoming": ${CALL_INCOMING},
      "outgoing": ${CALL_OUTGOING},
      "video": ${CALL_VIDEO},
      "audio": ${CALL_AUDIO},
      "turn": ${CALL_TURN},
      "hd": ${CALL_HD},
      "fhd": ${CALL_FHD},
      "log": ${CALL_LOG},
      "maxdur": ${CALL_MAXDUR},
      "turn_server": "${CALL_TURN_SERVER}"
    },
    "conf": {
      "video": ${CONF_VIDEO},
      "audio": ${CONF_AUDIO},
      "screen": ${CONF_SCREEN},
      "hd": ${CONF_HD},
      "fhd": ${CONF_FHD},
      "maxdur": ${CONF_MAXDUR}
    },
    "group": {
      "create": ${GROUP_CREATE},
      "member": ${GROUP_MEMBER},
      "message": ${GROUP_MESSAGE},
      "presence": ${GROUP_PRESENCE},
      "call": ${GROUP_CALL},
      "location": ${GROUP_LOCATION},
      "max_groups": ${GROUP_MAX_GROUPS}
    },
    "file": {
      "upload": ${FILE_UPLOAD},
      "signed": ${FILE_SIGNED},
      "max_size": ${FILE_MAX_SIZE},
      "upload_url": "${FILE_UPLOAD_URL}"
    },
    "location": {
      "emulator": ${LOC_EMULATOR},
      "mock": ${LOC_MOCK},
      "send_real": ${LOC_SEND_REAL},
      "send_age": ${LOC_SEND_AGE},
      "can_sub": ${LOC_CAN_SUB},
      "anti_triang": ${LOC_ANTI_TRIANG},
      "user": {
        "reach": ${LOC_USER_REACH},
        "accuracy": ${LOC_USER_ACCURACY},
        "fuzziness": ${LOC_USER_FUZZINESS},
        "maxage": ${LOC_USER_MAXAGE}
      },
      "group": {
        "reach": ${LOC_GROUP_REACH},
        "maxage": ${LOC_GROUP_MAXAGE}
      },
      "subs": {
        "count": ${LOC_SUBS_COUNT},
        "duration": ${LOC_SUBS_DURATION},
        "sendreal": ${LOC_SUBS_SENDREAL}
      }
    },
    "proximity_search": {
      "user": {
        "min_radius": ${SEARCH_USER_MIN_RADIUS},
        "max_radius": ${SEARCH_USER_MAX_RADIUS},
        "maxage": ${SEARCH_USER_MAXAGE},
        "reach": ${SEARCH_USER_REACH},
        "bounds": ${SEARCH_USER_BOUNDS}
      },
      "group": {
        "min_radius": ${SEARCH_GROUP_MIN_RADIUS},
        "max_radius": ${SEARCH_GROUP_MAX_RADIUS},
        "maxage": ${SEARCH_GROUP_MAXAGE},
        "reach": ${SEARCH_GROUP_REACH},
        "bounds": ${SEARCH_GROUP_BOUNDS}
      }
    },
    "ratelimit": {
      "message": "${RATELIMIT_MESSAGE}",
      "call": "${RATELIMIT_CALL}",
      "upload": "${RATELIMIT_UPLOAD}",
      "location": "${RATELIMIT_LOCATION}",
      "login": "${RATELIMIT_LOGIN}",
      "failure": "${RATELIMIT_FAILURE}"
    }
  }
}
EOF
)

# Execute request
echo "Sending UAC request..."
echo ""
curl --header "Content-Type: application/json" \
     --request POST \
     --data "${JSON_PAYLOAD}" \
     "${API_URL}"

echo ""
echo ""
