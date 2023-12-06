<?php
/********************************************************************************
 This File contains all functions necessary for sending a request using  Mesibo API's to perform
 the operations as mentioned in the documentation of the functions given below.
 
 IMPORTANT: All functions are dependent on the Mesibo API function (mesiboapi.php).
*********************************************************************************/
require_once('mesiboapi.php');

function MesiboAddUser($address, $appid, $session, $expiry, $flag) {
	$parameters=array();
	$parameters['op']='useradd';
	
	$user=array();
	$user['address']=$address;
	$user['flags']=$flag;
	
	$token=array();
	$token['appid']=$appid;
	$token['session']=$session;
	$token['expiry']=$expiry;

	$user['token']=$token;

	$parameters['user']=$user;

	return MesiboAPI($parameters);
}

function MesiboDeleteUser($address) {  
    
	$parameters=array();
	$parameters['op']='userdel';
	$user=array();
	$user['address']=$address;
	$parameters['user']=$user;
    
	return MesiboAPI($parameters);
}    

function MesiboDeleteToken($address) {  
	$parameters=array();
	$parameters['op']='userset';
	
	$user=array();
	$user['address']=$address;
	
	$token=array();
	$token['remove']=true;

	$user['token']=$token;

	$parameters['user']=$user;

	return MesiboAPI($parameters);
}    

function MesiboCreateGroup($name, $flags, $start, $duration, $members, $calls) {  
	global $jsonapi;
	$parameters=array();
	$parameters['op']= 'groupadd';
	
	$group=array();
	$group['name'] = $name;
	$group['flags'] = $flags;

	if($start) $group['start'] = $start;

	$group['duration'] = $duration;
	

	if($members) {
		$m=array();

		$m['m'] = $members;
		
		$permissions=array();
		$permissions['send'] = true;
		$permissions['recv'] = true;
		$permissions['pub'] = true;
		$permissions['sub'] = true;
		$permissions['list'] = true;

		if($jsonapi) $m['permissions'] = $permissions;

		$group['members'] = $m;
	}

	if($calls && $jsonapi) $group['call'] = $calls;
	
	$parameters['group'] = $group;

	return MesiboAPI($parameters);
}    

function MesiboSetGroup($groupid, $name, $flags, $members) {  
	$parameters=array();
	$parameters['op']= 'groupset';
	
	$group=array();
	$group['gid'] = $groupid;
	$group['name'] = $name;
	$group['flags'] = $flags;
	if($members) {
		$m=array();

		$m['m'] = $members;
		
		$permissions=array();
		$permissions['send'] = true;
		$permissions['recv'] = true;
		$permissions['pub'] = true;
		$permissions['sub'] = true;
		$permissions['list'] = true;

		if($jsonapi) $m['permissions'] = $permissions;

		$group['members'] = $m;
	}
	
	$parameters['group'] = $group;

	return MesiboAPI($parameters);
}    

function MesiboDeleteGroup($groupid) {  
	$parameters=array();
	$parameters['op']='groupdel';
	
	$group=array();
	$group['gid'] = $groupid;
	$parameters['group'] = $group;

	return MesiboAPI($parameters);
}    

function MesiboEditMembers($groupid, $members, $delete) {  
	
	$parameters=array();
	$parameters['op']='groupeditmembers';

	$group=array();
	$group['gid']=$groupid;
	$group['delete']=$delete;
	$parameters['group'] = $group;
	
	if($members) {
		$m=array();

		$m['m'] = $members;
		
		$permissions=array();
		$permissions['send'] = true;
		$permissions['recv'] = true;
		$permissions['pub'] = true;
		$permissions['sub'] = true;
		$permissions['list'] = true;

		if($jsonapi) $m['permissions'] = $permissions;

		$group['members'] = $m;
	}

	return MesiboAPI($parameters);
}    

function MesiboGetMembers($groupid) {  
	$parameters=array();
	$parameters['op']='groupgetmembers';

	$group=array();
	$group['gid']=$groupid;
	$parameters['group'] = $group;

	return MesiboAPI($parameters);
}    

function MesiboMessage($from, $to, $groupid, $type, $expiry, $flag, $message) {  
	$parameters=array();
	$parameters['op']='message';
	
	$m=array();
	$m['from'] = $from;
	$m['to'] = $to;
	$m['gid'] = $groupid;
	$m['type'] = $type;
	$m['expiry'] = $expiry;
	$m['flags'] = $flags;
	$m['message'] = $message;
	
	$parameters['message']=$m;

	return MesiboAPI($parameters);
}    

