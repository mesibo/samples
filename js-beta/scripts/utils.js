//utils.js      


const MESIBO_READFLAG_READRECEIPT = 1;
const MESIBO_READFLAG_SENDLAST = 2;
const MESIBO_READFLAG_FIFO = 4;
const MESIBO_READFLAG_SUMMARY = 0x10;
const MESIBO_READFLAG_SENDEOR = 0x20;
const MESIBO_READFLAG_WITHFILES = 0x80;
const MESIBO_MSGSTATUS_OUTBOX = 0
const MESIBO_MSGSTATUS_SENT = 1
const MESIBO_MSGSTATUS_DELIVERED = 2
const MESIBO_MSGSTATUS_READ = 3
const MESIBO_MSGSTATUS_RECEIVEDNEW = 0x12
const MESIBO_MSGSTATUS_RECEIVEDREAD = 0x13
const MESIBO_MSGSTATUS_CALLMISSED = 0x15
const MESIBO_MSGSTATUS_CALLINCOMING = 0x16
const MESIBO_MSGSTATUS_CALLOUTGOING = 0x17
const MESIBO_MSGSTATUS_CUSTOM = 0x20
const MESIBO_MSGSTATUS_FAIL = 0x80
const MESIBO_MSGSTATUS_USEROFFLINE = 0x81
const MESIBO_MSGSTATUS_INBOXFULL = 0x82
const MESIBO_MSGSTATUS_INVALIDDEST = 0x83
const MESIBO_MSGSTATUS_EXPIRED = 0x84
const MESIBO_MSGSTATUS_BLOCKED = 0x88

const MESIBO_MSG_ORIGIN_SENT = 0
const MESIBO_MSG_ORIGIN_RECIEVED = 1

class Mesibo_AppUtils {

  static timeNow() {
    var d = new Date();
    h = (d.getHours() < 10 ? '0' : '') + d.getHours();
    m = (d.getMinutes() < 10 ? '0' : '') + d.getMinutes();
    return h + ':' + m;
  }

  static timeFromTs(ts) {
    var theDate = new Date(ts);
    var dateString = theDate.toLocaleTimeString();
    return dateString.slice(0, 5);
  }

  static dateNow(ts) {
    var theDate = new Date(ts);
    var dateString = theDate.toString();
    return dateString.slice(0, 4) + ', ' + dateString.slice(4, 10);
  }

  static dateYesterday(ts) {
    var today = new Date(ts);
    var yesterday = new Date(today);
    yesterday.setDate(today.getDate() - 1);
    var yesterdayString = yesterday.toString();

    return yesterdayString.slice(0, 4) + ', ' + yesterdayString.slice(4, 10);
  }

  static createRecievedBubble(msg_data) {
    var msgBodyDiv = document.createElement('div');
    msgBodyDiv.className = "row message-body";
    var topReceiverDiv = document.createElement('div');
    topReceiverDiv.className = 'col-sm-12 message-main-receiver'; //top receiver-div-class
    var receiverDiv = document.createElement('div');
    receiverDiv.className = 'receiver';
    var textDiv = document.createElement('div');
    textDiv.className = 'message-text';
    var timeSpan = document.createElement('span');
    timeSpan.className = 'message-time pull-right';

    var msgcontent = document.createTextNode(msg_data['data']);
    var timecontent = document.createTextNode(Mesibo_AppUtils.timeFromTs(msg_data['ts']));

    textDiv.append(msgcontent);
    timeSpan.append(timecontent);
    receiverDiv.append(textDiv);
    receiverDiv.append(timeSpan);
    topReceiverDiv.appendChild(receiverDiv);
    msgBodyDiv.appendChild(topReceiverDiv);

    var mylist = document.getElementById("conversation");
    mylist.appendChild(msgBodyDiv);

  }

