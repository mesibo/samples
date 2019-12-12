// files.js

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
//Send files like image, video, documents, etc
let sendFile = (pFileType, pFileurl, pThumbnail) => {

	let caption = DOM.fileCaption.value;
	DOM.fileCaption.value = "";

	mid = MesiboDemoApp.getInstance().random();
	var p = {
		'id': mid
		, 'peer': MesiboDemoApp.getStorage().getContactPropertyMatching('number', 'name', DOM.messageAreaName.innerHTML)
		, 'gid': 0
		, 'channel': 0
		, 'origin': MESIBO_ORIGIN_REALTIME
		, 'flag': MESIBO_FLAG_DEFAULT
		, 'status': MESIBO_MSGSTATUS_OUTBOX,

		'filetype': pFileType, //For image
		'fileurl': pFileurl
	, };

	var rich_msg = {
		type: p.filetype
		, size: 0
		, url: p.fileurl
		, tn  : p.thumbnail,
		message: caption ? new TextEncoder().encode(caption) : ""
	, };

	MesiboDemoApp.triggerOnMessage(p, caption ? caption : "");

	p = {};
	p.peer = MesiboDemoApp.getStorage().getContactPropertyMatching('number', 'name', DOM.messageAreaName.innerHTML);
	p.flag = MESIBO_FLAG_DEFAULT;
	p.type = 0;
	p.expiry = 3600 * 24;

	MesiboDemoApp.getInstance().sendFile(p, mid, rich_msg);

};

function sendResizedImage(file, max_width, max_height, imageEncoding, imgUrl) {
	var fileLoader = new FileReader()
		, canvas = document.createElement('canvas')
		, context = null
		, imageObj = new Image()
		, blob = null;

	//create a hidden canvas object we can use to create the new resized image data
	canvas.id = "hiddenCanvas";
	canvas.width = max_width;
	canvas.height = max_height;
	canvas.style.visibility = "hidden";
	document.body.appendChild(canvas);

	//get the context to use 
	context = canvas.getContext('2d');

	// check for an image then
	//trigger the file loader to get the data from the image         
	if (file.type.match('image.*')) {
		fileLoader.readAsDataURL(file);
	} else {
		alert('File is not an image');
	}

	// setup the file loader onload function
	// once the file loader has the data it passes it to the 
	// image object which, once the image has loaded, 
	// triggers the images onload function
	fileLoader.onload = function() {
		var data = this.result;
		imageObj.src = data;
	};

	fileLoader.onabort = function() {
		alert("The upload was aborted.");
	};

	fileLoader.onerror = function() {
		alert("An error occured while reading the file.");
	};


	// set up the images onload function which clears the hidden canvas context, 
	// draws the new image then gets the blob data from it
	imageObj.onload = function() {

		// Check for empty images
		if (0 == this.width || 0 == this.height) {
			alert('Image is empty');
		} else {

			context.clearRect(0, 0, max_width, max_height);
			context.drawImage(imageObj, 0, 0, this.width, this.height, 0, 0, max_width, max_height);
			blob = dataURItoBlob(canvas.toDataURL(imageEncoding));
			sendWithThumbnail(blob, imgUrl)

		}
	};

	imageObj.onabort = function() {
		alert("Image load was aborted.");
	};

	imageObj.onerror = function() {
		alert("An error occured while loading image.");
	};

}

function dataURItoBlob(dataURI) {
	// convert base64 to raw binary data held in a string
	// doesn't handle URLEncoded DataURIs 
	var byteString = atob(dataURI.split(',')[1]);

	// separate out the mime component
	var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0]

	// write the bytes of the string to an ArrayBuffer
	var ab = new ArrayBuffer(byteString.length);

	// create a view into the buffer
	var ia = new Uint8Array(ab);

	// set the bytes of the buffer to the correct values
	for (var i = 0; i < byteString.length; i++) {
		ia[i] = byteString.charCodeAt(i);
	}

	// write the ArrayBuffer to a blob, and you're done
	var blob = new Blob([ab], {
		type: mimeString
	});
	return blob;

}

async function uploadSendFile() {

	f = DOM.fileInput.files[0];
	//Validate file type before proceeding. Only images handled here
	const formData = new FormData();

	formData.append('file', f);

	const options = {
		method: 'POST'
		, body: formData,

	};

	const response = await fetch(MesiboDemoApp.getStorage().uploadUrl + '?op=upload&token=' + MESIBO_ACCESS_TOKEN
		, options);

	const file_url = await response.json();

	sendResizedImage(f, 200, 200, 'base64', file_url['file']); //Compression required

}

function sendWithThumbnail(blob, imgUrl) {
	var reader = new FileReader();
	reader.onloadend = function() {
		var tn_array = new Uint8Array(reader.result); //reader.result from base64
		sendFile(1, imgUrl, tn_array); //Sending Image
	}
	reader.readAsArrayBuffer(blob);
}

// One validation function for all file types    
function isValidFileType(fName, fType) {
	var extensionLists = {}; //Create an object for all extension lists
	extensionLists.video = ['m4v', 'avi', 'mpg', 'mp4', 'webm'];
	extensionLists.image = ['jpg', 'gif', 'bmp', 'png'];
	return extensionLists[fType].indexOf(fName.split('.').pop()) > -1;
}

function showFilePreview(input) {

	var f = null;
	//Modify preview src attr in file modal
	if (input.files && input.files[0]) {
		f = input.files[0];
		var reader = new FileReader();

		reader.onload = function(e) {
			$('#image-preview').attr('src', e.target.result);
		}

		reader.readAsDataURL(input.files[0]);
	} else
		return false;

	var s = getById("fileModalLabel");
	if (s) {
		s.innerText = "Selected File: " + (isValidFileType(f.name, 'image') ? f.name : "FILE TYPE NOT SUPPORTED");
		gSelectedFile = f.name;
	}

	$('#fileModal').modal("show");
}

function closeFilePreview() {
	$('#fileModal').modal("hide");
	//Clear selected file button attr
}