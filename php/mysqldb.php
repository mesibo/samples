<?php

$persistenceConnection = 0;
$mysqlconnected = 0;

function ConnectToDB()
{
	global $db_host, $db_user, $db_pass, $db_name, $persistenceConnection;
	
	if($persistenceConnection > 0 ) {
		$conn = mysql_pconnect($db_host, $db_user, $db_pass ) or die ('DB ERROR 1');
	} else {
		$conn = mysql_connect($db_host, $db_user, $db_pass ) or die ('DB ERROR 1');
	}

	mysql_select_db($db_name) or die ('Invalid query: ' . mysql_error());
	mysql_set_charset('utf8');
	mysql_query("set character_set_results = 'utf8', character_set_client = 'utf8', character_set_connection = 'utf8', character_set_database = 'utf8', character_set_server = 'utf8'");
	
	$mysqlconnected = 1;
	return $conn;
}

function QueryDB($query, $printquery=0) {

	global $mysqlconnected;
	
	if($mysqlconnected != 1)
		ConnectToDB();
		
	if($printquery == 1)
		print "$query<br/>\n";
		
	//$result = mysql_query($query) or die('Invalid query: ' . mysql_error());
	$res = mysql_query($query);
	if($res == false) {
		error_log("Query failed: $query\n".mysql_error()."\n");
	}
	return $res;
}

function SetQueryDB($query, $printquery=0) {

	$result = QueryDB($query, $printquery);
	
	if(false == $result)
		return false;
	
	//mysql_affected_rows returns negative if op failed, 0 if no row affected
	//In the case of "INSERT ... ON DUPLICATE KEY UPDATE" queries, the return value will be 1 if an insert was performed, or 2 for an update of an existing row.
	return mysql_affected_rows();
}

function InsertQueryDB($query, $printquery=0) {

	$result = QueryDB($query, $printquery);
	
	if(false == $result)
		return false;
	
	return mysql_insert_id();
}

function GetValueFromDB($query, $field, $printquery=0) {

	$result = QueryDB($query, $printquery);

	if(false == $result)
		return false;

	$num_rows = mysql_num_rows($result);
	if($num_rows > 0) {
        	$row = mysql_fetch_assoc($result);
	        $value = $row[$field];
        	mysql_free_result($result);
		return $value;
	}
	return false;
}

function GetRowCount($query, $printquery=0) {
	$result = QueryDB($query, $printquery);
	if(false == $result)
		return false;
	return mysql_num_rows($result);
}

function GetRowFromDB($query, $expectedrows=0, $printquery=0) {

	$result = QueryDB($query, $printquery);
	if(false == $result)
		return false;

	$num_rows = mysql_num_rows($result);
	if(($expectedrows == 0 && $num_rows > 0) || ($expectedrows > 0 && $num_rows == $expectedrows) ) {
        	$row = mysql_fetch_assoc($result);
        	mysql_free_result($result);
		return $row;
	}
	return false;
}

function CloseDB()
{
	global $persistenceConnection;
	
	if($persistenceConnection == 0 ) {
		mysql_close ();
		$mysqlconnected = 0;
	}
	
}

function create_setquery_frompostdata($fields) {
	$q = '';

	foreach($fields as $key) {
		$val = GetRequestField($key);
		if($val != '') {
			if($q != '')
				$q .= ',';
			$q .= "$key='$val'";
		}
	}
	return $q;
}
