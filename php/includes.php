<?php
	include_once ("httpheaders.php");
	include_once ('config.php');
	include_once ("errorhandler.php");
	include_once ("mysqldb.php");
	include_once ('mesibohelper.php');
	include_once ("json.php");

	ini_set('default_charset', 'UTF-8');
	if(function_exists('date_default_timezone_set')) {
		date_default_timezone_set('Etc/GMT');
	}
	
	//error_reporting(E_ALL);
	set_error_handler("handle_error");

function GetRequestField($field, $defaultval="") {
	$val = $defaultval;

	if(isset($_REQUEST[$field])) {
		$val = mysql_real_escape_string(trim($_REQUEST[$field]));
	}

	return $val;
}


