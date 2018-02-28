package com.mesibo.firstsample;

import android.databinding.DataBindingUtil;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import com.mesibo.api.Mesibo;
import com.mesibo.firstsample.databinding.ActivityDemoBinding;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

/**
 * This code sample demonstrates how to send and receive messages using mesibo API and making your
 * own user interface
 *
 * Note: charge the destination in code below as required
 */

public class DemoActivity extends AppCompatActivity implements View.OnClickListener, Mesibo.MessageListener {

    private ActivityDemoBinding mBinding = null;
    private DemoActivityMessageAdapter demoActivityMessageAdapter = null;
    private ArrayList<DemoActivityMessageHolder> messageArrayList = new ArrayList<DemoActivityMessageHolder>();
    private Mesibo.MessageListener messageListener = null;
    private Mesibo mesibo = null;


    private String destination = "919999970001";
    Mesibo.MessageParams messageParams = null;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);


        mBinding = DataBindingUtil.setContentView(this, R.layout.activity_demo);
        demoActivityMessageAdapter = new DemoActivityMessageAdapter(messageArrayList);

        mBinding.recyclerviewMessageList.setAdapter(demoActivityMessageAdapter);

        mBinding.sendMessage.setOnClickListener(this);

        messageParams = new Mesibo.MessageParams();
        messageParams.setPeer(destination);

        mesiboReadMessages();
    }


    private void scrollRecyclerView() {
        mBinding.recyclerviewMessageList.scrollToPosition(messageArrayList.size()-1);
    }

    private void mesiboReadMessages() {

        /* add Mesibo.MessageListener listener to get real-time & DB messages and status updates */
        Mesibo.addListener(this);

        Mesibo.setReadingSession(destination, Mesibo.READFLAG_READRECEIPT, null);
        /* read stored messages from database */
        Mesibo.read(100, this);
    }

    @Override
    public void onClick(View v) {

        DemoActivityMessageHolder msg = null;
        long msgid = 0;

        switch (v.getId()){
            case R.id.send_message:
                if (TextUtils.isEmpty(mBinding.edittextMessage.getText().toString().trim())) {
                    return;
                }

                // assign a random unique id to message
                msgid = Mesibo.random();
                msg = new DemoActivityMessageHolder(msgid, mBinding.edittextMessage.getText().toString(), true, getTime(), Mesibo.MSGSTATUS_OUTBOX);
                messageArrayList.add(msg);

                mesibo.sendMessage(messageParams, msgid, msg.getMessage());
                mBinding.edittextMessage.setText("");
                demoActivityMessageAdapter.notifyDataSetChanged();
                scrollRecyclerView();
                break;
        }
    }
    private String getTime() {
        SimpleDateFormat dateFormat = new SimpleDateFormat("hh:mm aa");
        return dateFormat.format(new Date()).toString();
    }

    @Override
    public boolean Mesibo_onMessage(Mesibo.MessageParams params, byte[] bytes) {
        messageArrayList.add(new DemoActivityMessageHolder(params.mid, new String(bytes),false, getTime(), params.getStatus()));
        demoActivityMessageAdapter.notifyDataSetChanged();
        scrollRecyclerView();
        return true;
    }

    @Override
    public void Mesibo_onMessageStatus(Mesibo.MessageParams params) {
        /* find message holder and set the status
           Update UI if requires (not in this sample)
         */
        DemoActivityMessageHolder.setStatus(params.mid, params.getStatus());
    }

    @Override
    public void Mesibo_onActivity(Mesibo.MessageParams params, int activity) {

    }

    @Override
    public void Mesibo_onLocation(Mesibo.MessageParams params, Mesibo.Location location) {

    }

    @Override
    public void Mesibo_onFile(Mesibo.MessageParams params, Mesibo.FileInfo fileInfo) {

    }
}