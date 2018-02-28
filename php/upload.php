<?php
function upload($file_id, $folder) {
	if(!isset($_FILES[$file_id])) {
		return false;
	}

	if(!isset($_FILES[$file_id]['name'])) {
		return false;
	}

	if(!$_FILES[$file_id]['size']) { //Check if the file is made
	//	return false;
	}

	$ext_arr = explode(".",basename($_FILES[$file_id]['name']));
	$ext = strtolower($ext_arr[count($ext_arr)-1]); //Get the last extension

	$file_name = time().'-'.substr(md5(uniqid(rand(),1)),0,16).".$ext";

	$uploadfile = $folder . '/' . $file_name;

	$result = '';
	
	if (!move_uploaded_file($_FILES[$file_id]['tmp_name'], $uploadfile)) {
		echo "move failed: ". $_FILES[$file_id]['tmp_name']." to $uploadfile";
		return false;
	} 

	chmod($uploadfile, 0755);
	return $file_name;
}


