//app_ui.js

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

let getById = (id, parent) => parent ? parent.getElementById(id) : getById(id, document);
let getByClass = (className, parent) => parent ? parent.getElementsByClassName(className) : getByClass(className, document);



// 'chat' is used to store the current chat
// which is being opened in the message area
let chat = null;


// this will be used to store the date of the last message
// in the message area
let lastDate = "";
let oldestDate = "";
let oldestTime = "";

// Get the matching status tick icon
let getStatusClass = (status) => {
	var statusTick = "";
	switch (status) {

		case MESIBO_MSGSTATUS_SENT:
			statusTick = "far fa-check-circle";
			break;

		case MESIBO_MSGSTATUS_DELIVERED:
			statusTick = "fas fa-check-circle";
			break;


		case MESIBO_MSGSTATUS_READ:
			statusTick = "fas fa-check-circle";
			break;

		default:
			statusTick = "far fa-clock";
	}

	return statusTick;
};

// If the status value is read type, color it blue. Default color of status icon is gray
let getStatusColor = (status) => {
	var statusColor = "";
	switch (status) {
		case MESIBO_MSGSTATUS_READ:
			statusColor = "blue";
			break;

		default:
			statusColor = "grey";
	}

	return statusColor;
};


let addDateToMessageArea = (date) => {

	document.getElementById("msglist").innerHTML += `
	  <div class="date_header">
            <p id=>${date}</p>
      </div>
      `;

	lastDate = date;
};

let prependDateToMessageArea = (date) => {
	document.getElementById("msglist").insertAdjacentHTML("afterbegin", `
	  <div class="date_header">
            <p id=>${date}</p>
      </div>
      `);

	oldestDate = date;
};

let updateStatusTick = (peer, mid, status) => {

	const statusTick = getById('status_tick_' + mid);

	if (!statusTick) return;
	updateDOMstatus(statusTick, status);

	const lastMessageStatus = getById('chat_list_user_last_message_status_' + MESIBO_USER_DESTINATION);

	if (!lastMessageStatus) return;
	updateDOMstatus(lastMessageStatus, status);

};


let updateDOMstatus = (statusTick, status) => {

	statusTick.className = getStatusClass(status);
	if (MESIBO_MSGSTATUS_READ == status)
		statusTick.style.color = "blue";

};

/**
 * This function is called to add message div element to the message area.
 * The child div elements will contain message body,status tick, etc
 * Note, that this will 'append' the element to the message list ie; To the tail end
 * This is done for adding messages arriving in real-time
 **/

let appendMessageToMessageArea = (msg) => {
	let msgDate = mDate(msg.time).messageListFormat();
	if ((!lastDate) || (lastDate != msgDate) && ('Today' != msgDate)) {
		addDateToMessageArea(msgDate);
	}


	if (msg.sender === 0) {
		let statusClass = getStatusClass(msg.status);
		let statusColor = getStatusColor(msg.status);
		let sendStatus = `<i id="status_tick_${msg.id}" class= "${statusClass}" style = "color:${statusColor}" ></i>`;

		document.getElementById("msglist").innerHTML += `
		    <div class="outgoing_msg">
		          <div class="sent_msg">
		          <div style="max-width: 200px;overflow-wrap: break-word;">
		                <p>${msg.body}</p>
		          </div>      
		                  <div class="d-flex flex-row">
		                    <div id= ${msg.id} class="time ml-auto small text-right flex-shrink-0 align-self-end text-muted" style="float:right">
		                     ${mDate(msg.time).getTime()}
		                       ${(msg.sender === 0) ? sendStatus : ""}
		                    </div>
		                  </div>
		          </div>
			</div>`;
	} else {
		document.getElementById("msglist").innerHTML += `
			 <div class="incoming_msg">
			      <div class="received_msg">
			            <div class="received_withd_msg">
			              <div style="max-width: 200px;overflow-wrap: break-word;">
			              <p>${msg.body}</p>                
			              </div>
			              <div id= ${msg.id} class="time ml-auto small text-left flex-shrink-0 align-self-end text-muted" style="float:left ; padding-bottom: 3px; width: 75px">
			              ${mDate(msg.time).getTime()}
			              </div>
			            </div>
			      </div>
			</div> 
			`;
	}

	updateScroll();
};

