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

    /** a screen was created: add buttons and menu items */
    public func MesiboUI_onInitScreen(screen: MesiboScreen) -> Bool {
        if Int32(screen.type) == MESIBO_SCREEN_USERLIST {
            // the chat list: add your own buttons or "more" menu items here
            // (screen.buttons, screen.menu)
            return false
        }

        if Int32(screen.type) == MESIBO_SCREEN_MESSAGES {
            updateCallButtons(screen: screen)
        }
        return false
    }

    /** an open screen is refreshed (MesiboUI.updateScreens()), e.g. when a call starts or ends */
    public func MesiboUI_onUpdateScreen(screen: MesiboScreen) {
        updateCallButtons(screen: screen)
    }

    /** a row was bound: change colors etc. as suitable for your app */
    public func MesiboUI_onUpdateRow(screen: MesiboScreen, row: MesiboRow, last: Bool) -> Bool {
        return false
    }

    /** a row was tapped: return true if you handled it */
    public func MesiboUI_onClickedRow(screen: MesiboScreen, row: MesiboRow) -> Bool {
        return false
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
            MesiboCall.getInstance().show(inProgress: parent)
            return
        }

        guard let profile = screen.profile else { return }
        MesiboCall.getInstance().callUi(parent, profile: profile, video: sender.tag == callButtonVideo)
    :qa
}
}
