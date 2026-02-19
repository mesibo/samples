package com.mesibo.firstapp

import com.mesibo.messaging.MesiboUIListener
import com.mesibo.messaging.MesiboUI.MesiboScreen
import com.mesibo.messaging.MesiboUI.MesiboUserListScreen
import com.mesibo.messaging.MesiboUI.MesiboMessageScreen
import com.mesibo.messaging.MesiboUI.MesiboRow
import com.mesibo.messaging.MesiboRecycleViewHolder
import com.mesibo.api.MesiboProfile
import com.mesibo.firstapp.R
import com.mesibo.messaging.MesiboUI
import android.app.Activity
import android.content.Context
import android.view.MenuItem
import com.mesibo.calls.api.MesiboCall

/* Messaging UI customization listener
  Refer to the https://docs.mesibo.com/ui-modules/ for details
*/
class UIListener : MesiboUIListener {
    override fun MesiboUI_onInitScreen(screen: MesiboScreen): Boolean {
        if (screen.userList) {
            mLastUserListContext = screen.parent
            initUserListScreen(screen as MesiboUserListScreen)
        } else {
            mLastMessagingContext = screen.parent
            initMessageListScreen(screen as MesiboMessageScreen)
        }
        return false
    }

    override fun MesiboUI_onGetCustomRow(
        screen: MesiboScreen,
        row: MesiboRow
    ): MesiboRecycleViewHolder? {
        return null
    }

    override fun MesiboUI_onUpdateRow(
        screen: MesiboScreen,
        row: MesiboRow,
        last: Boolean
    ): Boolean {
        return false
    }

    override fun MesiboUI_onShowLocation(context: Context, profile: MesiboProfile): Boolean {
        return false
    }

    override fun MesiboUI_onClickedRow(screen: MesiboScreen, row: MesiboRow): Boolean {
        return false
    }

    fun userListScreenMenuHandler(context: Context?, item: Int) {
        if (item == R.id.action_settings) {
        } else if (item == R.id.action_menu_e2ee) {
            MesiboUI.showEndToEndEncryptionInfoForSelf(context)
        } else if (item == R.id.mesibo_share) {
        }
    }

    fun initUserListScreen(screen: MesiboUserListScreen) {
        (screen.parent as Activity).menuInflater.inflate(R.menu.menu_userlist, screen.menu)
        val menuhandler = MenuItem.OnMenuItemClickListener { item ->
            userListScreenMenuHandler(screen.parent, item.itemId)
            true
        }
        screen.menu.findItem(R.id.action_menu_e2ee).setOnMenuItemClickListener(menuhandler)
    }

    fun messageListScreenMenuHandler(context: Context?, item: Int, profile: MesiboProfile?) {
        if (null == profile) {
            return
        }
        if (R.id.action_call == item) {
            if (!MesiboCall.getInstance().callUi(context, profile, false)) MesiboCall.getInstance()
                .callUiForExistingCall(context)
        } else if (R.id.action_videocall == item) {
            if (!MesiboCall.getInstance().callUi(context, profile, true)) MesiboCall.getInstance()
                .callUiForExistingCall(context)
        } else if (R.id.action_e2e == item) {
            MesiboUI.showEndToEndEncryptionInfo(context, profile.getAddress(), profile.groupid)
        }
    }

    fun initMessageListScreen(screen: MesiboMessageScreen) {
        (screen.parent as Activity).menuInflater.inflate(R.menu.menu_messaging, screen.menu)

        /* different item for group calls */if (null != screen.profile && screen.profile.isGroup) {
            var menuItem = screen.menu.findItem(R.id.action_call)
            if (!screen.profile.isActive) menuItem.isVisible = false
            menuItem.setIcon(R.drawable.ic_mesibo_groupcall_audio)
            // MenuItemCompat.setShowAsAction(menuItem, MenuItemCompat.SHOW_AS_ACTION_NEVER);
            menuItem = screen.menu.findItem(R.id.action_videocall)
            menuItem.setIcon(R.drawable.ic_mesibo_groupcall_video)
            if (!screen.profile.isActive) menuItem.isVisible = false
            //MenuItemCompat.setShowAsAction(menuItem, MenuItemCompat.SHOW_AS_ACTION_NEVER);
        }
        val menuhandler = MenuItem.OnMenuItemClickListener { item ->
            messageListScreenMenuHandler(screen.parent, item.itemId, screen.profile)
            true
        }
        screen.menu.findItem(R.id.action_call).setOnMenuItemClickListener(menuhandler)
        screen.menu.findItem(R.id.action_videocall).setOnMenuItemClickListener(menuhandler)
        screen.menu.findItem(R.id.action_e2e).setOnMenuItemClickListener(menuhandler)
        screen.titleArea.setOnClickListener {
            MesiboUI.showBasicProfileInfo(
                screen.parent,
                screen.profile
            )
        }
    }

    companion object {
        private var mLastUserListContext: Context? = null
        private var mLastMessagingContext: Context? = null
        val lastUserListContext: Context?
            get() = mLastUserListContext
        val lastMessagingContext: Context?
            get() = mLastMessagingContext
    }
}
