// calls.js
function videoCall() {
	$('#videoModal').modal("show");
	// Setup UI elements for video call
	MesiboDemoApp.getInstance().setupVideoCall("localVideo", "remoteVideo", true);
	//Video Call API
	MesiboDemoApp.getInstance().call(MesiboDemoApp.getStorage().getContactPropertyMatching('number', 'name', DOM.messageAreaName.innerHTML));
}

function voiceCall() {
	$('#voiceModal').modal("show");
	// Setup UI elements for audio call
	MesiboDemoApp.getInstance().setupVoiceCall("audioPlayer");
	//Voice Call API
	MesiboDemoApp.getInstance().call(MesiboDemoApp.getStorage().getContactPropertyMatching('number', 'name', DOM.messageAreaName.innerHTML));
}

function answer() {
	$('#answerModal').modal("hide");

	//Common modal popup notification for a call. Select the required modal to be displayed
	if (MesiboDemoApp.mesiboNotify.is_video_call)
		video_answer();
	else
		audio_answer();

}

/** Control Modal View **/
function hangup() {
	$('#answerModal').modal("hide");
	MesiboDemoApp.getInstance().hangup(0);
}

function video_answer() {
	$('#videoModal').modal("show");
	MesiboDemoApp.getInstance().answer(true);
}

function video_hangup() {
	$('#videoModal').modal("hide");
	MesiboDemoApp.getInstance().hangup(0);
}

function voice_answer() {
	$('#audioModal').modal("show");
	MesiboDemoApp.getInstance().answer(true);
}

function voice_hangup() {
	$('#audioModal').modal("hide");
	MesiboDemoApp.getInstance().hangup(0);
}

