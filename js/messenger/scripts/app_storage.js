//app_storage.js

/** Copyright (c) 2019 Mesibo
 * https://mesibo.com
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the terms and condition mentioned
 * on https://mesibo.com as well as following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this
 * list of conditions, the following disclaimer and links to documentation and
 * source code repository.
 *
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * Neither the name of Mesibo nor the names of its contributors may be used to
 * endorse or promote products derived from this software without specific prior
 * written permission.
 *
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * Documentation
 * https://mesibo.com/documentation/
 *
 * Source Code Repository
 * https://github.com/mesibo/samples/js-beta
 *
 *
 */

function MesiboStorage() {
	this.user = {};
	this.groupList = [];
	this.messageList = this._getMessagesFromStorage();
	this.contactList = this._getContactsFromStorage(); //Updates contacts and user profile
	this.contactsLastUpdate = 0; //Timestamp for the last time contacts was updated
	this.lastRead = {};
	this.downloadUrl = "";
	this.uploadUrl = "";

}


MesiboStorage.prototype._getMessagesFromStorage = function() {
	var ml = JSON.parse(localStorage.getItem("Mesibo_Messages_Local_Storage")) || [];
	return ml;
}

MesiboStorage.prototype._syncContactList = function(c) {
	var cl = [];
	if (!c) return;

	//Store the contacts locally as per format of choice
	for (var i = 0; i < c.length; i++) {
		var e = {};
		e['id'] = i + 1;
		e['name'] = c[i]['name'];
		e['number'] = c[i]['phone'];
		e['pic'] = this.downloadUrl + c[i]['photo'];
		e['status'] = c[i]['status'];
		cl.push(e);
	}

	return cl;
}


MesiboStorage.prototype._getContactsFromStorage = function() {
	var cl = JSON.parse(localStorage.getItem("Mesibo_Contacts_Local_Storage")) || {};
	MesiboLog(cl, Object.keys(cl).length);

	if (0 !== Object.keys(cl).length) {
		/** 
		The stored  contacts object will also contain details of the profile logged in currently.
		Extract the profile details and store it in context
		**/
		var u = cl['u'];
		var selfUser = {
			id: 0, //Main User
			name: u['name']
			, number: u['phone']
			, pic: this.downloadUrl + u['photo']
		, };

		this.user = selfUser;

		/**
		Store the update time stamp in context. This is done so that the next time you call
		fetchContacts, it will only provide you with the contacts that have changed since that TS.
		**/
		this.contactsLastUpdate = cl['ts']; 

		// Feature currently under implementation: Group Messaging
		cl = cl['contacts'].filter(function(contact) {
			return contact.gid == 0; //Do not load groups
		});
		cl = this._syncContactList(cl);
	}

	return cl;
}


MesiboStorage.prototype._updateMessagesInStorage = function() {
	//Store messages in ls
	localStorage.setItem("Mesibo_Messages_Local_Storage", JSON.stringify(this.messageList));
}

/** Getters **/
MesiboStorage.prototype.getUser = function() {
	return this.user;
}

MesiboStorage.prototype.getByGroupId = function(groupId) {
	return this.messageList.filter(msg => msg.recvIsGroup && msg.recvId === groupId);
}

MesiboStorage.prototype.getByContactId = function(contactId) {
	return this.messageList.filter(msg => {
		return !msg.recvIsGroup && ((msg.sender === this.user.id && msg.recvId === contactId) || (msg.sender === contactId && msg.recvId === this.user.id));
	});
}

MesiboStorage.prototype.getMessages = function() {
	return this.messageList;
}

MesiboStorage.prototype.getLastUnreadMessage = function(peer) {
	for (var i = this.messageList.length - 1; i >= 0; i--)
		if (peer == this.messageList[i]['params']['peer']) {
			var mid = this.messageList[i]['read_status'] ? 0 : this.messageList[i]['id'];
			return mid;
		}

	return 0; //Not found
}

