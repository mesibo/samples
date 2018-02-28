package com.mesibo.firstsample;

import android.os.Bundle;

import com.google.gson.Gson;
import com.mesibo.api.Mesibo;

/** Mesibo allows you to used your own servers for file transfer so that there are no arbitrary limitations
 *
 * All you have to do is to
 * 1) create a listner and register with mesibo which will assist mesibo in uploading and downloading file.
 * 2) Mesibo will invoke listener with file path every time it need to upload a file. This listener will upload
 * and let mesibo know about the URL it was uploaded to so that it can be downloaded by recipients as
 * and when requires
 * 3) In case of download, mesibo will invoke listener with URL of the file.
 *
 * We are using Mesibo HTTP API in this example. You can use any HTTP API but you will find many
 * advantage in using Mesibo HTTP API, especially transfer speed, simplicity and cross-platform (same API for
 * both Android and iOS)
 */

public class MesiboFileTransferHelper implements Mesibo.FileTransferHandler {

    private static Gson mGson = new Gson();
    private static Mesibo.HttpQueue mQueue = new Mesibo.HttpQueue(4, 0);


    public static class UploadResponse {
        public String op;
        public String file;
        public String result;

        UploadResponse() {
            result = null;
            op = null;
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
        b.putString("token", SampleAppWebApi.getToken());
        b.putLong("mid", mid);
        /* end of post data */

        Mesibo.Http http = new Mesibo.Http();

        http.url = SampleAppConfiguration.apiUrl;
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
                    UploadResponse uploadResponse = null;
                    try {
                        uploadResponse = mGson.fromJson(response, UploadResponse.class);
                    } catch (Exception e) {}

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

                int status = f.getStatus();
                if(100 == percent || status != Mesibo.FileInfo.STATUS_RETRYLATER) {
                    status = Mesibo.FileInfo.STATUS_INPROGRESS;
                    if(percent < 0)
                        status = Mesibo.FileInfo.STATUS_RETRYLATER;
                }

                Mesibo.updateFileTransferProgress(f, percent, status);

                return (100 == percent  || status != Mesibo.FileInfo.STATUS_RETRYLATER);
            }
        };

        if(null != mQueue)
            mQueue.queue(http);
        else if(http.execute()) {

        }

        return true;
    }

    /** This function is called when mesibo need to transfer (upload or download) a file.
     * All you have to do is to
     * 1) upload or download file as requested in file.mode
     * 2) In case of upload, if upload is successful, set the URL of the uploaded file which will
     * be sent to receiver
     */
    @Override
    public boolean Mesibo_onStartFileTransfer(Mesibo.FileInfo file) {
        if(Mesibo.FileInfo.MODE_DOWNLOAD == file.mode)
            return downloadFile(file.getParams(), file);

        return uploadFile(file.getParams(), file);
    }

    /** This function is called when mesibo need to abort a file transfer.
     */
    @Override
    public boolean Mesibo_onStopFileTransfer(Mesibo.FileInfo file) {
        Mesibo.Http http = (Mesibo.Http) file.getFileTransferContext();
        if(null != http)
            http.cancel();

        return true;
    }

}


