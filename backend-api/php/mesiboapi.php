<?php

require_once('mesiboconfig.php');
require_once('json.php');

$err = false;
if(!isset($apptoken))
	$err = true;

if ($err) {
	echo "ERROR: Please define your app token. If you don't have one then signup at https://mesibo.com to get one";
	exit();	
}

/********************************************************************************
Descripton: Performs the requested API operation 
                                                 
Parameters: $parameters - Parameters specific to the operation
		    $result- Contains the response information. 

Return Values: True- If operation is successful.        
               False- If operation failed.                                                             
*********************************************************************************/
function MesiboAPI($parameters) {
	global $apikey, $apilog, $file, $apptoken;
	global $mesibobaseurl;
	global $jsonapi;

	$parameters['token']=$apptoken;
	$jsonbody = null;
	$url = $mesibobaseurl;
	if($jsonapi) {
		$jsonbody = safe_json_encode($parameters);
	} else {
		$p = '';
		CreateURLEncoded($parameters, $p);
		$p = rtrim($p,'&');
		$url= $url.'?'.$p;
	}

	$response = GetAPIResponse($url, $jsonbody);
	return MesiboParseResponse($response);
}

/********************************************************************************
Descripton: Converts the response into function usable format for programming convenience. 
                                                                                                
Parameters: $response - The response to be parsed.                                 
		    $result- Contains the parsed response.    

Return Values: True- If the response was a success.    
               False- If the response was a failure.   
*********************************************************************************/
function MesiboParseResponse($response) {
	$result = json_decode($response, true);
	if(is_null($result)) 
		return false;
	return $result;
}

/********************************************************************************
Descripton: Reads the response from Mesibo URL for the request made.
                                                                                                
Parameters: $url - URL of the API being invoked.                                 

Return Values: Returns the response
*********************************************************************************/
function GetAPIResponse($url, $jsonbody) {
	$ch = curl_init();
	curl_setopt($ch,CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);  
	curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 2);
	curl_setopt($ch,CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch,CURLOPT_CONNECTTIMEOUT, 10);
	curl_setopt($ch,CURLOPT_TIMEOUT, 20);

	if($jsonbody) {
		curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $jsonbody);
	}

	$response = curl_exec($ch);
	curl_close ($ch);
	return $response;
}

/********************************************************************************
Descripton: Creates URL encoded parameters
                                                                                                
Parameters: $params_array - Parameters                                 
                                                                                         
Return Values: URL encoded parameters.    
*********************************************************************************/
function CreateURLEncoded($params_array, &$out) {

	foreach($params_array as $key=>$val) {   
		if(is_array($val)) {
			CreateURLEncoded($val, $out);
			continue;
		}
		if($val === true) {
			$val = 1;
		} else if($val === false) {
			$val = 0;
		}
		$out .= "$key=" . urlencode($val) . '&';    
	}
}

