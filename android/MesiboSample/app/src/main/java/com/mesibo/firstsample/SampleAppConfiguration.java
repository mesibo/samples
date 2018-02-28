package com.mesibo.firstsample;


import com.mesibo.api.Mesibo;

public class SampleAppConfiguration {

    // IMPORTANT: define a random namespace string in case you are using public api
    // so that it only shows contacts created in your test environment
    public static String namespace = "aXmsal0q7nNNy";

    public static String apiUrl = "https://mesibo.com/demoapi/api.php";
    public static String downloadUrl = "https://mesibo.com/demofiles/";

    public static int toolbarColor = 0xff00868b;
    public static String  emptyUserListMessage = "Ask your family and friends to download so that you can try out Mesibo functionalities";

    //IMPORTANT: ADD YOUR GOOGLE MAP KEY in AndroidManifest.xml if you are using location features of mesibo UI
}