MesiboStorage.prototype.changeStatusById = function(options) {
	this.messageList = this.messageList.map((msg) => {
		if (options.isGroup) {
			if (msg.recvIsGroup && msg.recvId === options.id) msg.status = 2;
		} else {
			if (!msg.recvIsGroup && msg.sender === options.id && msg.recvId === this.user.id) msg.status = 2;
		}
		return msg;
	});
}

MesiboStorage.prototype.addMessage = function(msg) {
	this.messageList.push(msg);
	this._updateMessagesInStorage();
}

MesiboStorage.prototype.getContactPropertyMatching = function(target, key, value){
	//Note: Ensure both key and value are valid properties
	for (i = 0; i < this.contactList.length; i++)
		if (this.contactList[i][key] == value) //Search for a key property with the required value
			return this.contactList[i][target];// If matched, return the required target property

	MesiboLog("No matching property "+ target+ "found for key " + key + "matching "+ value );
	return -1;
}


MesiboStorage.prototype.getContacts = function() {
	return this.contactList;
}

MesiboStorage.prototype.getGroups = function() {
	return this.grouplist;
}

MesiboStorage.prototype.updateContacts = function(cl) {
	this.contactList = cl;
}

MesiboStorage.prototype.updateContactsInStorage = function(c) {
	localStorage.setItem("Mesibo_Contacts_Local_Storage", JSON.stringify(c));
}

/**
* For a read receipt received , mark all messages before that also as read.
**/
MesiboStorage.prototype.updateReadPrevious = function(pMsgId) {

	var msgIdPos = -1;
	for (var i = this.messageList.length - 1; i >= 0; i--) {
		if (this.messageList[i]['id'] == pMsgId) {
			msgIdPos = i;
			break;
		}
	}

	if (msgIdPos == -1) {
		MesiboLog("Error: Storage :updateReadPrevious: MsgId not found in sent Messages");
		return -1;
	}

	//Update read receipt for all previously delivered messages
	//TBD: Maybe have a lastMsgRead pos in ls,to make it faster and stop it there

	for (var i = msgIdPos - 1; i >= 0; i--) {
		if (MESIBO_MSGSTATUS_READ == this.messageList[i]['status'])
			return 0; //last read reached

		if (MESIBO_MSGSTATUS_DELIVERED == this.messageList[i]['status']) {
			this.messageList[i]['status'] = MESIBO_MSGSTATUS_READ;
			this.messageList[i]['params']['status'] = MESIBO_MSGSTATUS_READ;
		}
	}

}

/**
* For a read receipt sent , mark all messages before that also as read.
* If marked read, read receipt will not be sent for that message in the next read call
**/
MesiboStorage.prototype.updateReceivedReadPrevious = function(pMsgId, peer) {

	var msgIdPos = -1;
	for (var i = this.messageList.length - 1; i >= 0; i--) {
		if (this.messageList[i]['id'] == pMsgId) {
			msgIdPos = i;
			break;
		}
	}

	if (-1 == msgIdPos) {
		MesiboLog("Error: Storage :updateReceivedReadPrevious: MsgId not found in sent Messages");
		return -1;
	}

	//Update read receipt for all previously delievered messages
	//Store a lastMsgRead pos in ls,to make it faster and stop it there

	for (var i = msgIdPos; i >= 0; i--) {
		if (this.messageList[i]['sender'] == this.getContactPropertyMatching('id', 'number', peer)) {
			if (this.messageList[i]['read_status'] == false)
				this.messageList[i]['read_status'] = true;
			else
				return 0; //Last read Message reached
		}

	}
}

MesiboStorage.prototype.onMessageStatus = function(m) {
	var i;
	for (i = this.messageList.length - 1; i >= 0; i--) {

		if (this.messageList[i]['id'] == m.id) {
			this.messageList[i]['status'] = m.status;
			this.messageList[i]['params']['status'] = m.status;
			if (MESIBO_MSGSTATUS_READ == m.status)
				this.updateReadPrevious(m.id);
			this._updateMessagesInStorage();
			return 0;
		}
	}

	return -1;
}

