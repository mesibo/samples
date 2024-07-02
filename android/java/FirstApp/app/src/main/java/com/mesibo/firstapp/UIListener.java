package com.mesibo.firstapp;

import android.app.Activity;
import android.content.Context;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import com.mesibo.api.Mesibo;
import com.mesibo.api.MesiboProfile;
import com.mesibo.calls.api.MesiboCall;
import com.mesibo.messaging.MesiboRecycleViewHolder;
import com.mesibo.messaging.MesiboUI;
import com.mesibo.messaging.MesiboUIListener;

/* Messaging UI customization listener
  Refer to the https://mesibo.com/documentation/ui-modules/ for details
*/

public class UIListener implements MesiboUIListener {
    private static Context mLastUserListContext = null;
    private static Context mLastMessagingContext = null;

    // define some menu IDs for dynamic menus on userlist and message screen
    private static final int MENU_AUDIOCALL = Menu.FIRST;
    private static final int MENU_VIDEOCALL = Menu.FIRST + 1;
    private static final int MENU_E2EE = Menu.FIRST + 2;
    private static final int MENU_MESSAGE = Menu.FIRST + 3;
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
        if(item == MENU_E2EE) {
            MesiboUI.showEndToEndEncryptionInfoForSelf(context);
        }
    }

    void initUserListScreen(MesiboUI.MesiboUserListScreen screen) {
        screen.menu.clear();;

        MenuItem.OnMenuItemClickListener menuhandler = new MenuItem.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                userListScreenMenuHandler(screen.parent, item.getItemId());
                return true;
            }
        };

        /* Creating menu dynamically - alternatively you can also inflate menus from XML resource files */
        MenuItem menuItem = screen.menu.add(0, R.id.mesibo_contacts, Menu.NONE, "New Message");
        menuItem.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS);
        menuItem.setIcon(MesiboUI.MESIBO_DEFAULTICON_MESSAGE);
        //menuItem.setOnMenuItemClickListener(menuhandler);

        menuItem = screen.menu.add(0, MENU_E2EE, Menu.NONE, "End-toEnd Encryption");
        menuItem.setShowAsAction(MenuItem.SHOW_AS_ACTION_NEVER);
        menuItem.setOnMenuItemClickListener(menuhandler);
    }

    void messageListScreenMenuHandler(Context context, int item, MesiboProfile profile) {
        if(null == profile) {
            return;
        }

        if(MENU_AUDIOCALL == item) {
            if(!MesiboCall.getInstance().callUi(context, profile, false))
                MesiboCall.getInstance().callUiForExistingCall(context);
        }
        else if(MENU_VIDEOCALL == item) {
            if(!MesiboCall.getInstance().callUi(context, profile, true))
                MesiboCall.getInstance().callUiForExistingCall(context);
        }
        else if(MENU_E2EE == item) {
            MesiboUI.showEndToEndEncryptionInfo(context, profile.getAddress(), profile.groupid);
        }
    }

    void initMessageListScreen(MesiboUI.MesiboMessageScreen screen) {
        screen.menu.clear();;
        MenuItem.OnMenuItemClickListener menuhandler = new MenuItem.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                messageListScreenMenuHandler(screen.parent, item.getItemId(), screen.profile);
                return true;
            }
        };

        /* Creating menu dynamically - alternatively you can also inflate menus from XML resource files */
        // set group call icons
        if(null != screen.profile) {
            MenuItem menuItem = screen.menu.add(0, MENU_AUDIOCALL, Menu.NONE, "Audio Call");
            menuItem.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS);

            if (screen.profile.isGroup() && !screen.profile.isActive())
                menuItem.setVisible(false);
            menuItem.setIcon(screen.profile.isGroup() ? MesiboCall.MESIBO_DEFAULTICON_GROUPAUDIOCALL : MesiboCall.MESIBO_DEFAULTICON_AUDIOCALL);
            menuItem.setOnMenuItemClickListener(menuhandler);

            // MenuItemCompat.setShowAsAction(menuItem, MenuItemCompat.SHOW_AS_ACTION_NEVER);

            menuItem = screen.menu.add(0, MENU_VIDEOCALL, Menu.NONE, "Video Call");
            menuItem.setIcon(screen.profile.isGroup() ? MesiboCall.MESIBO_DEFAULTICON_GROUPVIDEOCALL : MesiboCall.MESIBO_DEFAULTICON_VIDEOCALL);
            if (screen.profile.isGroup() && !screen.profile.isActive())
                menuItem.setVisible(false);
            menuItem.setOnMenuItemClickListener(menuhandler);
            menuItem.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS);

            if(Mesibo.e2ee().isEnabled()) {
                menuItem = screen.menu.add(0, MENU_E2EE, Menu.NONE, "End-toEnd Encryption");
                menuItem.setShowAsAction(MenuItem.SHOW_AS_ACTION_NEVER);
                menuItem.setOnMenuItemClickListener(menuhandler);
            }

        }

        screen.titleArea.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                MesiboUI.showBasicProfileInfo(screen.parent, screen.profile);
            }
        });
    }
}
