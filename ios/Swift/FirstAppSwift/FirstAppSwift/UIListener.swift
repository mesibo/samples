//
//  UIListener.swift
//  FirstAppSwift
//
//  Messaging UI customization listener.
//  Refer to https://docs.mesibo.com/ui-modules/ for details.
//  Copyright © 2023 Mesibo. All rights reserved.
//

import UIKit
import mesibo
import MesiboUI
import MesiboCall

// tags of the call buttons we add, to find and replace them
private let callButtonVideo = 9001
private let callButtonVoice = 9002
private let callButtonInProgress = 9003

public class UIListener: NSObject, MesiboUIListener {

    // the screen each call button belongs to, for its action
    private let buttonScreens = NSMapTable<UIBarButtonItem, MesiboScreen>.weakToWeakObjects()

    override init() {
        super.init()
        MesiboUI.setListener(self)
    }


    // MARK: - MesiboUIListener

    /**
     * OPTIONAL - the texts, colors, etc. of the messaging UI (the same names on Android and iOS), set
     * on each new configuration (a theme applied). Refer to https://docs.mesibo.com/ui-modules/setting-defaults/
     */
    public func MesiboUI_onConfig(config: MesiboUiConfig, dark: Bool) {
        config.userList.emptyMessage = "No messages!"
        config.userList.showBackButton = true
    }

    /**
     * a screen was created: add buttons and menu items. Return true for this screen's other
     * callbacks (MesiboUI_onUpdateScreen, MesiboUI_onAction, the row callbacks), false for none.
     */
    public func MesiboUI_onInitScreen(screen: MesiboScreen) -> Bool {
        if Int32(screen.type) == MESIBO_SCREEN_USERLIST {
            // the chat list: add your own buttons or "more" menu items here (screen.buttons,
            // screen.menu). End-to-end encryption: turned on or off there (mesibo keeps the choice)
            let item = MesiboMenuItem(title: "End-to-end encryption", image: UIImage(systemName: "lock"), identifier: "e2ee") { [weak screen] _ in
                if let parent = screen?.parent {
                    MesiboUI.showEndToEndEncryptionConfiguration(parent)
                }
            }
            screen.menu.add(item)

            // Customize: the look of the light or dark theme, saved by mesibo and used at once
            let customize = MesiboMenuItem(title: "Customize", image: UIImage(systemName: "paintbrush"), identifier: "customize") { [weak screen] _ in
                guard let parent = screen?.parent else {
                    return
                }
                MesiboUI.launchCustomize(parent) { json, dark in
                    MesiboUI.saveCustomization(json, dark: dark)
                    return true
                }
            }
            screen.menu.add(customize)
            return true
        }

        if Int32(screen.type) == MESIBO_SCREEN_MESSAGES {
            // the end-to-end encryption of this chat (its state, the security code to compare),
            // only while it is on, and not for groups
            if Mesibo.getInstance().e2ee().isEnabled() && !(screen.profile?.isGroup() ?? false) {
                let item = MesiboMenuItem(title: "End-to-end encryption", image: UIImage(systemName: "lock.shield"), identifier: "e2ee") { [weak screen] _ in
                    if let parent = screen?.parent, let profile = screen?.profile {
                        MesiboUI.showEndToEndEncryptionInfo(parent, profile: profile)
                    }
                }
                screen.menu.add(item)
            }
            updateCallButtons(screen: screen)
            return true
        }

        if Int32(screen.type) == MESIBO_SCREEN_PROFILE, let profileScreen = screen as? MesiboProfileScreen {
            // the buttons under the name
            profileScreen.actions.addObjects(from: callItems(screen: screen))
        } else if Int32(screen.type) == MESIBO_SCREEN_PROFILE_POPUP {
            // the popup's buttons, between Message and Info
            screen.menu.addObjects(from: callItems(screen: screen))
        }
        return true
    }

