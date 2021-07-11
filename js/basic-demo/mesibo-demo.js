
/* Refer following tutorial and API documentation to know how to create a user token
 * https://mesibo.com/documentation/tutorials/first-app/ 
 */
var demo_user_token = '<token>';
/* App ID used to create a user token. */
var demo_appid = 'com.mesibo.firstapp';
/* A destination where this demo app will send message or make calls */
var demo_destination = '18005551234';


function MesiboListener(o) {
	this.api = o;
}

MesiboListener.prototype.Mesibo_OnConnectionStatus = function(status, value) {
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

MesiboListener.prototype.Mesibo_OnMessageStatus = function(m) {
	console.log("Mesibo_OnMessageStatus: from "  + m.peer + " status: " + m.status + " id: " + m.id);
}

MesiboListener.prototype.Mesibo_OnMessage = function(m, data) {
	var s = array2String(data, 0, data.byteLength);
	console.log("Mesibo_OnMessage: from "  + m.peer + " id: " + m.id + " msg: " + s);
	console.log(data);
}

MesiboListener.prototype.Mesibo_OnCall = function(callid, from, video) {
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

MesiboListener.prototype.Mesibo_OnCallStatus = function(callid, status) {
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
api.setListener(new MesiboListener(api));
api.setCredentials(demo_user_token);
api.setDatabase("mesibo");
api.start();

var message_index = 0;
var profile = api.getProfile(demo_destination, 0);

function sendMessage() {
	profile.sendMessage(api.random(), message_index + ": Hello From JS");
	message_index++;
}

function sendFile() {
	var msg = {}; //create a rich message
	
	msg.message = 'Hello from js';

	// You can either specify file element id or enter details manually
	if(true) {
		msg.file = 'filefield'; // recommended approach
	} else {

		msg.filetype = MESIBO_FILETYPE_IMAGE;	
		msg.size = 1023;	
		msg.fileurl = 'https://cdn.pixabay.com/photo/2019/08/02/09/39/mugunghwa-4379251_1280.jpg'
		msg.title = 'Himalaya';
	}

	profile.sendFile(api.random(), msg);
}

function sendReadReceipt() {
	var rs = profile.readDbSession(null, function(count) {

	});

	rs.enableReadReceipt(true);
	rs.read(100);
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

function updateProfile() {
	var sp = api.getSelfProfile();
	var n = document.getElementById("name");
	sp.setName(n.value);
	sp.setStatus("My status");
	
	// profileimage is in demo.html
	sp.setImage("profileimage");

	sp.save();
}

function createGroup() {
	// createGroup function can take listener or function as the last parameter
	api.createGroup("My Group From JS", 0, function(profile) {
		console.log("group created");
		addMembers(profile);
	});
}

function addMembers(profile) {
	var gp = profile.getGroupProfile();
	var members = ["123456", "112233"];
	gp.addMembers(members, MESIBO_MEMBERFLAG_ALL, 0);
}
