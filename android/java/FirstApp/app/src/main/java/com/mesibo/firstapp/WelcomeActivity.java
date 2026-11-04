package com.mesibo.firstapp;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.appcompat.app.AppCompatActivity;

import com.mesibo.messaging.MesiboDialogs;

/* What this demo does and what to do before using it; skipped once the tokens are set. */
public class WelcomeActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if(MainActivity.areTokensSet()) {
            onContinue(null);
            return;
        }

        setContentView(R.layout.activity_welcome);
    }

    public void onContinue(View view) {
        // nothing to do in the demo without the tokens
        if(!MainActivity.areTokensSet()) {
            MesiboDialogs.alert(this, getString(R.string.welcome_tokens_missing_title), getString(R.string.welcome_tokens_missing));
            return;
        }

        startActivity(new Intent(this, MainActivity.class));
        finish();
    }
}