    /**
     * Voice and video call buttons, for the profile screen and the profile popup (none for a group
     * the user left). During a call, they bring it back.
     */
    private func callItems(screen: MesiboScreen) -> [MesiboMenuItem] {
        guard let profile = screen.profile, !(profile.isGroup() && !profile.isActive()) else {
            return []
        }

        return [false, true].map { video in
            MesiboMenuItem(title: video ? "Video" : "Voice", image: UIImage(systemName: video ? "video.fill" : "phone.fill"),
                           identifier: video ? "videocall" : "voicecall") { [weak screen] _ in
                guard let parent = screen?.parent, let profile = screen?.profile else {
                    return
                }

                // during a call: back to it
                if MesiboCall.getInstance().isAnyCallInProgress() {
                    MesiboCall.getInstance().showCallInProgress(parent)
                    return
                }
                MesiboCall.getInstance().callUi(parent, profile: profile, video: video)
            }
        }
    }

    /** an open screen is refreshed (MesiboUI.updateScreens()), e.g. when a call starts or ends */
    public func MesiboUI_onUpdateScreen(screen: MesiboScreen) {
        updateCallButtons(screen: screen)
    }

    /** a row was bound: change colors etc. as suitable for your app */
    public func MesiboUI_onUpdateRow(screen: MesiboScreen, row: MesiboRow, last: Bool) {
    }

    /**
     * the user did something (action.type, MESIBO_ACTION_*): a row tapped, a profile to show, an
     * attachment, the camera, a voice message, a long press action, a message to send, ... Return
     * true to let the UI do it as usual, false when the app handled it. For example, to check a
     * message before it is sent (and change it, or return false to stop it):
     *     if Int32(action.type) == MESIBO_ACTION_SEND { ... action.message ... }
     */
    public func MesiboUI_onAction(screen: MesiboScreen, action: MesiboUiAction) -> Bool {
        return true
    }


    // MARK: - call buttons

    private func callButton(symbol: String, tag: Int, label: String, screen: MesiboScreen) -> UIBarButtonItem {
        let button = UIBarButtonItem(image: UIImage(systemName: symbol), style: .plain,
                                     target: self, action: #selector(onCallButton(_:)))
        button.tag = tag
        button.accessibilityLabel = label
        buttonScreens.setObject(screen, forKey: button)
        return button
    }

    /** video and voice call buttons in chats; during a call, a button to return to it */
    private func updateCallButtons(screen: MesiboScreen) {
        // remove the buttons we added before
        let ours = screen.buttons.indexesOfObjects { item, _, _ in
            guard let button = item as? UIBarButtonItem else { return false }
            return button.tag >= callButtonVideo && button.tag <= callButtonInProgress
        }
        screen.buttons.removeObjects(at: ours)

        if Int32(screen.type) != MESIBO_SCREEN_MESSAGES {
            return
        }

        if MesiboCall.getInstance().isAnyCallInProgress() {
            let button = callButton(symbol: "phone.connection", tag: callButtonInProgress,
                                    label: "Call in progress", screen: screen)
            button.tintColor = .systemGreen
            screen.buttons.add(button)
            return
        }

        // no calls in groups the user has left
        guard let profile = screen.profile else { return }
        if profile.isGroup() && !profile.isActive() {
            return
        }

        // shown left to right in the order added
        let group = profile.isGroup()
        screen.buttons.add(callButton(symbol: group ? "video.badge.plus" : "video", tag: callButtonVideo,
                                      label: group ? "Group video call" : "Video call", screen: screen))
        screen.buttons.add(callButton(symbol: group ? "phone.badge.plus" : "phone", tag: callButtonVoice,
                                      label: group ? "Group voice call" : "Voice call", screen: screen))
    }

    @objc private func onCallButton(_ sender: UIBarButtonItem) {
        guard let screen = buttonScreens.object(forKey: sender), let parent = screen.parent else { return }

        if sender.tag == callButtonInProgress {
            MesiboCall.getInstance().showCallInProgress(parent)
            return
        }

        guard let profile = screen.profile else { return }
        MesiboCall.getInstance().callUi(parent, profile: profile, video: sender.tag == callButtonVideo)
}
}
