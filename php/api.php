<?php
	include_once ("includes.php");

	ConnectToDB();

	$op=GetRequestField('op', '');

	OnEmptyExit($op, 'NOOP');
	$result = array();

	$op = strtolower($op);
	$apifuncname = $op."_callbackapi";
	if(!function_exists($apifuncname)) {
		$result['error'] = 'BADOP';
		DoExit(false, $result);
	}

	$result['op'] = $op;
	$result['ts'] = time(); //always send time so that client know the time diff
	$res = $apifuncname($result);
	DoExit($res, $result);

function login_callbackapi(&$result) {
	$name=GetRequestField('name', '');
	$phone=GetRequestField('phone', '');
	$appid = GetRequestField('aid', '');
	$ns=GetRequestField('ns', '');

	if($appid == '') {
		$result['error'] = 'MISSINGAID';
		return false;
	}
	
	if($ns == '') {
		$result['error'] = 'MISSINGNS';
		return false;
	}

	if(strlen($phone) < 9) {
		$result['error'] = 'BADPHONE';
		return false;
	}

	$response = MesiboAddUser($phone, $appid, 0, 365*24*60, 0);
	if(!$response || !$response['result']) {
		$result['error'] = 'APIERR'.$response['error'];
		return false;
	}

	$newuser = 0;
	$ts = time(); 
	$token = $response['user']['token'];
	$uid = $response['user']['uid'];
	$result['token'] = $token;

	$values = "uid=$uid, ns='$ns', name='$name', phone='$phone', token='$token', ts=$ts";
	SetQueryDB("insert into users set $values on duplicate key update $values");
	
	$query = "select name, phone from users where ns='$ns' and phone!='$phone' order by ts desc limit 10";
	webapi_getrecords($query, $result, null, 'contacts', '');

	contact_update_notify($name, $phone, $ns);
	return true; 
}

function logout_callbackapi(&$result) {
	$token=GetRequestField('token', '');
	QueryDB("delete from users where token='$token'");
	return true;
}

function notify($from, $to, $subject, $message, $type, $name="", $phone="", $gid=0, $status="", $photo="", $ts=0) {
	if($to == '')
		return;

	if($from == '') {
		$from = '100';
	} else {
		//not required as it will anyway will be rejected by mesibo
		$to = str_replace($from, '', $to);
		$to = str_replace(',,', ',', $to);
	}

	$n = array();
	$n['subject'] = $subject;
	$n['msg'] = $message;
	$n['type'] = $type;
	$n['action'] = 0;
	$n['name'] = $name;
	$n['phone'] = $phone;
	
	$channel = 1;
	$groupid = 0;
	$expiry = 3600*24*7;
	$flag = 4; // transient
	$m = safe_json_encode($n);

	MesiboMessage($from, $to, $groupid, $channel, 1, $expiry, $flag, $m, $r);
}

function contact_update_notify($name, $phone, $ns) {
	$to = GetValueFromDB("select group_concat(phone) phones from users where ns='$ns' and phone!='$phone' order by ts desc limit 10", 'phones');
	notify($phone, $to, '', '', 1, $name, $phone, 0, '', '', 0);
	return true;
}

function get_uploaded_file() {
	include_once("upload.php");
	$folder = FILES_FOLDER;
	$content = '';

	//print "file:";
	//print_r($_FILES);
	foreach($_FILES as $key => $value) {
		$filename = upload($key, $folder);
		if(!$filename) {
			//$temp = safe_json_encode($_FILES);
			//print $temp;
			return false;
		}

		return $filename;
	}

	return false;
}

function upload_callbackapi(&$result) {
	$filename = get_uploaded_file();
	if(!$filename) {
		$result['error'] = 'MISSINGFILE';
		return false;
	}

	$result['file'] = $filename; // file field is need for file upload
	return true;
}



function DoExit($result, $data) {
	$data['result'] = "FAIL";

	if($result) {
		$data['result'] = "OK";
	}

	$jsondata = safe_json_encode($data);
	// This header will cause issue when error message is printed and error text length > content lenght
	//header("Content-length: " . strlen($jsondata));
	print $jsondata;
	flush();
	exit;
}

function OnEmptyExit($var, $code) {
	if($var == '') {
		$result = array();
		$result['code'] = $code;
		DoExit(false, $result);
	}
}

function webapi_getrecords($query, &$user, $callbackfn, $key='records', $keycount='reccount') {
	$result = NULL;
	if($query != '')
		$result = QueryDB($query);

	if(NULL == $result) {
		if($keycount != '')
			$user[$keycount] = 0; // zero records

		$user[$key] = array(); //empty array so that we don't need to check class of data when json decoded
		return false;
	}

	$num_rows = mysql_num_rows($result);
	if($keycount != '')
		$user[$keycount] = $num_rows;

	$i = 0;
	while ($row = mysql_fetch_assoc($result)) {
		if($callbackfn != '' && $callbackfn != null)
			$callbackfn($i, $row);

		$user[$key][$i] = $row;
		$i++;
	}

	mysql_free_result($result);
	return true;
}
