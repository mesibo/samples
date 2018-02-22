package com.mesibo.firstsample;


import com.mesibo.api.Mesibo;

public class SampleAppConfiguration {

    /* In production app - you should get this token dynamically using mesibo server side api */
    public static String mesiboAuthToken = "384146797d7399a8610a55b7085c5f424dc86be111ec";

    public static String uploadUrl = "https://example.com/upload.php";
    public static String downloadUrl = "https://example.com/files/";

    public static int toolbarColor = 0xff00868b;
    public static String  emptyUserListMessage = "Ask your family and friends to download so that you can try out Mesibo functionalities";

}