MesiboStorage.prototype.updateProfileData = function(m, data) {
	const profileData = decodeString(data);

	for (var i = 0; this.contactList.length; i++) {
		if (contactList['number'] == profileData['phone']) {
			contactList['name'] = profileData['name'];
			contactList['pic'] = this.downloadUrl + profileData['photo'];
			contactList['status'] = profileData['status'];
			return 0;
		}
	}

	MesiboLog("Error: storage: updateProfileData failed");
	return -1;

}

// Add message to storage
MesiboStorage.prototype.onMessage = function(m, data) {

	// Item already in storage. No need to add to storage
	if ((MESIBO_ORIGIN_DBMESSAGE == m.origin) || (MESIBO_ORIGIN_DBSUMMARY == m.origin) || m.presence)
		return 0;

	if (1 == m.type) { //Update in profile
		this.updateProfileData(m, data);
		return 0;
	}

	let msg = {
		id: m.id
		, time: mDate().toString()
		, params: m
	, };

	if ('status' in m) { //Status exists only for sent Messages
		msg.sender = this.user.id;
		msg.recvId = this.getContactPropertyMatching('id', 'number', m.peer);
		msg.status = m.status;
	} else {
		msg.sender = this.getContactPropertyMatching('id', 'number', m.peer);
		msg.recvId = this.user.id;
		msg.recvIsGroup = false;
	}

	if ('filetype' in m) { // For files
		msg.filetype = m.filetype;
		msg.fileurl = m.fileurl;
		msg.body = decodeString(m.message); //Caption
	} else if (data)
		msg.body = decodeString(data);

	this.addMessage(msg);

	return 0;
}


MesiboStorage.prototype.getLatestMessageTime = function(peer) {
	for (var i = this.messageList.length - 1; i >= 0; i--)
		if (this.messageList[i]['params']['peer'] == peer)
			return this.messageList[i].time;

	return 0; //Not found
}

MesiboStorage.prototype.getOldestMessageTime = function(peer) {
	for (var i = 0; i < this.messageList.length; i++)
		if (this.messageList[i]['params']['peer'] == peer) {
			return this.messageList[i].time;
		}

	return 0; //Not found
}

MesiboStorage.prototype.getLastRead = function(peer) {
	if (!(peer in this.lastRead))
		this.updateLastRead(peer, this.messageList.length);

	return this.lastRead[peer];
}

MesiboStorage.prototype.initRead = function(peer) {
	this.updateLastRead(peer, this.messageList.length);
}

MesiboStorage.prototype.updateLastRead = function(peer, lr) {
	this.lastRead[peer] = lr;

	if (this.lastRead[peer] < 0)
		this.lastRead[peer] = 0;
}

/** Read Messages from storage into UI
* Run through messages and get messages matching to given peer
* Then, copy the message object and trigger the onMessage function in notify class
* The origin of the message is set as MESIBO_ORIGIN_DBMESSAGE as messages are being read from storage
**/
MesiboStorage.prototype.read = function(peer, count) {
	let lastRead = this.getLastRead(peer);
	var j = count;
	var nRead = 0;

	for (var i = lastRead - 1; i >= 0 && j > 0; i--, j--) {
		if (this.messageList[i].params.peer == peer) {
			//Filter messages only for selected user
			var msg = {};
			Object.assign(msg, this.messageList[i]);
			msg.params.origin = MESIBO_ORIGIN_DBMESSAGE;
			msg.params.time = this.messageList[i].time;
			msg.body = new TextEncoder().encode(msg.body);
			MesiboDemoApp.mesiboNotify.Mesibo_OnMessage(msg.params, msg.body);
			nRead++;
		}
	}

	this.updateLastRead(peer, lastRead - nRead);

	return nRead;

}
