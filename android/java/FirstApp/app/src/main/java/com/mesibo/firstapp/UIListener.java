package com.mesibo.firstapp;

import android.app.Activity;
import android.content.Context;
import android.view.MenuItem;

import com.mesibo.api.Mesibo;
import com.mesibo.api.MesiboProfile;
import com.mesibo.calls.api.MesiboCall;
import com.mesibo.messaging.MesiboRecycleViewHolder;
import com.mesibo.messaging.MesiboUI;
import com.mesibo.messaging.MesiboUiAction;
import com.mesibo.messaging.MesiboUIListener;
import com.mesibo.messaging.MesiboUiConfig;

/* Messaging UI customization listener (optional): adds the call and encryption buttons to the
   screens. Refer to https://docs.mesibo.com/ui-modules/customizing/ for details
*/

public class UIListener implements MesiboUIListener {

    /**
     * OPTIONAL - the texts, colors, etc. of the messaging UI (the same names on Android and iOS), set
     * on each new configuration (a theme applied). Refer to the documentation
     * https://docs.mesibo.com/ui-modules/setting-defaults/
     */
    @Override
    public void MesiboUI_onConfig(MesiboUiConfig config, boolean dark) {
        config.messages.showMissedCalls = true;
        config.userList.showBackButton = true;
    }

    @Override
    public boolean MesiboUI_onInitScreen(MesiboUI.MesiboScreen screen) {
        // SCREEN_PROFILE and SCREEN_PROFILE_POPUP get the call buttons; other screens are SCREEN_GENERIC
        if(MesiboUI.SCREEN_USERLIST == screen.type) {
            initUserListScreen((MesiboUI.MesiboUserListScreen) screen);
        } else if(MesiboUI.SCREEN_MESSAGES == screen.type) {
            initMessageListScreen((MesiboUI.MesiboMessageScreen) screen);
        } else if (MesiboUI.SCREEN_PROFILE == screen.type) {
            // the buttons under the name
            addCallItems(((MesiboUI.MesiboProfileScreen) screen).actions, screen);
        } else if (MesiboUI.SCREEN_PROFILE_POPUP == screen.type) {
            // the popup's buttons, between Message and Info
            addCallItems(screen.menu, screen);
        }
        return true;
    }

    // ids of the call items of the profile screen and popup
    private static final int MENU_PROFILE_VOICE = 9101;
    private static final int MENU_PROFILE_VIDEO = 9102;

    /**
     * Voice and video call buttons, for the profile screen and the profile popup (none for a group
     * the user left). During a call, they bring it back.
     */
    private void addCallItems(android.view.Menu menu, MesiboUI.MesiboScreen screen) {
        com.mesibo.api.MesiboProfile profile = screen.profile;
        if (null == menu || null == profile || (profile.isGroup() && !profile.isActive()))
            return;

        for (int i = 0; i < 2; i++) {
            final boolean video = 1 == i;
            menu.add(android.view.Menu.NONE, video ? MENU_PROFILE_VIDEO : MENU_PROFILE_VOICE, 50 + i, video ? "Video" : "Voice")
                    .setIcon(video ? R.drawable.ic_mesibo_videocam : R.drawable.ic_mesibo_call)
                    .setOnMenuItemClickListener(item -> {
                        // during a call: back to it
                        if (com.mesibo.calls.api.MesiboCall.getInstance().isAnyCallInProgress())
                            com.mesibo.calls.api.MesiboCall.getInstance().showCallInProgress(screen.parent);
                        else
                            com.mesibo.calls.api.MesiboCall.getInstance().callUi(screen.parent, profile, video);
                        return true;
                    });
        }
    }

    @Override
    public MesiboRecycleViewHolder MesiboUI_onGetCustomRow(MesiboUI.MesiboScreen screen, MesiboUI.MesiboRow row) {
        return null; // the default rendering
    }

    @Override
    public void MesiboUI_onUpdateRow(MesiboUI.MesiboScreen screen, MesiboUI.MesiboRow row, boolean last) {
    }

    /**
     * The user did something (action.type, MesiboUI.ACTION_*): a row tapped, a profile to show,
     * an attachment, the camera, a voice message, a long press action, a message to send, ...
     * Return true to let the UI do it as usual, false when the app handled it. For example, to
     * check a message before it is sent (and change it, or return false to stop it):
     *     if (MesiboUI.ACTION_SEND == action.type) { ... action.message ... }
     */
    @Override
    public boolean MesiboUI_onAction(MesiboUI.MesiboScreen screen, MesiboUiAction action) {
        return true;
    }

    void initUserListScreen(MesiboUI.MesiboUserListScreen screen) {
        ((Activity)screen.parent).getMenuInflater().inflate(R.menu.menu_userlist, screen.menu);

        screen.menu.findItem(R.id.action_menu_e2ee).setOnMenuItemClickListener(item -> {
            MesiboUI.showEndToEndEncryptionConfiguration(screen.parent);
            return true;
        });

        // Customize: the look of the light or dark theme, saved by mesibo and used at once
        screen.menu.findItem(R.id.action_menu_customize).setOnMenuItemClickListener(item -> {
            MesiboUI.launchCustomize(screen.parent, (json, dark) -> {
                MesiboUI.saveCustomization(json, dark);
                return true;
            });
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
            MesiboUI.showEndToEndEncryptionInfo(context, profile);
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

        // end-to-end encryption of this chat only while it is on (when off, the screen would
        // only say the chat isn't end-to-end encrypted), and never for groups
        screen.menu.findItem(R.id.action_e2e).setVisible(Mesibo.e2ee().isEnabled()
                && (null == screen.profile || !screen.profile.isGroup()));

        // tap the name in the toolbar: the profile of the user or group
        screen.titleArea.setOnClickListener(v -> MesiboUI.showProfile(screen.parent, screen.profile));
    }
}
