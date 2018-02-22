package com.mesibo.firstsample;

import android.os.Bundle;

import com.google.gson.Gson;
import com.mesibo.api.Mesibo;

public class MesiboFileTransferHelper implements Mesibo.FileTransferHandler {

     private static Gson mGson = new Gson();
    private static Mesibo.HttpQueue mQueue = new Mesibo.HttpQueue(4, 0);


    public static class UploadResponse {
        public String op;
        public String file;
        public String result;
        public String xxx;

        UploadResponse() {
            result = null;
            op = null;
            xxx = null;
            file = null;
        }
    }

    MesiboFileTransferHelper() {
        	Mesibo.addListener(this);
    }


    public boolean uploadFile(Mesibo.MessageParams params, final Mesibo.FileInfo file) {

        /* [OPTIONAL] check the required network connectivity for automatic or manual file download */
        if(Mesibo.getNetworkConnectivity() != Mesibo.CONNECTIVITY_WIFI && !file.userInteraction)
            return false;

        final long mid = file.mid;

        /* [OPTIONAL] any POST data to send with the file */
        Bundle b = new Bundle();
        b.putString("op", "upload");
        b.putString("token", "some token to authenticate upload");
        b.putLong("mid", mid);
        /* end of post data */

        Mesibo.Http http = new Mesibo.Http();

        http.url = SampleAppConfiguration.uploadUrl;
        http.postBundle = b;
        http.uploadFile = file.getPath();
        http.uploadFileField = "photo";
        http.other = file;
        file.setFileTransferContext(http);

        http.listener = new Mesibo.HttpListener() {
            @Override
            public boolean Mesibo_onHttpProgress(Mesibo.Http config, int state, int percent) {
                Mesibo.FileInfo f = (Mesibo.FileInfo)config.other;

                if(100 == percent && Mesibo.Http.STATE_DOWNLOAD == state) {

                    //parse response
                    String response = config.getDataString();
                    UploadResponse uploadResponse = mGson.fromJson(response, UploadResponse.class);

                    if(null == uploadResponse || null == uploadResponse.file) {
                        Mesibo.updateFileTransferProgress(f, -1, Mesibo.FileInfo.STATUS_FAILED);
                        return false;
                    }

                    f.setUrl(uploadResponse.file);
                }

                int status = f.getStatus();
                if(100 == percent || status != Mesibo.FileInfo.STATUS_RETRYLATER) {
                    status = Mesibo.FileInfo.STATUS_INPROGRESS;
                    if(percent < 0)
                        status = Mesibo.FileInfo.STATUS_RETRYLATER;
                }

                if(percent < 100 || (100 == percent && Mesibo.Http.STATE_DOWNLOAD == state))
                    Mesibo.updateFileTransferProgress(f, percent, status);

                return ((100 == percent && Mesibo.Http.STATE_DOWNLOAD == state) || status != Mesibo.FileInfo.STATUS_RETRYLATER);
            }
        };

        if(null != mQueue)
            mQueue.queue(http);
        else if(http.execute()) {

        }

        return true;
    }

    public boolean downloadFile(final Mesibo.MessageParams params, final Mesibo.FileInfo file) {
        final long mid = file.mid;

        String url = file.getUrl();
        if(!url.toLowerCase().startsWith("http://") && !url.toLowerCase().startsWith("https://")) {
            url = SampleAppConfiguration.downloadUrl + url;
        }

        Mesibo.Http http = new Mesibo.Http();

        http.url = url;
        http.downloadFile = file.getPath();
        http.resume = true;
        http.maxRetries = 10;
        http.other = file;
        file.setFileTransferContext(http);

        http.listener = new Mesibo.HttpListener() {
            @Override
            public boolean Mesibo_onHttpProgress(Mesibo.Http http, int state, int percent) {
                Mesibo.FileInfo f = (Mesibo.FileInfo)http.other;

                int status = Mesibo.FileInfo.STATUS_INPROGRESS;

                //TBD, we can simplify this now, don't need separate handling
                if(Mesibo.FileInfo.SOURCE_PROFILE == f.source) {
                    if(100 == percent) {
                        //Mesibo.UserProfile profile = Mesibo.getUserProfile(params);
                        Mesibo.updateFileTransferProgress(f, percent, Mesibo.FileInfo.STATUS_INPROGRESS);
                    }
                } else {

                    status = f.getStatus();
                    if(100 == percent || status != Mesibo.FileInfo.STATUS_RETRYLATER) {
                        status = Mesibo.FileInfo.STATUS_INPROGRESS;
                        if(percent < 0)
                            status = Mesibo.FileInfo.STATUS_RETRYLATER;
                    }

                    Mesibo.updateFileTransferProgress(f, percent, status);

                }

                return (100 == percent  || status != Mesibo.FileInfo.STATUS_RETRYLATER);
            }
        };

        if(null != mQueue)
            mQueue.queue(http);
        else if(http.execute()) {

        }

        return true;
    }

    /* This is called when mesibo need to upload file. All you have to do is to
     1) upload file
     2) If upload is successful, set the URL of the uploaded file which will be sent to receiver
     */
    @Override
    public boolean Mesibo_onStartFileTransfer(Mesibo.FileInfo file) {
        if(Mesibo.FileInfo.MODE_DOWNLOAD == file.mode)
            return downloadFile(file.getParams(), file);

        return uploadFile(file.getParams(), file);
    }

    @Override
    public boolean Mesibo_onStopFileTransfer(Mesibo.FileInfo file) {
        Mesibo.Http http = (Mesibo.Http) file.getFileTransferContext();
        if(null != http)
            http.cancel();

        return true;
    }

}


