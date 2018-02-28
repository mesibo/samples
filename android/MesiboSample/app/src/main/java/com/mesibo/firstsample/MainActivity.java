package com.mesibo.firstsample;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import com.mesibo.mediapicker.MediaPicker;
import com.mesibo.messaging.MesiboUI;

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

        final Button loginButton = findViewById(R.id.login);

        loginButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                startLogin();
                loginButton.setEnabled(false);
            }
        });

        final Button logoutButton = findViewById(R.id.logout);
        logoutButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                SampleAppWebApi.logout();
                showLayout();
            }
        });

        showLayout();
    }

    void showLayout() {
        View mv = findViewById(R.id.messageLayout);
        View lv = findViewById(R.id.loginLayout);

        boolean isLoggedIn = SampleAppWebApi.isLoggedin();

        lv.setVisibility(isLoggedIn?View.GONE:View.VISIBLE);
        mv.setVisibility(isLoggedIn?View.VISIBLE:View.GONE);

    }

    void startLogin() {
        EditText nv = findViewById(R.id.name);
        EditText pv = findViewById(R.id.phone);
        final Button loginButton = findViewById(R.id.login);

        String name = nv.getText().toString();
        String phone = pv.getText().toString();

        if(TextUtils.isEmpty(phone)) {
            loginButton.setEnabled(true);
            return;
        }

        SampleAppWebApi.login(name, phone, new SampleAppWebApi.DemoWebApiResponseHandler() {
            @Override
            public void onApiResponse(boolean result) {
                showLayout();
                loginButton.setEnabled(true);
            }
        });

    }




}
