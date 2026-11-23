package com.mesibo.firstapp

import android.app.Activity
import android.content.Context
import android.view.MenuItem
import com.mesibo.api.Mesibo
import com.mesibo.api.MesiboProfile
import com.mesibo.calls.api.MesiboCall
import com.mesibo.messaging.MesiboRecycleViewHolder
import com.mesibo.messaging.MesiboUI
import com.mesibo.messaging.MesiboUiAction
import com.mesibo.messaging.MesiboUI.MesiboMessageScreen
import com.mesibo.messaging.MesiboUI.MesiboRow
import com.mesibo.messaging.MesiboUI.MesiboScreen
import com.mesibo.messaging.MesiboUI.MesiboUserListScreen
import com.mesibo.messaging.MesiboUIListener
import com.mesibo.messaging.MesiboUiConfig

/* Messaging UI customization listener (optional): adds the call and encryption buttons to the
  screens. Refer to https://docs.mesibo.com/ui-modules/customizing/ for details
*/
class UIListener : MesiboUIListener {

    companion object {
        // ids of the call items of the profile screen and popup
        private const val MENU_PROFILE_VOICE = 9101
        private const val MENU_PROFILE_VIDEO = 9102
    }

    /**
     * OPTIONAL - the texts, colors, etc. of the messaging UI (the same names on Android and iOS), set
     * on each new configuration (a theme applied). Refer to the documentation
     * https://docs.mesibo.com/ui-modules/setting-defaults/
     */
    override fun MesiboUI_onConfig(config: MesiboUiConfig, dark: Boolean) {
        config.messages.showMissedCalls = true
        config.userList.showBackButton = true
    }

    override fun MesiboUI_onInitScreen(screen: MesiboScreen): Boolean {
        // SCREEN_PROFILE and SCREEN_PROFILE_POPUP get the call buttons; other screens are SCREEN_GENERIC
        if (MesiboUI.SCREEN_USERLIST == screen.type) {
            initUserListScreen(screen as MesiboUserListScreen)
        } else if (MesiboUI.SCREEN_MESSAGES == screen.type) {
            initMessageListScreen(screen as MesiboMessageScreen)
        } else if (MesiboUI.SCREEN_PROFILE == screen.type) {
            // the buttons under the name
            addCallItems((screen as MesiboUI.MesiboProfileScreen).actions, screen)
        } else if (MesiboUI.SCREEN_PROFILE_POPUP == screen.type) {
            // the popup's buttons, between Message and Info
            addCallItems(screen.menu, screen)
        }
        return true
    }

    /**
     * Voice and video call buttons, for the profile screen and the profile popup (none for a group
     * the user left). During a call, they bring it back.
     */
    private fun addCallItems(menu: android.view.Menu?, screen: MesiboScreen) {
        val profile = screen.profile ?: return
        if (null == menu || (profile.isGroup && !profile.isActive))
            return

        for (video in listOf(false, true)) {
            menu.add(android.view.Menu.NONE, if (video) MENU_PROFILE_VIDEO else MENU_PROFILE_VOICE, if (video) 51 else 50,
                    if (video) "Video" else "Voice")
                .setIcon(if (video) R.drawable.ic_mesibo_videocam else R.drawable.ic_mesibo_call)
                .setOnMenuItemClickListener {
                    // during a call: back to it
                    if (MesiboCall.getInstance().isAnyCallInProgress)
                        MesiboCall.getInstance().showCallInProgress(screen.parent)
                    else
                        MesiboCall.getInstance().callUi(screen.parent, profile, video)
                    true
                }
        }
    }

    override fun MesiboUI_onGetCustomRow(screen: MesiboScreen, row: MesiboRow): MesiboRecycleViewHolder? {
        return null // the default rendering
    }

    override fun MesiboUI_onUpdateRow(screen: MesiboScreen, row: MesiboRow, last: Boolean) {
    }


    /**
     * The user did something (action.type, MesiboUI.ACTION_*): a row tapped, a profile to show,
     * an attachment, the camera, a voice message, a long press action, a message to send, ...
     * Return true to let the UI do it as usual, false when the app handled it. For example, to
     * check a message before it is sent (and change it, or return false to stop it):
     *     if (MesiboUI.ACTION_SEND == action.type) { ... action.message ... }
     */
    override fun MesiboUI_onAction(screen: MesiboScreen, action: MesiboUiAction): Boolean {
        return true
    }

    private fun initUserListScreen(screen: MesiboUserListScreen) {
        (screen.parent as Activity).menuInflater.inflate(R.menu.menu_userlist, screen.menu)

        screen.menu.findItem(R.id.action_menu_e2ee).setOnMenuItemClickListener {
            MesiboUI.showEndToEndEncryptionConfiguration(screen.parent)
            true
        }

        // Customize: the look of the light or dark theme, saved by mesibo and used at once
        screen.menu.findItem(R.id.action_menu_customize).setOnMenuItemClickListener {
            MesiboUI.launchCustomize(screen.parent) { json, dark ->
                MesiboUI.saveCustomization(json, dark)
                true
            }
            true
        }
    }

    private fun messageListScreenMenuHandler(context: Context, item: Int, profile: MesiboProfile?) {
        if (null == profile) return

        // during a call, callUi brings back the call in progress instead
        when (item) {
            R.id.action_call -> MesiboCall.getInstance().callUi(context, profile, false)
            R.id.action_videocall -> MesiboCall.getInstance().callUi(context, profile, true)
            R.id.action_e2e -> MesiboUI.showEndToEndEncryptionInfo(context, profile)
        }
    }

    private fun initMessageListScreen(screen: MesiboMessageScreen) {
        (screen.parent as Activity).menuInflater.inflate(R.menu.menu_messaging, screen.menu)

        val profile = screen.profile
        if (null != profile) {
            val group = profile.isGroup
            // no calls in a group you are not a member of anymore
            val canCall = !group || profile.isActive

            var menuItem = screen.menu.findItem(R.id.action_call)
            menuItem.setIcon(if (group) MesiboCall.MESIBO_DEFAULTICON_GROUPAUDIOCALL else MesiboCall.MESIBO_DEFAULTICON_AUDIOCALL)
            menuItem.isVisible = canCall

            menuItem = screen.menu.findItem(R.id.action_videocall)
            menuItem.setIcon(if (group) MesiboCall.MESIBO_DEFAULTICON_GROUPVIDEOCALL else MesiboCall.MESIBO_DEFAULTICON_VIDEOCALL)
            menuItem.isVisible = canCall
        }

        val menuhandler = MenuItem.OnMenuItemClickListener { item ->
            messageListScreenMenuHandler(screen.parent, item.itemId, screen.profile)
            true
        }
        screen.menu.findItem(R.id.action_call).setOnMenuItemClickListener(menuhandler)
        screen.menu.findItem(R.id.action_videocall).setOnMenuItemClickListener(menuhandler)
        screen.menu.findItem(R.id.action_e2e).setOnMenuItemClickListener(menuhandler)

        // end-to-end encryption of this chat only while it is on (when off, the screen would
        // only say the chat isn't end-to-end encrypted), and never for groups
        screen.menu.findItem(R.id.action_e2e).isVisible =
            Mesibo.e2ee().isEnabled && screen.profile?.isGroup != true

        // tap the name in the toolbar: the profile of the user or group
        screen.titleArea.setOnClickListener { MesiboUI.showProfile(screen.parent, screen.profile) }
    }
}
