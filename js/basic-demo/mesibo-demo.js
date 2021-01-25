
/* Refer following tutorial and API documentation to know how to create a user token
 * https://mesibo.com/documentation/tutorials/first-app/ 
 */
var demo_user_token = 'xxxxxxxxxxxxxxxxxxxx';
/* App ID used to create a user token. */
var demo_appid = 'web';
/* A destination where this demo app will send message or make calls */
var demo_destination = '18005551234';


function DemoNotify(o) {
	this.api = o;
}

DemoNotify.prototype.Mesibo_OnConnectionStatus = function(status, value) {
	console.log("Mesibo_OnConnectionStatus: "  + status);
	var s = document.getElementById("cstatus");
	if(!s) return;
	if(MESIBO_STATUS_ONLINE == status) {
		s.classList.replace("btn-danger", "btn-success");
		s.innerText = "You are online";
		return;
	} 
		
	s.classList.replace("btn-success", "btn-danger");
	switch(status) {
		case MESIBO_STATUS_CONNECTING:
			s.innerText = "Connecting";
			break;

		case MESIBO_STATUS_CONNECTFAILURE:
			s.innerText = "Connection Failed";
			break;

		case MESIBO_STATUS_SIGNOUT:
			s.innerText = "Signed out";
			break;

		case MESIBO_STATUS_AUTHFAIL:
			s.innerText = "Disconnected: Bad Token or App ID";
			break;

		default:
			s.innerText = "You are offline";
			break;
	}
}

DemoNotify.prototype.Mesibo_OnMessageStatus = function(m) {
	console.log("Mesibo_OnMessageStatus: from "  + m.peer + " status: " + m.status + " id: " + m.id);
}

DemoNotify.prototype.Mesibo_OnMessage = function(m, data) {
	var s = array2String(data, 0, data.byteLength);
	console.log("Mesibo_OnMessage: from "  + m.peer + " id: " + m.id + " msg: " + s);
	console.log(data);
}

DemoNotify.prototype.Mesibo_OnCall = function(callid, from, video) {
	console.log("Mesibo_onCall: " + (video?"Video":"Voice") + " call from: " + from);
	if(video)
		this.api.setupVideoCall("localVideo", "remoteVideo", true);
	else
		this.api.setupVoiceCall("audioPlayer");

	var s = document.getElementById("ansBody");
	if(s)
		s.innerText = "Incoming " + (video?"Video":"Voice") + " call from: " + from;

	$('#answerModal').modal({ show: true });
}

DemoNotify.prototype.Mesibo_OnCallStatus = function(callid, status) {
	console.log("Mesibo_onCallStatus: " + status);
	var v = document.getElementById("vcstatus");
	var a = document.getElementById("acstatus");

	var s = ""; 
	if(status&MESIBO_CALLSTATUS_COMPLETE) {
		s = "Complete"; 
		console.log("closing");
		$('#answerModal').modal("hide");
	}

	switch(status) {
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
	if(v)
		v.innerText = "Call Status: " + s;

	if(a)
		a.innerText = "Call Status: " + s;
}

var api = new Mesibo();
api.setAppName(demo_appid);
api.setListener(new DemoNotify(api));
api.setCredentials(demo_user_token);
api.setDatabase("mesibo");
api.start();

var message_index = 0;
function sendMessage() {
	var p = {};
	p.peer = demo_destination;	
	p.type = 0;
	p.expiry = 3600*24;
	p.flag = MESIBO_FLAG_DELIVERYRECEIPT|MESIBO_FLAG_READRECEIPT;
	//api.sendMessage(p, 678, "Hello From JavaScript");
	api.sendMessage(p, api.random(), message_index + ": ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz");
	message_index++;

}

function sendFile() {
	var p = {};
	p.peer = demo_destination;	
	p.type = 0;
	p.expiry = 3600*24;
	p.flag = MESIBO_FLAG_DELIVERYRECEIPT|MESIBO_FLAG_READRECEIPT;
	
	var msg = {}; //create a rich message
	msg.filetype = 1;	// 1 for image 2 for video, 3 audio, 10 other
	msg.size = 1023;	
	msg.fileurl = 'https://cdn.pixabay.com/photo/2019/08/02/09/39/mugunghwa-4379251_1280.jpg'
	msg.title = 'Himalaya';
	msg.message = 'Hello from js';
	
	api.sendFile(p, api.random(), msg);
}

function sendReadReceipt() {
	var p = {};
	p.peer = demo_destination;	
	p.type = 0;
	p.expiry = 3600*24;

	var rrid = 13453967264; //id of the message for which we are sending read-receipt 
	api.sendReadReceipt(p, rrid);
}

function video_call() {
	api.setupVideoCall("localVideo", "remoteVideo", true);
	api.call(demo_destination);
}

function video_mute_toggle() {
	api.toggleVideoMute();
}

function audio_mute_toggle() {
	api.toggleAudioMute();
}

function voice_call() {
	api.setupVoiceCall("audioPlayer");
	api.call(demo_destination);
}

function answer() {
	$('#answerModal').modal("hide");
	api.answer(true);
}

function hangup() {
	$('#answerModal').modal("hide");
	api.hangup(0);
}


