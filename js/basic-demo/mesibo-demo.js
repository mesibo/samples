
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

MesiboListener.prototype.Mesibo_onConnectionStatus = function(status, value) {
	console.log("Mesibo_onConnectionStatus: "  + status);
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

MesiboListener.prototype.Mesibo_onMessageStatus = function(m) {
	console.log("Mesibo_onMessageStatus: from "  + m.peer + " status: " + m.status + " id: " + m.mid);
}

MesiboListener.prototype.Mesibo_onMessage = function(m) {
	console.log("Mesibo_onMessage: from "  + m.peer + " id: " + m.mid + " msg: " + m.message);
}

MesiboListener.prototype.Mesibo_onCall = function(callid, from, video) {
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

MesiboListener.prototype.Mesibo_onCallStatus = function(callid, status) {
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
var listener = new MesiboListener(api);
api.setListener(listener);
api.setCredentials(demo_user_token);
api.setDatabase("mesibo");
api.start();

var profile = api.getProfile(demo_destination, 0);

function sendMessage() {
	var m = profile.newMessage();
	m.message = "Hello From JS";
	m.send();
}

function sendFile() {
	var m = profile.newMessage();
	m.message = 'Hello from js';
	m.title = 'Himalaya';
	m.message = 'Everest';

	// You can either specify file element id or enter details manually
	if(true) {
		m.setContent('filefield'); // recommended approach
	} else {
		m.setContent('https://cdn.pixabay.com/photo/2019/08/02/09/39/mugunghwa-4379251_1280.jpg');
		m.setContentType(MESIBO_FILETYPE_IMAGE);	
		m.title = 'Himalaya';
		m.message = 'Everest';
	}

	m.send();
}

function readMessages() {
	var rs = profile.createReadSession(listener);
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
