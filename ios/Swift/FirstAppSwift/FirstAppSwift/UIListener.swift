//
//  UIListener.swift
//  Copyright © 2023 Mesibo. All rights reserved.
//

import Foundation
import MesiboUI
import MesiboCall

/* Messaging UI customization listener
  Refer to the https://mesibo.com/documentation/ui-modules/ for details
*/
@objcMembers public class UIListener : NSObject, MesiboUIListener {
    
    override init() {
        super.init()
        MesiboUI.setListener(self);
    }
    
    public func MesiboUI_onInitScreen(screen: MesiboScreen) -> Bool {
        if(screen.userList) {
            initilizeUserListScreen(screen: screen as! MesiboUserListScreen)
        }
        else {
            initilizeMessagingScreen(screen: screen as! MesiboMessageScreen)
        }
        return true;
    }
    
    public func MesiboUI_onGetCustomRowHeight(screen: MesiboScreen, row: MesiboRow) -> CGFloat {
        return -1;
    }
    
    public func MesiboUI_onGetCustomRow(screen: MesiboScreen, row: MesiboRow) -> MesiboCell? {
        return nil;
    }
    
    public func MesiboUI_onUpdateRow(screen: MesiboScreen, row: MesiboRow, last: Bool) -> Bool {
        return true;
    }
    
    public func MesiboUI_onShowScreen(screen: MesiboScreen) -> Bool {
        return false;
    }
    
    public func MesiboUI_onClickedRow(screen: MesiboScreen, row: MesiboRow) -> Bool {
        return false;
    }
    
    func initilizeUserListScreen(screen: MesiboUserListScreen) {
        // add custom buttons to User list screen
        let button = UIButton(type: .custom)
        var image = MesiboUI.imageNamed(MESIBO_DEFAULTICON_MESSAGE)
        button.setImage(image, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        button.tag = Int(MESIBOUI_TAG_NEWMESSAGE)
        screen.buttons = [button]
    }

    func initilizeMessagingScreen(screen: MesiboMessageScreen) {
        let profile = screen.profile
     
        if profile.isGroup() && !profile.isActive() {
            return
        }

        let button = UIButton(type: .custom)
        var image = MesiboUI.imageNamed(profile.isGroup() ? MESIBO_DEFAULTICON_GROUPAUDIOCALL : MESIBO_DEFAULTICON_AUDIOCALL)
        button.setImage(image, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        MesiboUI.addTarget(self, screen: screen, view: button, action: #selector(onAudioCall(sender:)))

        let vbutton = UIButton(type: .custom)
        image = MesiboUI.imageNamed(profile.isGroup() ? MESIBO_DEFAULTICON_GROUPVIDEOCALL : MESIBO_DEFAULTICON_VIDEOCALL)
        vbutton.setImage(image, for: .normal)
        vbutton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        MesiboUI.addTarget(self, screen: screen, view: vbutton, action: #selector(onVideoCall(sender:)))

        screen.buttons = [button, vbutton]

        MesiboUI.addTarget(self, screen: screen, view: screen.titleArea, action: #selector(onShowProfile(sender:)))
    }

    func makeCall(parent: Any, profile: MesiboProfile, video: Bool) {
        DispatchQueue.main.async(execute: {
            MesiboCall.getInstance().callUi(parent, profile: profile, video: video)
            
        })
    }


    @objc func onAudioCall(sender: Any) {

        let screen = MesiboUI.getParentScreen(sender) as! MesiboMessageScreen
        makeCall(parent: screen.parent, profile: screen.profile, video: false)
    }

    func onVideoCall(sender: Any) {
        let screen = MesiboUI.getParentScreen(sender) as! MesiboMessageScreen
        makeCall(parent: screen.parent, profile: screen.profile, video: true)
    }

    func onShowProfile(sender: Any) {
        let screen = MesiboUI.getParentScreen(sender) as! MesiboMessageScreen
        MesiboUI.showBasicProfileInfo(screen.parent, profile: screen.profile)
    }

    func onShowSettings(sender: Any) {

        let screen = MesiboUI.getParentScreen(sender) as! MesiboUserListScreen
        /* show your app settings - refer to messenger source for example */

    }
}
