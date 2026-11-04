package com.mesibo.firstapp

import android.app.Activity
import android.content.Context
import android.view.MenuItem
import com.mesibo.api.MesiboProfile
import com.mesibo.calls.api.MesiboCall
import com.mesibo.messaging.MesiboRecycleViewHolder
import com.mesibo.messaging.MesiboUI
import com.mesibo.messaging.MesiboUI.MesiboMessageScreen
import com.mesibo.messaging.MesiboUI.MesiboRow
import com.mesibo.messaging.MesiboUI.MesiboScreen
import com.mesibo.messaging.MesiboUI.MesiboUserListScreen
import com.mesibo.messaging.MesiboUIListener

/* Messaging UI customization listener (optional): adds the call and encryption buttons to the
  screens. Refer to https://docs.mesibo.com/ui-modules/customizing/ for details
*/
class UIListener : MesiboUIListener {
    override fun MesiboUI_onInitScreen(screen: MesiboScreen): Boolean {
        // other screens (e.g. the profile popup) are SCREEN_GENERIC
        if (MesiboUI.SCREEN_USERLIST == screen.type) {
            initUserListScreen(screen as MesiboUserListScreen)
        } else if (MesiboUI.SCREEN_MESSAGES == screen.type) {
            initMessageListScreen(screen as MesiboMessageScreen)
        }
        return false
    }

    override fun MesiboUI_onGetCustomRow(screen: MesiboScreen, row: MesiboRow): MesiboRecycleViewHolder? {
        return null // the default rendering
    }

    override fun MesiboUI_onUpdateRow(screen: MesiboScreen, row: MesiboRow, last: Boolean): Boolean {
        return false
    }

    override fun MesiboUI_onShowLocation(context: Context, profile: MesiboProfile): Boolean {
        return false // the default location picker
    }

    override fun MesiboUI_onClickedRow(screen: MesiboScreen, row: MesiboRow): Boolean {
        return false // the default action
    }

    private fun initUserListScreen(screen: MesiboUserListScreen) {
        (screen.parent as Activity).menuInflater.inflate(R.menu.menu_userlist, screen.menu)

        screen.menu.findItem(R.id.action_menu_e2ee).setOnMenuItemClickListener {
            MesiboUI.showEndToEndEncryptionInfoForSelf(screen.parent)
            true
        }
    }

    private fun messageListScreenMenuHandler(context: Context, item: Int, profile: MesiboProfile?) {
        if (null == profile) return

        // during a call, callUi brings back the call in progress instead
        when (item) {
            R.id.action_call -> MesiboCall.getInstance().callUi(context, profile, false)
            R.id.action_videocall -> MesiboCall.getInstance().callUi(context, profile, true)
            R.id.action_e2e -> MesiboUI.showEndToEndEncryptionInfo(context, profile.address, profile.groupid)
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

        // tap the name in the toolbar: the profile of the user or group
        screen.titleArea.setOnClickListener { MesiboUI.showProfile(screen.parent, screen.profile) }
    }
}