  static createImageRecievedBubble(msg_data) {

    var msgBodyDiv = document.createElement('div');
    msgBodyDiv.className = "row message-body";
    var topReceiverDiv = document.createElement('div');
    topReceiverDiv.className = 'col-sm-12 message-main-receiver'; //top sender-div-class
    var receiverDiv = document.createElement('div');
    receiverDiv.className = 'receiver';
    var imgDiv = document.createElement('div');
    imgDiv.className = 'image_container_recieved';
    var imgSrc = document.createElement('img');
    imgSrc.className = 'resize_fit_center';
    imgSrc.setAttribute('src', msg_data['fileurl']);
    var textDiv = document.createElement('div');
    textDiv.className = 'message-text';
    var timeSpan = document.createElement('span');
    timeSpan.className = 'message-time pull-right';

    var msgcontent = document.createTextNode(msg_data['data']);
    var timecontent = document.createTextNode(Mesibo_AppUtils.timeFromTs(msg_data['ts']));

    textDiv.append(msgcontent);
    timeSpan.append(timecontent);
    imgDiv.append(imgSrc);
    receiverDiv.append(imgDiv);
    receiverDiv.append(textDiv);
    receiverDiv.append(timeSpan);
    topReceiverDiv.appendChild(receiverDiv);
    msgBodyDiv.appendChild(topReceiverDiv);

    var mylist = document.getElementById("conversation");
    mylist.appendChild(msgBodyDiv);

  }



  static createSentBubble(msg_data) {

    var msgBodyDiv = document.createElement('div');
    msgBodyDiv.className = "row message-body";
    var topSenderDiv = document.createElement('div');
    topSenderDiv.className = 'col-sm-12 message-main-sender'; //top sender-div-class
    var senderDiv = document.createElement('div');
    senderDiv.className = 'sender';
    var textDiv = document.createElement('div');
    textDiv.className = 'message-text';
    var timeSpan = document.createElement('span');
    timeSpan.className = 'message-time pull-right';

    var statusTick = document.createElement('img');
    statusTick.className = 'status_msg_img';
    Mesibo_AppUtils.updateStatusTick(statusTick, msg_data['status']);
    statusTick.setAttribute("id", msg_data['id']);

    var msgcontent = document.createTextNode(msg_data['data']);
    var timecontent = document.createTextNode(Mesibo_AppUtils.timeFromTs(msg_data['ts']));

    textDiv.append(msgcontent);
    timeSpan.append(timecontent);
    timeSpan.append(statusTick);
    senderDiv.append(textDiv);
    senderDiv.append(timeSpan);
    topSenderDiv.appendChild(senderDiv);
    msgBodyDiv.appendChild(topSenderDiv);

    var mylist = document.getElementById("conversation");
    mylist.appendChild(msgBodyDiv);

  }


  static createImageSentBubble(msg_data) {

    var msgBodyDiv = document.createElement('div');
    msgBodyDiv.className = "row message-body";
    var topSenderDiv = document.createElement('div');
    topSenderDiv.className = 'col-sm-12 message-main-sender'; //top sender-div-class
    var senderDiv = document.createElement('div');
    senderDiv.className = 'sender';

    var imgCont = document.createElement('div');
    imgCont.className = 'image_container';

    var imgDiv = document.createElement('img');
    imgDiv.className = 'resize_fit_center';
    imgDiv.setAttribute('src', msg_data['fileurl']);
    imgDiv.setAttribute('display',"max-width: 200px;");
    
    var textDiv = document.createElement('div');
    textDiv.className = 'message-text';
    var timeSpan = document.createElement('span');
    timeSpan.className = 'message-time pull-right';

    var statusTick = document.createElement('img');
    statusTick.className = 'status_msg_img';
    Mesibo_AppUtils.updateStatusTick(statusTick, msg_data['status']);
    statusTick.setAttribute("id", msg_data['id']);

    var msgcontent = document.createTextNode(msg_data['data']);
    var timecontent = document.createTextNode(Mesibo_AppUtils.timeFromTs(msg_data['ts']));

    textDiv.append(msgcontent);
    timeSpan.append(timecontent);
    timeSpan.append(statusTick);
    senderDiv.append(imgDiv);
    senderDiv.append(textDiv);
    senderDiv.append(timeSpan);
    topSenderDiv.appendChild(senderDiv);
    msgBodyDiv.appendChild(topSenderDiv);

    var mylist = document.getElementById("conversation");
    mylist.appendChild(msgBodyDiv);

  }


  static createDateHeaderForHistory(msg_data, previous_date) {
    var current_date = Mesibo_AppUtils.dateNow(msg_data['ts']);

    if (previous_date != current_date) {
      previous_date = current_date;

      if (current_date == Mesibo_AppUtils.dateNow(+new Date()))
        Mesibo_AppUtils.createDateHeaderBlock("Today");
      else if (current_date == Mesibo_AppUtils.dateYesterday(+new Date()))
        Mesibo_AppUtils.createDateHeaderBlock("Yesterday");
      else
        Mesibo_AppUtils.createDateHeaderBlock(current_date);
    }

    return previous_date;
  }