/**
 * This function is called to add message div element to the message area.
 * The child div elements will contain message body,status tick, etc
 * Note, that this will 'prepend' the element to the message list ie; To the head/top before other messages
 * This is done for adding messages when reading from database/storage through read API
 * The order of reading messages will be in reverse order so this will prepend messages 
 **/
let prependMessageToMessageArea = (msg) => {

	if (msg.sender === 0) {
		let statusClass = getStatusClass(msg.status);
		let statusColor = getStatusColor(msg.status);
		let sendStatus = `<i id="status_tick_${msg.id}" class= "${statusClass}" style = "color:${statusColor}" ></i>`;

		document.getElementById("msglist").insertAdjacentHTML("afterbegin", `
		    <div class="outgoing_msg">
		          <div class="sent_msg">
		          <div style="max-width: 200px;overflow-wrap: break-word;">
		                <p>${msg.body}</p>
		                </div>
		                  <div class="d-flex flex-row">
		                    <div id= ${msg.id} class="time ml-auto small text-right flex-shrink-0 align-self-end text-muted" style="float:right">
		                     ${mDate(msg.time).getTime()}
		                       ${(msg.sender === 0) ? sendStatus : ""}
		                    </div>
		                  </div>
		          </div>
			</div>
		`);
	} else {

		// var peer_profile_pic = MesiboDemoApp.getStorage().getPhotoFromPhone(MESIBO_USER_DESTINATION);
		document.getElementById("msglist").insertAdjacentHTML("afterbegin", `
			<div class="incoming_msg">
			      <div class="received_msg">
			            <div class="received_withd_msg">
			              <div style="max-width: 200px;overflow-wrap: break-word;">
			              <p>${msg.body}</p>                
			              </div>
			              <div id= ${msg.id} class="time ml-auto small text-left flex-shrink-0 align-self-end text-muted" style="float:left padding-bottom: 3px">
			              ${mDate(msg.time).getTime()}
			              </div>
			            </div>
			      </div>
			</div>`);
	}

	let msgDate = mDate(msg.time).messageListFormat();

	if ((oldestDate != msgDate) && (oldestTime == msg.time)) {
		prependDateToMessageArea(msgDate);
	}

	updateScroll();
};


let updateScroll = (height) => {
	var objDiv = document.getElementById("scrollMessage");
	objDiv.scrollTop = objDiv.scrollHeight;
}

/**
 * This is the UI callback function called from notify class when there is a new message
 * All messages to be added to UI will be through this channel
 * This function handles various message types like text, files, activity/presence information, etc
 **/
let MesiboUI_onMessage = (m, data) => {

	const s = getById('status_indicator');

	//Update Activity indicators
	if (m.presence) {
		s.textContent = "";
		const p = m.presence;
		switch (p) {
			case MESIBO_ACTIVITY_ONLINE:
				s.textContent = "Online";
				break
			case MESIBO_ACTIVITY_TYPING:
				s.textContent = "Typing...";
				break;
		}
		return 0;
	}

	if (MESIBO_ORIGIN_REALTIME == m.origin)
		s.textContent = "";


	let msg = {
		id: m.id
		, time: ((m.origin == MESIBO_ORIGIN_DBMESSAGE) || (m.origin == MESIBO_ORIGIN_DBSUMMARY)) ? m.time : mDate().toString()
		, params: m
	, };

	var msg_type_sent = 'status' in m ? true : false;

	if (msg_type_sent) { //Status exists only for sent Messages
		msg.sender = 0;
		msg.recvId = MESIBO_USER_DESTINATION;
		msg.status = m.status;
		msg.body = decodeString(data);
	} else {
		msg.sender = MESIBO_USER_DESTINATION;
		msg.recvId = 0;
		msg.recvIsGroup = false;
		msg.read = false;
		msg.body = decodeString(data);
	}


	if (MESIBO_ORIGIN_DBMESSAGE == m.origin)
		prependMessageToMessageArea(msg);
	else if (MESIBO_ORIGIN_REALTIME == m.origin) {
		appendMessageToMessageArea(msg);
	}


	return 0;
};

