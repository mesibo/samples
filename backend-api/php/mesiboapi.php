<?php
/**
 * Mesibo Backend API - PHP Sample Implementation
 * 
 * This file contains sample functions for invoking mesibo backend API.
 * For complete documentation, visit: https://docs.mesibo.com/api/backend-api/
 * 
 * Setup Instructions:
 * 1. Create a file named 'mesiboconfig.php' in the same directory
 * 2. Get your App Token from Mesibo Console: https://console.mesibo.com
 * 3. Add the following line to mesiboconfig.php:
 *    <?php
 *    $apptoken = "your_app_token_here";
 *    ?>
 * 
 * @link https://mesibo.com
 * @link https://docs.mesibo.com/api/backend-api/
 */

require_once('mesiboconfig.php');

// Validate that app token is configured
$err = false;
if(!isset($apptoken))
	$err = true;

if ($err) {
	echo "ERROR: Please define your app token in mesiboconfig.php\n";
	echo "Get your App Token from Mesibo Console: https://console.mesibo.com\n";
	echo "If you don't have an account, signup at: https://mesibo.com\n";
	exit();	
}

/**
 * Mesibo Backend API - Main function
 * 
 * Performs the requested API operation and returns response.
 * All API operations go through this function.
 * 
 * @param array $parameters API parameters including 'op' (operation) and operation-specific data
 * @return array|false Decoded JSON response or false on error
 * 
 * @example
 * $params = array('op' => 'users', 'count' => 10);
 * $result = MesiboAPI($params);
 */
function MesiboAPI($parameters) {
	global $mesibobaseurl, $apptoken;

	// Add app token to request
	$parameters['token'] = $apptoken;

	// Get API URL (can be overridden via parameters)
	$url = isset($parameters['apiurl']) ? $parameters['apiurl'] : $mesibobaseurl;

	// Encode parameters as JSON
	$json_data = safe_json_encode($parameters);

	// Initialize cURL session
	$ch = curl_init($url);
	curl_setopt_array($ch, array(
		CURLOPT_POST => true,
		CURLOPT_POSTFIELDS => $json_data,
		CURLOPT_RETURNTRANSFER => true,
		CURLOPT_HTTPHEADER => array(
			'Content-Type: application/json',
			'Content-Length: ' . strlen($json_data)
		),
		CURLOPT_TIMEOUT => 30,              // Maximum time for request
		CURLOPT_CONNECTTIMEOUT => 10,       // Maximum time for connection
		CURLOPT_SSL_VERIFYPEER => true,     // Verify SSL certificate
		CURLOPT_SSL_VERIFYHOST => 2         // Verify hostname in certificate
	));

	// Execute request
	$response = curl_exec($ch);

	// Handle cURL errors
	if (curl_errno($ch)) {
		$response = 'FAILED: ' . curl_error($ch);
	}

	curl_close($ch);

	// Parse JSON response
	$result = json_decode($response, true);
	if(is_null($result)) 
		return false;
	
	return $result;
}

/**
 * Generate and send OTP (One-Time Password)
 * 
 * Used for phone/email verification in authentication flows.
 * 
 * @param string $address Phone number (with country code) or email address
 * @param int $tries Maximum number of verification attempts allowed
 * @param int $expiry OTP validity period in seconds
 * @param bool $reuse Whether the same OTP can be reused for verification
 * @return array|false API response containing OTP details or false on error
 * 
 * @example
 * $result = MesiboOTP('+1234567890', 3, 300, false);
 */
function MesiboOTP($address, $tries, $expiry, $reuse) {
	$parameters['op'] = 'otp';
	$parameters['otp'] = array(
		'address' => $address,      // Phone number or email
		'tries' => $tries,          // Max verification attempts
		'expiry' => $expiry,        // Validity in seconds
		'reuse' => $reuse           // Allow OTP reuse
	);

	return MesiboAPI($parameters);
}

/**
 * Add a new user to your mesibo application
 * 
 * Creates a user with access token for your app.
 * 
 * @param string $name User's display name
 * @param string $address Unique user identifier (phone/email/username)
 * @param string $appid Your application's bundle ID (e.g., com.example.app)
 * @param int $expiry Token validity in minutes (0 for never expires)
 * @param string $otp OTP for verification (if using OTP-based registration)
 * @return array|false API response containing user token or false on error
 * 
 * @example
 * $result = MesiboAddUser('John Doe', 'john@example.com', 'com.example.app', 525600, '123456');
 */
function MesiboAddUser($name, $address, $appid, $expiry, $otp) {

	$parameters = array();
	$parameters['op'] = 'useradd';

	$parameters['user'] = array(
		'name' => $name,           // User's display name
		'address' => $address,     // Unique user identifier
		'otp' => $otp,            // OTP for verification

		'token' => array(
			'appid' => $appid,     // Your app's bundle ID
			'expiry' => $expiry,   // Token expiry in minutes
			'v2' => true          // Use v2 token format
		)
	);
	
	return MesiboAPI($parameters);
}

?>