  static createDateHeaderBlock(date_value) {
    var iDiv = document.createElement('div');
    iDiv.className = "row message-previous";
    var innerDiv = document.createElement('div');
    innerDiv.className = "col-sm-12 previous";
    var headerDiv = document.createElement('div');
    headerDiv.className = 'date_header';
    var datetext = document.createTextNode(date_value);

    headerDiv.append(datetext);
    innerDiv.append(headerDiv);
    iDiv.append(innerDiv);

    var mylist = document.getElementById("conversation")
    mylist.appendChild(iDiv);
  }

  static getUserFromPhone(phone_number, phone_book) {
    // console.log(phone_number, phone_book);
    var user_list = Object.keys(phone_book);

    for (var i = 0; i < user_list.length; i++) {
      // console.log(phone_book[user_list[i]]['phone'] == phone_number)
      if (phone_book[user_list[i]]['phone'] == phone_number)
        return user_list[i];
    }

    console.log("User does not exist with phone phone number", phone_number);
    return -1;
  }


  static updateStatusTick(statusTick, status) {
    if (statusTick) {

      switch (status) {

        case MESIBO_MSGSTATUS_SENT:
          statusTick.setAttribute("src", "images/mesibo_single_tick.png");
          break;

        case MESIBO_MSGSTATUS_DELIVERED:
          statusTick.setAttribute("src", "images/mesibo_double_tick.png");
          break;


        case MESIBO_MSGSTATUS_READ:
          statusTick.setAttribute("src", "images/mesibo_double_tick_coloured.png");
          break;

        default:
          statusTick.setAttribute("src", "images/mesibo_timer.png");

      }
    }

  }

  static updateReadPrevious(pMsgArray, pMsgId) {
    console.log("===>utils:updateReadPrevious called ");
    var MsgIdPos = -1;
    for (var i = pMsgArray.length - 1; i >= 0; i--) {
      if (pMsgArray[i]['id'] == pMsgId) {
        MsgIdPos = i;
        break;
      }
    }

    if (MsgIdPos == -1) {
      console.log("Error:utils:updateReadPrevious:MsgId not found in array of sent Messages");
      return -1;
    }

    //Update read receipt for all previously delievered messages
    //TBD: Maybe have a lastMsgRead pos in ls,to make iterate faster and stop it there

    // console.log(pMsgArray);

    for (var i = MsgIdPos - 1; i >= 0; i--) {
      if (pMsgArray[i]['status'] == MESIBO_MSGSTATUS_DELIVERED | MESIBO_MSGSTATUS_READ) {
        pMsgArray[i]['data'];
        Mesibo_AppUtils.updateStatusTick(document.getElementById(pMsgArray[i]['id']), MESIBO_MSGSTATUS_READ);
      }
    }

  }

  static updateScroll() {
    var objDiv = document.getElementById("conversation");
    objDiv.scrollTop = objDiv.scrollHeight;
  }

  static updateProfilePic(user_name, file_path) {
    document.getElementById(user_name).setAttribute("src", file_path);
  }

  static updateLastMsg(selected_user_name, selected_user_id) {

    var lastMsgId = String(selected_user_name) + "_LastMsg";
    var lastMsgDateId = String(selected_user_name) + "_LastDate";
    var lastMsgStatusId = String(selected_user_name) + "_LastStatus";
    console.log(lastMsgStatusId);

    var lastMsgArea = document.getElementById(lastMsgId);
    $(lastMsgId).text('');
    var lastMsgDateArea = document.getElementById(lastMsgDateId);
    $(lastMsgDateId).text('');
    var lastMsgStatusArea = document.getElementById(lastMsgStatusId);


    var retrievedMsgArray = localStorage.getItem(selected_user_id);
    retrievedMsgArray = JSON.parse(retrievedMsgArray);

    if (retrievedMsgArray) {

      var lastMsgContent = retrievedMsgArray[retrievedMsgArray.length - 1];
      if (lastMsgContent['data'].length > 20)
        lastMsgArea.innerHTML = lastMsgContent['data'].slice(0, 20) + " ...";
      else
        lastMsgArea.innerHTML = lastMsgContent['data'];


      if (Mesibo_AppUtils.dateNow(lastMsgContent['ts']) == Mesibo_AppUtils.dateYesterday(+new Date()))
        lastMsgDateArea.innerHTML = 'Yesterday';
      else if (Mesibo_AppUtils.dateNow(lastMsgContent['ts']) == Mesibo_AppUtils.dateNow(+new Date()))
        lastMsgDateArea.innerHTML = Mesibo_AppUtils.timeFromTs(lastMsgContent['ts']);
      else {
        var dateValue = new Date(lastMsgContent['ts']);
        lastMsgDateArea.innerHTML = dateValue.getDate() + "/" + (dateValue.getMonth() + 1) + "/" + dateValue.getFullYear()
      }


      if (lastMsgContent['flag'] == 3) { //Message Recieved, Don't show status tick
        lastMsgStatusArea.style.display = "none";
      } else {
        lastMsgStatusArea.style.display = "inline";
        Mesibo_AppUtils.updateStatusTick(lastMsgStatusArea, lastMsgContent['status']);
      }
    }

  }

