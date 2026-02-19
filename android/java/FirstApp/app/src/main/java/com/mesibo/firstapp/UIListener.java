package com.mesibo.firstapp;

import android.app.Activity;
import android.content.Context;
import android.view.MenuItem;
import android.view.View;

import com.mesibo.api.MesiboProfile;
import com.mesibo.calls.api.MesiboCall;
import com.mesibo.messaging.MesiboRecycleViewHolder;
import com.mesibo.messaging.MesiboUI;
import com.mesibo.messaging.MesiboUIListener;

/* Messaging UI customization listener
  Refer to the https://docs.mesibo.com/ui-modules/ for details
*/

public class UIListener implements MesiboUIListener {
    private static Context mLastUserListContext = null;
    private static Context mLastMessagingContext = null;
    @Override
    public boolean MesiboUI_onInitScreen(MesiboUI.MesiboScreen screen) {
        if(screen.userList) {
            mLastUserListContext = screen.parent;
            initUserListScreen((MesiboUI.MesiboUserListScreen) screen);
        } else {
            mLastMessagingContext = screen.parent;
            initMessageListScreen((MesiboUI.MesiboMessageScreen) screen);
        }
        return false;
    }

    public static Context getLastUserListContext() {
        return mLastUserListContext;
    }

    public static Context getLastMessagingContext() {
        return mLastMessagingContext;
    }

    @Override
    public MesiboRecycleViewHolder MesiboUI_onGetCustomRow(MesiboUI.MesiboScreen screen, MesiboUI.MesiboRow row) {
        return null;
    }

    @Override
    public boolean MesiboUI_onUpdateRow(MesiboUI.MesiboScreen screen, MesiboUI.MesiboRow row, boolean last) {
        return false;
    }

    @Override
    public boolean MesiboUI_onShowLocation(Context context, MesiboProfile profile) {
        return false;
    }


    @Override
    public boolean MesiboUI_onClickedRow(MesiboUI.MesiboScreen screen, MesiboUI.MesiboRow row) {
        return false;
    }

    void userListScreenMenuHandler(Context context, int item) {
        if (item == R.id.action_settings) {

        } else if(item == R.id.action_menu_e2ee) {
            MesiboUI.showEndToEndEncryptionInfoForSelf(context);
        } else if(item == R.id.mesibo_share) {

        }
    }

    void initUserListScreen(MesiboUI.MesiboUserListScreen screen) {
        ((Activity)screen.parent).getMenuInflater().inflate(R.menu.menu_userlist, screen.menu);

        MenuItem.OnMenuItemClickListener menuhandler = new MenuItem.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                userListScreenMenuHandler(screen.parent, item.getItemId());
                return true;
            }
        };

        screen.menu.findItem(R.id.action_menu_e2ee).setOnMenuItemClickListener(menuhandler);

    }

    void messageListScreenMenuHandler(Context context, int item, MesiboProfile profile) {
        if(null == profile) {
            return;
        }

        if(R.id.action_call == item) {
            if(!MesiboCall.getInstance().callUi(context, profile, false))
                MesiboCall.getInstance().callUiForExistingCall(context);
        }
        else if(R.id.action_videocall == item) {
            if(!MesiboCall.getInstance().callUi(context, profile, true))
                MesiboCall.getInstance().callUiForExistingCall(context);
        }
        else if(R.id.action_e2e == item) {
            MesiboUI.showEndToEndEncryptionInfo(context, profile.getAddress(), profile.groupid);
        }
    }

    void initMessageListScreen(MesiboUI.MesiboMessageScreen screen) {
        ((Activity)screen.parent).getMenuInflater().inflate(R.menu.menu_messaging, screen.menu);

        /* different item for group calls */
        if(null != screen.profile && screen.profile.isGroup()) {
            MenuItem menuItem = screen.menu.findItem(R.id.action_call);
            if(!screen.profile.isActive()) menuItem.setVisible(false);
            menuItem.setIcon(R.drawable.ic_mesibo_groupcall_audio);
            // MenuItemCompat.setShowAsAction(menuItem, MenuItemCompat.SHOW_AS_ACTION_NEVER);

            menuItem = screen.menu.findItem(R.id.action_videocall);
            menuItem.setIcon(R.drawable.ic_mesibo_groupcall_video);
            if(!screen.profile.isActive()) menuItem.setVisible(false);
            //MenuItemCompat.setShowAsAction(menuItem, MenuItemCompat.SHOW_AS_ACTION_NEVER);
        }

        MenuItem.OnMenuItemClickListener menuhandler = new MenuItem.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                messageListScreenMenuHandler(screen.parent, item.getItemId(), screen.profile);
                return true;
            }
        };

        screen.menu.findItem(R.id.action_call).setOnMenuItemClickListener(menuhandler);
        screen.menu.findItem(R.id.action_videocall).setOnMenuItemClickListener(menuhandler);
        screen.menu.findItem(R.id.action_e2e).setOnMenuItemClickListener(menuhandler);

        screen.titleArea.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                MesiboUI.showBasicProfileInfo(screen.parent, screen.profile);
            }
        });
    }
}
