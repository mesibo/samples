<?php

/* set your database credentials here */
$db_host = "";
$db_name = "";         
$db_user = "";           
$db_pass = "";     

/* Signup to https://mesibo.com to get your app token */
$mesibo_app_token = '';

if($db_host == '' || $db_name == '' || $db_user == '' || $db_pass == '' || $mesibo_app_token == '') {
	echo "ERROR: DB or mesibo app token is not set";
	exit;
}
	
define("FILES_FOLDER", "../demofiles");