  static getLastTs(selected_user_id) {
    var retrievedMsgArray = localStorage.getItem(selected_user_id);

    retrievedMsgArray = JSON.parse(retrievedMsgArray);
    if (retrievedMsgArray) {
      // console.log(retrievedMsgArray);
      var lastMsgContent = retrievedMsgArray[retrievedMsgArray.length - 1];
      return lastMsgContent['ts'];
    } else
      return 0;
  }

  static updateUserListOrder(phone_book) {
    var $divs = $("#UserList .row.sideBar-body");
    var TimeOrderedDivs = $divs.sort(function(a, b) {
      return Mesibo_AppUtils.getLastTs(phone_book[b.id]['phone']) - Mesibo_AppUtils.getLastTs((phone_book[a.id]['phone']));
    });
    $("#UserList").html(TimeOrderedDivs);
  }


  static createContactsListDisplay(contactsArray) {
    console.log("===>utils:createContactsListDisplay called ");
    // console.log(contactsArray);
    if (contactsArray) {
      for (var i = 0; i < contactsArray.length; i++)
        Mesibo_AppUtils.createProfileBlock(contactsArray[i]);
    }

  }

  //If sync is required
  static getSyncPhoneBook(contactsArray) {
    console.log("===>Mesibo_AppUtils.getSyncPhoneBook called");
    //If you need to synchronise contact names provide a json object in the following format

    var SyncPhoneBook = {
      "phone_number": {
        "name": "contact_name",
        "phone": "phone_number"
      },

      //For example     
      "91xxxxxxxxxx": {
        "name": "Test User",
        "phone": "91xxxxxxxxxx"
      },
    };

    console.log(contactsArray);
    var NewPhoneBook = {};


    if (contactsArray && SyncPhoneBook) {
      for (var i = 0; i < contactsArray.length; i++) {
        if (Object.keys(SyncPhoneBook).includes(contactsArray[i]['phone'])) {
          contactsArray[i]['name'] = SyncPhoneBook[contactsArray[i]['phone']]['name'];
          NewPhoneBook[contactsArray[i]['name']] = contactsArray[i];
        }
      }
    }

    return NewPhoneBook;

  }

  static getPhoneBookFromContacts(contactsArray) {

    var NewPhoneBook = {};
    for (var i = 0; i < contactsArray.length; i++) {
      NewPhoneBook[contactsArray[i]['name']] = contactsArray[i];
    }
    return NewPhoneBook
  }

  static createProfileBlock(profileDetails) {
    // console.log("===> utils:createProfileBlock called ");
    var rowBodyDiv = document.createElement('div');
    rowBodyDiv.className = "row sideBar-body";
    rowBodyDiv.onclick = function() {
      loadChatHistory(profileDetails['name']);
    };

    var profilePicDiv = document.createElement('div');
    profilePicDiv.className = "col-sm-3 col-xs-3 sideBar-avatar";
    var profilePicIconDiv = document.createElement('div');
    profilePicIconDiv.className = "avatar-icon";
    var profilePic = document.createElement('img');
    if (profileDetails['photo'])
      profilePic.setAttribute("src", "https://appimages.mesibo.com/" + profileDetails['photo']);
    else
      profilePic.setAttribute("src", "images/profile/default-profile-icon-16.jpg ");

    var profileNameMainDiv = document.createElement('div');
    profileNameMainDiv.className = "col-sm-9 col-xs-9 sideBar-main";
    var profileNameRowDiv = document.createElement('div');
    profileNameRowDiv.className = "row";
    var profileNameBlockDiv = document.createElement('div');
    profileNameBlockDiv.className = "col-sm-8 col-xs-8 sideBar-name";
    var profileNameSpan = document.createElement('span');
    profileNameSpan.className = "name-meta";

    var profileNameValidText = "Unknown"
    if (profileDetails['name'])
      profileNameValidText = profileDetails['name'];

    var profileNameText = document.createTextNode(profileNameValidText); //Name
    var profileNameStrongText = document.createElement('strong');
    var profileStatusPara = document.createElement('p');
    var profileStatusText = document.createTextNode(profileDetails['status']); //Status

    profileStatusPara.append(profileStatusText);
    profileNameStrongText.append(profileNameText)
    profileNameSpan.append(profileNameStrongText);
    profileNameSpan.append(profileStatusPara);
    profileNameBlockDiv.append(profileNameSpan);
    profileNameRowDiv.append(profileNameBlockDiv);
    profileNameMainDiv.append(profileNameRowDiv);

    profilePicIconDiv.append(profilePic);
    profilePicDiv.append(profilePicIconDiv);

    rowBodyDiv.append(profilePicDiv);
    rowBodyDiv.append(profileNameMainDiv);


    var myContactsList = document.getElementById("syncedContactsList");
    myContactsList.appendChild(rowBodyDiv);

  }

