//core.js

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

function MesiboAppCore() {
	this.accessToken;
	this.appId;
	this.mesiboApi;
	this.mesiboNotify;
	this.mesiboStorage;
	this.selfUser;
	this.init();
}


MesiboAppCore.prototype._MesiboInit = function() {
	//Create Mesibo API instance
	const api = new Mesibo();
	this.mesiboNotify = new MesiboNotify(this);

	//Initialize Mesibo 
	api.setAppName(this.appId);
	api.setListener(this.mesiboNotify);
	api.setCredentials(this.accessToken);
	api.start();
	return api;
}


MesiboAppCore.prototype.init = function() {
	//Pass configuration 
	this.appId = MESIBO_APP_ID;
	this.accessToken = MESIBO_ACCESS_TOKEN;
	this.mesiboApi = this._MesiboInit();
	this.mesiboStorage = new MesiboStorage(); //Initialize storage
}

MesiboAppCore.prototype.getInstance = function() {
	return this.mesiboApi;
}

MesiboAppCore.prototype.getStorage = function() {
	return this.mesiboStorage;
}

MesiboAppCore.prototype.getSelfUser = function() {
	return this.selfUser;
}

MesiboAppCore.prototype.setSelfUser = function(s) {
	this.selfUser = s;
}


MesiboAppCore.prototype._syncContactList = function(c) {
	var cl = [];
	if (!c) return;

	//Syncup with local contacts format
	for (var i = 0; i < c.length && c[i].gid == "0"; i++) {
		var e = {};
		e['id'] = i;
		e['name'] = c[i]['name'];
		e['number'] = c[i]['phone'];
		e['pic'] = this.mesiboStorage.downloadUrl + c[i]['photo'];
		e['status'] = c[i]['status'];
		cl.push(e);
	}

	return cl;
}

MesiboAppCore.prototype.storeContacts = function(c) {

	this.mesiboStorage.updateContactsInStorage(c);
	this.mesiboStorage.downloadUrl = c['urls']['download'];
	this.mesiboStorage.uploadUrl = c['urls']['upload'];

	//Self profile details of logged in user, stored
	var u = c['u'];
	var selfUser = {
		id: 0, //Main User
		name: u['name']
		, number: u['phone']
		, pic: this.mesiboStorage.downloadUrl + u['photo']
	, };
	this.selfUser = selfUser;

	// Syncing with Local Contacts
	var cl = this._syncContactList(c['contacts']);

	this.mesiboStorage.updateContacts(cl);
}

MesiboAppCore.prototype.getContacts = function(c) {
	return this.mesiboStorage.getContacts();
}



MesiboAppCore.prototype.triggerOnMessage = function(m, data) {
	//onMessage callback in notify class
	this.mesiboNotify.Mesibo_OnMessage(m, data);
}

MesiboAppCore.prototype.readMessages = function(peer, count) {

	var nRead = 0;
	if (!this.mesiboStorage.getLastRead(peer)) {
		return nRead; //No messages to be read for selected user
	}

	nRead = this.mesiboStorage.read(peer, count); //Read from DB/Storage
	//This will in turn call onMessage in notify class
	if (nRead)
		updateScroll(30); //Scroll it a bit down 

	return nRead;
}

MesiboAppCore.prototype.readSummary = function() {

	var active_peer_entry = {};
	var ml = this.mesiboStorage.getMessages();

	//Make a hash of all the active peers and their corresponding last message
	for (var i = ml.length - 1; i >= 0; i--) {
		var peer = ml[i]['params']['peer'];
		if (!Object.keys(active_peer_entry).includes(ml[i]['params']['peer'])) {
			active_peer_entry[peer] = ml[i];
		}
	}

	//Read message summary to generate side panel of chat window
	for (var peer in active_peer_entry) {
		var msg = {}
		Object.assign(msg, active_peer_entry[peer]);
		msg.params.origin = MESIBO_ORIGIN_DBSUMMARY;
		this.triggerOnMessage(msg.params, new TextEncoder().encode(msg.body));
	}
}

MesiboAppCore.prototype.sendReadReceipt = function(peer) {
	const mid = this.mesiboStorage.getLastUnreadMessage(peer);

	if (mid) {
		this.mesiboApi.sendReadReceipt({
			'peer': peer
		}, mid);
		this.mesiboStorage.updateReceivedReadPrevious(mid, peer);
	}
	//Otherwise all messages are already read for this peer

	return 0;
}

MesiboAppCore.prototype.clear_outbox = function() {
	//Send messages currently in Out-box. This function is called when connection is switched to  online
	var ml = this.mesiboStorage.getMessages();
	for (var i = ml.length - 1; i >= 0; i--) {
		if (MESIBO_MSGSTATUS_OUTBOX == ml[i]['status'])
			sendMessage(ml[i]['params'], ml[i]['id'], ml[i])
		else break;
	}
}