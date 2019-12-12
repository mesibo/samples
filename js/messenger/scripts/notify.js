//notify.js

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

/**
Mesibo invokes various Listeners for various events.
For example, when you receive a message, receive an incoming call etc
MesiboNotify is a class of listeners that can be invoked to get real-time notification of events  
**/

function MesiboNotify(o) {
	this.AppContext = o;
}

// You will receive the connection status here
MesiboNotify.prototype.Mesibo_OnConnectionStatus = function(status, value) {
	MesiboLog("MesiboNotify.prototype.Mesibo_OnConnectionStatus: " + status);
	if (status === 1)
		this.AppContext.clear_outbox();
}

// You will receive status of sent messages her
MesiboNotify.prototype.Mesibo_OnMessageStatus = function(m) {

	MesiboLog("MesiboNotify.prototype.Mesibo_OnMessageStatus: from " + m.peer +
		" status: " + m.status);

	this.AppContext.getStorage().onMessageStatus(m);
	MesiboUI_onMessageStatus(m);

}

// You will receive messages here
MesiboNotify.prototype.Mesibo_OnMessage = function(m, data) {

	MesiboLog("TestNotify.prototype.Mesibo_OnMessage: from " + m.peer);

	this.AppContext.getStorage().onMessage(m, data);
	MesiboUI_onMessage(m, data);

}

// You will receive calls here
MesiboNotify.prototype.Mesibo_OnCall = function(callid, from, video) {
	this.is_video_call = video ? true : false;
	if (video)
		this.AppContext.getInstance().setupVideoCall("localVideo", "remoteVideo", true);
	else
		this.AppContext.getInstance().setupVoiceCall("audioPlayer");

	var s = document.getElementById("ansBody");
	if (s) {
		s.innerText = "Incoming " + (video ? "Video" : "Voice") + " call from: " + from;
	}

	$('#answerModal').modal({
		show: true
	});
}

// You will receive call status here
MesiboNotify.prototype.Mesibo_OnCallStatus = function(callid, status) {
	console.log("Mesibo_onCallStatus: " + status);
	var v = document.getElementById("vcstatus");
	var a = document.getElementById("acstatus");

	var s = "Complete";

	switch (status) {
		case MESIBO_CALLSTATUS_RINGING:
			s = "Ringing";
			break;

		case MESIBO_CALLSTATUS_ANSWER:
			s = "Answered";
			break;

		case MESIBO_CALLSTATUS_BUSY:
			s = "Busy";
			break;

		case MESIBO_CALLSTATUS_NOANSWER:
			s = "No Answer";
			break;

		case MESIBO_CALLSTATUS_INVALIDDEST:
			s = "Invalid Destination";
			break;

		case MESIBO_CALLSTATUS_UNREACHABLE:
			s = "Unreachable";
			break;

		case MESIBO_CALLSTATUS_OFFLINE:
			s = "Offline";
			break;
	}

	v.innerText = "Call Status: " + s;
	a.innerText = "Call Status: " + s;

	if (status & MESIBO_CALLSTATUS_COMPLETE) {
		if (this.is_video_call)
			$('#videoModal').modal("hide");
		else
			$('#voiceModal').modal("hide");
	}
}

MesiboNotify.prototype.Mesibo_isVideoCall = function() {
	return this.is_video_call;
}