  static createActivePeerBlock(userName, PhoneBook) {
    console.log("===>utils:createActivePeerBlock called for", userName);

    var rowBodyDiv = document.createElement('div');
    rowBodyDiv.className = "row sideBar-body";
    rowBodyDiv.onclick = function() {
      loadChatHistory(userName);
    };

    rowBodyDiv.setAttribute("id", userName);
    var profilePicDiv = document.createElement('div');
    profilePicDiv.className = "col-sm-3 col-xs-3 sideBar-avatar";
    var profilePicIconDiv = document.createElement('div');
    profilePicIconDiv.className = "avatar-icon";
    var profilePic = document.createElement('img');
    profilePic.setAttribute('id', userName + "_ProfilePicture");
    if (PhoneBook[userName]['photo'])
      profilePic.setAttribute("src", "https://appimages.mesibo.com/" + PhoneBook[userName]['photo']);
    else
      profilePic.setAttribute("src", "images/profile/default-profile-icon-16.jpg ");

    var profileNameMainDiv = document.createElement('div');
    profileNameMainDiv.className = "col-sm-9 col-xs-9 sideBar-main";
    var profileNameRowDiv = document.createElement('div');
    profileNameRowDiv.className = "row";
    var profileNameBlockDiv = document.createElement('div');
    profileNameBlockDiv.className = "col-sm-8 col-xs-8 sideBar-name";
    var profileNameSpan = document.createElement('span');
    profileNameSpan.className = "name-meta";

    var profileNameValidText = "Unknown"
    if (userName)
      profileNameValidText = PhoneBook[userName]['name'];

    var profileNameText = document.createTextNode(profileNameValidText); //Name
    var profileNameStrongText = document.createElement('strong');

    var profileStatusDiv = document.createElement('div');
    var profileStatusTick = document.createElement('img'); //Status Tick
    profileStatusTick.className = "last_msg_status";
    profileStatusTick.setAttribute('id', userName + "_LastStatus");
    profileStatusTick.setAttribute('style', "display: none;");

    var profileLastMessage = document.createElement('div');
    profileLastMessage.className = "last_msg_text";
    profileLastMessage.setAttribute('id', userName + "_LastMsg");

    var profileLastDate = document.createElement('div');
    profileLastDate.className = "col-sm-4 col-xs-4 pull-right sideBar-time";
    var profileLastDateSpan = document.createElement('span');
    profileLastDateSpan.className = "time-meta pull-right";
    profileLastDateSpan.setAttribute('id', userName + "_LastDate");

    profileLastDate.append(profileLastDateSpan);
    profileStatusDiv.append(profileStatusTick);
    profileStatusDiv.append(profileLastMessage);
    profileNameStrongText.append(profileNameText)
    profileNameSpan.append(profileNameStrongText);
    profileNameSpan.append(profileStatusDiv);
    profileNameBlockDiv.append(profileNameSpan);
    profileNameRowDiv.append(profileNameBlockDiv);
    profileNameRowDiv.append(profileLastDate);
    profileNameMainDiv.append(profileNameRowDiv);
    profilePicIconDiv.append(profilePic);
    profilePicDiv.append(profilePicIconDiv);
    rowBodyDiv.append(profilePicDiv);
    rowBodyDiv.append(profileNameMainDiv);

    var myActivePeerList = document.getElementById("UserList");
    myActivePeerList.appendChild(rowBodyDiv);


  }


