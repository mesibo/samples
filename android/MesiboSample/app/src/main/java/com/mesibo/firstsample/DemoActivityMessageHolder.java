package com.mesibo.firstsample;

import java.util.HashMap;


public class DemoActivityMessageHolder {
    private String mMessage;
    private boolean mSentMessage;
    private String mTimestamp;
    private int mStatus;
    private static HashMap<Long, DemoActivityMessageHolder> mMessageMap = new HashMap<Long, DemoActivityMessageHolder>();


    public DemoActivityMessageHolder(long id, String message , boolean isSentMessage , String time, int status){
        mSentMessage = isSentMessage;
        mMessage = message;
        mTimestamp = time;
        mStatus = status;
        mMessageMap.put(Long.valueOf(id), this);
    }

    public String getMessage() {
        return mMessage;
    }

    public boolean isSentMessage(){
        return mSentMessage;
    }

    public String getTime() {
        return mTimestamp;
    }

    public int getStatus() {
        return mStatus;
    }

    public static void setStatus(long id, int status) {
        DemoActivityMessageHolder msg = mMessageMap.get(Long.valueOf(id));
        if(null == msg) return;
        msg.mStatus = status;
    }


}
