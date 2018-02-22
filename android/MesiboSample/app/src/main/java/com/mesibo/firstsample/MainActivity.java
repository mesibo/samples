package com.mesibo.firstsample;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.support.v4.view.MenuItemCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;

import com.mesibo.api.Mesibo;
import com.mesibo.calls.MesiboCall;
import com.mesibo.mediapicker.MediaPicker;
import com.mesibo.messaging.MesiboUI;

import java.util.ArrayList;

public class MainActivity extends AppCompatActivity {


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        final Button launchDemoButton = findViewById(R.id.launch_demo);
        launchDemoButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this, DemoActivity.class);
                startActivity(intent);
            }
        });

        final Button launchMesiboUiButton = findViewById(R.id.launch_ui);
        launchMesiboUiButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                MesiboUI.Config uiConfig = MesiboUI.getConfig();

                /* [OPTIONAL] configure user interface */
                uiConfig.mToolbarColor = SampleAppConfiguration.toolbarColor;
                uiConfig.emptyUserListMessage = SampleAppConfiguration.emptyUserListMessage;
                MediaPicker.setToolbarColor(uiConfig.mToolbarColor);

                MesiboUI.launch(MainActivity.this, 0, false, false);
            }
        });

    }




}