  static displayActiveUsers(activeUserList, PhoneBook) {
    console.log("===>utils:displayActiveUsers called");

    for (var i = 0; i < activeUserList.length; i++) {
      var user_name = Mesibo_AppUtils.getUserFromPhone(activeUserList[i], PhoneBook)
      Mesibo_AppUtils.createActivePeerBlock(user_name, PhoneBook);
      Mesibo_AppUtils.updateProfilePic(user_name + "_ProfilePicture", "https://appimages.mesibo.com/" + PhoneBook[user_name]['photo']);
      Mesibo_AppUtils.updateLastMsg(user_name, activeUserList[i]);
    }
  }

}


// Fetch Contacts
async function fetchContacts(usrToken) {

  const response =
    await fetch('https://app.mesibo.com/api.php?op=getcontacts&token=' + usrToken);

  console.log(response);

  const contactsData = await response.json(); //extract JSON from the http response

  var personsOnly = contactsData['contacts'].filter(function(contact) {
    return contact.gid == 0;
  });

  var PhoneBook = Mesibo_AppUtils.getPhoneBookFromContacts(personsOnly);
  localStorage.setItem("Mesibo_LocalPhoneBook", JSON.stringify(PhoneBook));

  InitDisplay();

  // Syncing with Local Contacts
  Mesibo_AppUtils.createContactsListDisplay(Object.values(PhoneBook));
}

async function uploadAndSendFile(msg_payload, usrToken,AppStorage) {
  console.log("===> uploadAndSendFile called");
  $('#imagePreviewHolder').hide();

  const fileInput = document.querySelector('#imgupload');
  const formData = new FormData();

  console.log(fileInput);
  console.log(fileInput.files[0]);


  formData.append('file', fileInput.files[0]);

  const options = {
    method: 'POST',
    body: formData,

    // If you add this, upload won't work
    // headers: {
    //   'Content-Type': 'multipart/form-data',
    // }

  };

  const response = await fetch('https://s3.mesibo.com/api.php?op=upload&token=' + usrToken, options);
  console.log(response);
  const image_url = await response.json();
  console.log(image_url['file']);

  msg_payload['fileurl'] = image_url['file'];
  AppStorage.updateFileUrl(msg_payload['id'],msg_payload['peer'],image_url['file']);
  Mesibo_AppUtils.createImageSentBubble(msg_payload);
  resize(fileInput.files[0],200,200,'base64',msg_payload,image_url['file']);

}

function sendWithThumbnail(imgFile,msg_payload,imgUrl) {
  var reader = new FileReader();
  reader.onloadend = function() {
    console.log('RESULT', reader.result);
    var tn_array = new Uint8Array(reader.result); //reader.result from base64
    sendFiletoPeer(msg_payload['peer'], msg_payload['id'], imgUrl,tn_array,msg_payload['data']);
  }
  reader.readAsArrayBuffer(imgFile);
}






Array.prototype.contains = function(v) {
  for (var i = 0; i < Mesibo_AppUtils.length; i++) {
    if (Mesibo_AppUtils[i] === v) return true;
  }
  return false;
};

Array.prototype.unique = function() {
  var arr = [];
  for (var i = 0; i < Mesibo_AppUtils.length; i++) {
    if (!arr.contains(Mesibo_AppUtils[i])) {
      arr.push(Mesibo_AppUtils[i]);
    }
  }
  return arr;
}

function resize(file, max_width, max_height, imageEncoding , msg_payload, imgUrl){
    var fileLoader = new FileReader(),
    canvas = document.createElement('canvas'),
    context = null,
    imageObj = new Image(),
    blob = null;            

    //create a hidden canvas object we can use to create the new resized image data
    canvas.id     = "hiddenCanvas";
    canvas.width  = max_width;
    canvas.height = max_height;
    canvas.style.visibility   = "hidden";   
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
        if(this.width == 0 || this.height == 0){
            alert('Image is empty');
        } else {                

            context.clearRect(0,0,max_width,max_height);
            context.drawImage(imageObj, 0, 0, this.width, this.height, 0, 0, max_width, max_height);


            blob = dataURItoBlob(canvas.toDataURL(imageEncoding));

            //pass this blob to your upload function
            // upload(blob);
            sendWithThumbnail(blob,msg_payload,imgUrl)
            
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
  // doesn't handle URLEncoded DataURIs - see SO answer #6850276 for code that does this
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
  var blob = new Blob([ab], {type: mimeString});
  return blob;

}