let MesiboUI_updateSentReadPrevious = (pMsgId) => {
	MesiboLog('====> MesiboUI_updateSentReadPrevious called');
	let messages = MesiboDemoApp.getStorage().getMessages();

	var msgIdPos = -1;
	for (var i = messages.length - 1; i >= 0; i--) {
		if (messages[i]['id'] == pMsgId) {
			msgIdPos = i;
			break;
		}
	}

	if (-1 == msgIdPos) {
		MesiboLog("Error: MesiboUI_updateSentReadPrevious: MsgId not found in sent Messages");
		return -1;
	}


	for (var i = msgIdPos - 1; i >= 0; i--) {
		var m_status = messages[i]['status'];

		if ((MESIBO_MSGSTATUS_DELIVERED == m_status) || (MESIBO_MSGSTATUS_READ == m_status)) {
			//MESIBO_MSGSTATUS_READ because it might have already updated in storage, but UI is yet to be updated
			updateStatusTick(messages[i]['params']['peer'], messages[i]['id'], MESIBO_MSGSTATUS_READ);
		}
	}

}

let MesiboUI_onMessageStatus = (m) => {
	updateStatusTick(m.peer, m.id, m.status);
	if (MESIBO_MSGSTATUS_READ == m.status)
		MesiboUI_updateSentReadPrevious(m.id);
};



let sendMessage = (msg_params, msg_id, msg_data) => {
	//In case of resending messages or outbox
	if (msg_params) {
		if (!msg_data['body']) return -1;
		MesiboDemoApp.getInstance().sendMessage(msg_params, msg_id, msg_data);
	}

	var msgdata = document.getElementById("inputfield").value;
	if (!msgdata) return -1;

	document.getElementById("inputfield").value = "";

	const mid = MesiboDemoApp.getInstance().random();
	var p = {
		'id': mid
		, 'peer': MESIBO_USER_DESTINATION
		, 'gid': 0
		, 'channel': 0
		, 'origin': MESIBO_ORIGIN_REALTIME
		, 'flag': MESIBO_FLAG_DEFAULT
		, 'status': MESIBO_MSGSTATUS_OUTBOX
	};


	MesiboDemoApp.triggerOnMessage(p, new TextEncoder().encode(msgdata));

	p = {};
	p.peer = MESIBO_USER_DESTINATION;
	p.flag = MESIBO_FLAG_DEFAULT;

	MesiboDemoApp.getInstance().sendMessage(p, mid, msgdata);
};



//Enter to send Message
document.onkeydown = function(e) {
	e = e || window.event;
	switch (e.which || e.keyCode) {
		case 13: //(13 is ascii code for 'ENTER')
			sendMessage();
			if (event.preventDefault) event.preventDefault();
			break;
	}

}



let mesibo_popup_init = () => {

	//Update profile details
	getById("display_pic").setAttribute('src', MESIBO_DISPLAY_PICTURE);
	getById("display_name").innerHTML = MESIBO_DISPLAY_NAME;

	var peer = MESIBO_USER_DESTINATION;
	var count = 15;

	oldestDate = MesiboDemoApp.getStorage().getLatestMessageTime(peer);
	lastDate = oldestDate ? mDate(oldestDate).getDate() : "";
	oldestTime = MesiboDemoApp.getStorage().getOldestMessageTime(peer);

	MesiboDemoApp.getStorage().initRead(peer);

	MesiboDemoApp.readMessages(peer, count); //Should read last fifteen messages
	MesiboDemoApp.sendReadReceipt(peer);
	updateScroll(); //Pull scroll to bottom

};