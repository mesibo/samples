package com.mesibo.firstapp;

import android.app.Activity;
import android.content.Context;
import android.view.MenuItem;

import com.mesibo.api.MesiboProfile;
import com.mesibo.calls.api.MesiboCall;
import com.mesibo.messaging.MesiboRecycleViewHolder;
import com.mesibo.messaging.MesiboUI;
import com.mesibo.messaging.MesiboUIListener;

/* Messaging UI customization listener (optional): adds the call and encryption buttons to the
   screens. Refer to https://docs.mesibo.com/ui-modules/customizing/ for details
*/

public class UIListener implements MesiboUIListener {

    @Override
    public boolean MesiboUI_onInitScreen(MesiboUI.MesiboScreen screen) {
        // other screens (e.g. the profile popup) are SCREEN_GENERIC
        if(MesiboUI.SCREEN_USERLIST == screen.type) {
            initUserListScreen((MesiboUI.MesiboUserListScreen) screen);
        } else if(MesiboUI.SCREEN_MESSAGES == screen.type) {
            initMessageListScreen((MesiboUI.MesiboMessageScreen) screen);
        }
        return false;
    }

    @Override
    public MesiboRecycleViewHolder MesiboUI_onGetCustomRow(MesiboUI.MesiboScreen screen, MesiboUI.MesiboRow row) {
        return null; // the default rendering
    }

    @Override
    public boolean MesiboUI_onUpdateRow(MesiboUI.MesiboScreen screen, MesiboUI.MesiboRow row, boolean last) {
        return false;
    }

    @Override
    public boolean MesiboUI_onShowLocation(Context context, MesiboProfile profile) {
        return false; // the default location picker
    }

    @Override
    public boolean MesiboUI_onClickedRow(MesiboUI.MesiboScreen screen, MesiboUI.MesiboRow row) {
        return false; // the default action
    }

    void initUserListScreen(MesiboUI.MesiboUserListScreen screen) {
        ((Activity)screen.parent).getMenuInflater().inflate(R.menu.menu_userlist, screen.menu);

        screen.menu.findItem(R.id.action_menu_e2ee).setOnMenuItemClickListener(item -> {
            MesiboUI.showEndToEndEncryptionInfoForSelf(screen.parent);
            return true;
        });
    }

    void messageListScreenMenuHandler(Context context, int item, MesiboProfile profile) {
        if(null == profile) {
            return;
        }

        // during a call, callUi brings back the call in progress instead
        if(R.id.action_call == item) {
            MesiboCall.getInstance().callUi(context, profile, false);
        }
        else if(R.id.action_videocall == item) {
            MesiboCall.getInstance().callUi(context, profile, true);
        }
        else if(R.id.action_e2e == item) {
            MesiboUI.showEndToEndEncryptionInfo(context, profile.getAddress(), profile.groupid);
        }
    }

    void initMessageListScreen(MesiboUI.MesiboMessageScreen screen) {
        ((Activity)screen.parent).getMenuInflater().inflate(R.menu.menu_messaging, screen.menu);

        if(null != screen.profile) {
            boolean group = screen.profile.isGroup();
            // no calls in a group you are not a member of anymore
            boolean canCall = !group || screen.profile.isActive();

            MenuItem menuItem = screen.menu.findItem(R.id.action_call);
            menuItem.setIcon(group ? MesiboCall.MESIBO_DEFAULTICON_GROUPAUDIOCALL : MesiboCall.MESIBO_DEFAULTICON_AUDIOCALL);
            menuItem.setVisible(canCall);

            menuItem = screen.menu.findItem(R.id.action_videocall);
            menuItem.setIcon(group ? MesiboCall.MESIBO_DEFAULTICON_GROUPVIDEOCALL : MesiboCall.MESIBO_DEFAULTICON_VIDEOCALL);
            menuItem.setVisible(canCall);
        }

        MenuItem.OnMenuItemClickListener menuhandler = item -> {
            messageListScreenMenuHandler(screen.parent, item.getItemId(), screen.profile);
            return true;
        };

        screen.menu.findItem(R.id.action_call).setOnMenuItemClickListener(menuhandler);
        screen.menu.findItem(R.id.action_videocall).setOnMenuItemClickListener(menuhandler);
        screen.menu.findItem(R.id.action_e2e).setOnMenuItemClickListener(menuhandler);

        // tap the name in the toolbar: the profile of the user or group
        screen.titleArea.setOnClickListener(v -> MesiboUI.showProfile(screen.parent, screen.profile));
    }
}
