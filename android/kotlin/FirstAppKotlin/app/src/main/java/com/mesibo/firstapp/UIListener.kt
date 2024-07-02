package com.mesibo.firstapp

import android.content.Context
import android.view.Menu
import android.view.MenuItem
import com.mesibo.api.Mesibo
import com.mesibo.api.MesiboProfile
import com.mesibo.calls.api.MesiboCall
import com.mesibo.messaging.MesiboRecycleViewHolder
import com.mesibo.messaging.MesiboUI
import com.mesibo.messaging.MesiboUI.MesiboMessageScreen
import com.mesibo.messaging.MesiboUI.MesiboRow
import com.mesibo.messaging.MesiboUI.MesiboScreen
import com.mesibo.messaging.MesiboUI.MesiboUserListScreen
import com.mesibo.messaging.MesiboUIListener

/* Messaging UI customization listener
 Refer to the https://mesibo.com/documentation/ui-modules/ for details
*/
class UIListener : MesiboUIListener {
    override fun MesiboUI_onInitScreen(screen: MesiboScreen): Boolean {
        if (screen.userList) {
            lastUserListContext = screen.parent
            initUserListScreen(screen as MesiboUserListScreen)
        } else {
            lastMessagingContext = screen.parent
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
        if (item == MENU_E2EE) {
            MesiboUI.showEndToEndEncryptionInfoForSelf(context)
        }
    }

    fun initUserListScreen(screen: MesiboUserListScreen) {
        screen.menu.clear()


        val menuhandler = MenuItem.OnMenuItemClickListener { item ->
            userListScreenMenuHandler(screen.parent, item.itemId)
            true
        }

        /* Creating menu dynamically - alternatively you can also inflate menus from XML resource files */
        var menuItem = screen.menu.add(0, R.id.mesibo_contacts, Menu.NONE, "New Message")
        menuItem.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
        menuItem.setIcon(MesiboUI.MESIBO_DEFAULTICON_MESSAGE)

        //menuItem.setOnMenuItemClickListener(menuhandler);
        menuItem = screen.menu.add(0, MENU_E2EE, Menu.NONE, "End-toEnd Encryption")
        menuItem.setShowAsAction(MenuItem.SHOW_AS_ACTION_NEVER)
        menuItem.setOnMenuItemClickListener(menuhandler)
    }

    fun messageListScreenMenuHandler(context: Context?, item: Int, profile: MesiboProfile?) {
        if (null == profile) {
            return
        }

        if (MENU_AUDIOCALL == item) {
            if (!MesiboCall.getInstance().callUi(context, profile, false)) MesiboCall.getInstance()
                .callUiForExistingCall(context)
        } else if (MENU_VIDEOCALL == item) {
            if (!MesiboCall.getInstance().callUi(context, profile, true)) MesiboCall.getInstance()
                .callUiForExistingCall(context)
        } else if (MENU_E2EE == item) {
            MesiboUI.showEndToEndEncryptionInfo(context, profile.getAddress(), profile.groupid)
        }
    }

    fun initMessageListScreen(screen: MesiboMessageScreen) {
        screen.menu.clear()

        val menuhandler = MenuItem.OnMenuItemClickListener { item ->
            messageListScreenMenuHandler(screen.parent, item.itemId, screen.profile)
            true
        }

        /* Creating menu dynamically - alternatively you can also inflate menus from XML resource files */
        // set group call icons
        if (null != screen.profile) {
            var menuItem = screen.menu.add(0, MENU_AUDIOCALL, Menu.NONE, "Audio Call")
            menuItem.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)

            if (screen.profile.isGroup && !screen.profile.isActive) menuItem.setVisible(false)
            menuItem.setIcon(if (screen.profile.isGroup) MesiboCall.MESIBO_DEFAULTICON_GROUPAUDIOCALL else MesiboCall.MESIBO_DEFAULTICON_AUDIOCALL)
            menuItem.setOnMenuItemClickListener(menuhandler)

            // MenuItemCompat.setShowAsAction(menuItem, MenuItemCompat.SHOW_AS_ACTION_NEVER);
            menuItem = screen.menu.add(0, MENU_VIDEOCALL, Menu.NONE, "Video Call")
            menuItem.setIcon(if (screen.profile.isGroup) MesiboCall.MESIBO_DEFAULTICON_GROUPVIDEOCALL else MesiboCall.MESIBO_DEFAULTICON_VIDEOCALL)
            if (screen.profile.isGroup && !screen.profile.isActive) menuItem.setVisible(false)
            menuItem.setOnMenuItemClickListener(menuhandler)
            menuItem.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)

            if (Mesibo.e2ee().isEnabled) {
                menuItem = screen.menu.add(0, MENU_E2EE, Menu.NONE, "End-toEnd Encryption")
                menuItem.setShowAsAction(MenuItem.SHOW_AS_ACTION_NEVER)
                menuItem.setOnMenuItemClickListener(menuhandler)
            }
        }

        screen.titleArea.setOnClickListener {
            MesiboUI.showBasicProfileInfo(
                screen.parent,
                screen.profile
            )
        }
    }

    companion object {
        var lastUserListContext: Context? = null
            private set
        var lastMessagingContext: Context? = null
            private set

        // define some menu IDs for dynamic menus on userlist and message screen
        private const val MENU_AUDIOCALL = Menu.FIRST
        private const val MENU_VIDEOCALL = Menu.FIRST + 1
        private const val MENU_E2EE = Menu.FIRST + 2
        private const val MENU_MESSAGE = Menu.FIRST + 3
    }
}
