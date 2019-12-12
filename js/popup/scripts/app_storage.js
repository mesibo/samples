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
	this.messageList = this._getMessagesFromStorage();
	this.lastRead = {};

}

MesiboStorage.prototype._getMessagesFromStorage = function() {
	var ml = JSON.parse(localStorage.getItem("Mesibo_Messages_Local_Storage")) || [];
	return ml;
}


MesiboStorage.prototype._updateMessagesInStorage = function() {
	localStorage.setItem("Mesibo_Messages_Local_Storage", JSON.stringify(this.messageList));
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

	//Update read receipt for all previously delievered messages

	for (var i = msgIdPos - 1; i >= 0; i--) {
		if (MESIBO_MSGSTATUS_READ == this.messageList[i]['status'])
			return 0;  //last read reached. 

		if (MESIBO_MSGSTATUS_DELIVERED == this.messageList[i]['status']) {
			this.messageList[i]['status'] = MESIBO_MSGSTATUS_READ;
			this.messageList[i]['params']['status'] = MESIBO_MSGSTATUS_READ;
		}
	}

}

/**
* For a read receipt sent , mark all messages before that also as read.
* If marked read, read receipt will not be sent for that message
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

	for (var i = msgIdPos; i >= 0; i--) {
		if (this.messageList[i]['sender'] == MESIBO_USER_DESTINATION) {
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



MesiboStorage.prototype.onMessage = function(m, data) {

	// Item already in storage. No need to add to storage
	if ((MESIBO_ORIGIN_DBMESSAGE == m.origin) || (MESIBO_ORIGIN_DBSUMMARY == m.origin) || m.presence)
		return 0;

	let msg = {
		id: m.id
		, time: mDate().toString()
		, params: m
	, };

	if ('status' in m) { //Status exists only for sent Messages
		msg.sender = 0;
		msg.recvId = MESIBO_USER_DESTINATION;
		msg.status = m.status;
	} else {
		msg.sender = MESIBO_USER_DESTINATION;
		msg.recvId = 0;
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
