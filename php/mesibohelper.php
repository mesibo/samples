<?php
/********************************************************************************
 This File contains all functions necessary for sending a request using  Mesibo API's to perform
 the operations as mentioned in the documentation of the functions given below.
 
 IMPORTANT: All functions are dependent on the Mesibo API function (mesiboapi.php).
*********************************************************************************/
require_once('mesiboapi.php');

/********************************************************************************
Descripton: Creates a New User   

Parameters:	$email- A valid Email address which will be used for login. 
			$password- User's prefered password.  
			$name- User's name.

Return Values: True- When user account is Created.  
			   False- If user already exists. 
*********************************************************************************/
function MesiboAddUser($address, $appid, $session, $expiry, $flag) {
    
	$parameters=array();
	$parameters['op']='useradd';
	$parameters['addr']=$address;
	$parameters['appid']=$appid;
	$parameters['session']=$session;
	$parameters['expiry']=$expiry;
	$parameters['flag']=$flag;
	return MesiboAPI($parameters);
}

function MesiboDeleteUser($addr, $appid) {  
    
	$parameters=array();
	$parameters['op']='deluser';
	$parameters['addr']=$address;
	$parameters['appid']=$appid;
    
	return MesiboAPI($parameters);
}    

function MesiboDeleteToken($token) {  
    
	$parameters=array();
	$parameters['op']='deltoken';
	$parameters['token']=$token;
	return MesiboAPI($parameters);
}    

function MesiboSetGroup($groupid, $name, $flag, $members) {  
	$parameters=array();
	$parameters['gid']=$groupid;
	$parameters['op']=$groupid?'groupset':'groupadd';
	$parameters['name']=$name;
	$parameters['flag']=$flag;
	$parameters['m']=$members;
	return MesiboAPI($parameters);
}    

function MesiboDeleteGroup($groupid) {  
	$parameters=array();
	$parameters['op']='groupdel';
	$parameters['gid']=$groupid;
	return MesiboAPI($parameters);
}    

function MesiboEditMembers($groupid, $members, $delete) {  
	$parameters=array();
	$parameters['op']='groupeditmembers';
	$parameters['gid']=$groupid;
	$parameters['m']=$members;
	$parameters['delete']=$delete;
	return MesiboAPI($parameters);
}    

function MesiboGetMembers($groupid) {  
	$parameters=array();
	$parameters['op']='getmembers';
	$parameters['gid']=$groupid;
	return MesiboAPI($parameters);
}    

function MesiboMessage($from, $to, $groupid, $channel, $type, $expiry, $flag, $message, $forced=0) {  
	$parameters=array();
	$parameters['op']='message';
	$parameters['from']=$from;
	$parameters['to']=$to;
	$parameters['gid']=$groupid;
	$parameters['channel']=$channel;
	$parameters['type']=$type;
	$parameters['expiry']=$expiry;
	$parameters['flag']=$flag;
	$parameters['forced']=$forced;
	$parameters['msg']=$message;
	return MesiboAPI($parameters);
}    

