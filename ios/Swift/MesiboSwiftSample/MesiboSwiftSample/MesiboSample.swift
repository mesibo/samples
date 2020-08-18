//
//  MesiboSample.swift
//  MesiboSwiftSample
//
//  Copyright © 2020 Mesibo. All rights reserved.
//

import Foundation
import mesibo

@objcMembers public class MesiboSample : NSObject, MesiboDelegate {
    static var getInstanceMyInstance: MesiboSample? = nil
    
    public class func getInstance() -> MesiboSample {
        if nil == getInstanceMyInstance {
            let lockQueue = DispatchQueue(label: "self")
            lockQueue.sync {
                if nil == getInstanceMyInstance {
                    getInstanceMyInstance = MesiboSample()
                    //getInstanceMyInstance?.initialize()
                }
            }
        }
        return getInstanceMyInstance!
    }
    
    func start(_ accessToken: String) {

        Mesibo.getInstance().setAccessToken(accessToken)
        Mesibo.getInstance()!.setDatabase("mesibo.db", resetTables: 0)
        Mesibo.getInstance()!.addListener(self)
        Mesibo.getInstance()!.start();
    }
    
    func sendMessage(_ to:String, message: String) {
        let params: MesiboParams = MesiboParams();
        params.flag = UInt32(MESIBO_FLAG_DELIVERYRECEIPT | MESIBO_FLAG_READRECEIPT);
        params.expiry = 3600*24*7;
        params.peer = to;
        Mesibo.getInstance()?.sendMessage(params, msgid: (Mesibo.getInstance()?.random())!, string: message)
    }
    
    func readStoredMessagesForUsr(_ address: String) {
        let readSession: MesiboReadSession = MesiboReadSession()
        readSession.initSession(address, groupid: 0, query: nil, delegate: self)
        readSession.enableSummary(false)
        readSession.enableReadReceipt(true)
        readSession.read(100)
    }
    
    func readStoredMessagesForGroup(_ groupId: UInt32) {
        let readSession: MesiboReadSession = MesiboReadSession()
        readSession.initSession(nil, groupid: groupId, query: nil, delegate: self)
        readSession.enableSummary(false)
        readSession.enableReadReceipt(true)
        readSession.read(100)
    }
    
    // mesibo delegates
    public func mesibo_(onMessage params: MesiboParams?, data: Data?) {
        
        var message: String? = nil
        if let data = data {
            message = String(data: data, encoding: .utf8)
        }
   
    }
    
    public func mesibo_(onFile params: MesiboParams?, file: MesiboFileInfo?) {
        
    }
    
    public func mesibo_(onLocation params: MesiboParams?, location: MesiboLocation?) {
        
    }
    
    public func mesibo_(onActivity params: MesiboParams?, activity: Int32) {
    }
    
    public func mesibo_(onConnectionStatus status: Int32) {
        
        if MESIBO_STATUS_SIGNOUT == status {
            
        } else if MESIBO_STATUS_AUTHFAIL == status {
        }
        
        if MESIBO_STATUS_ONLINE == status {
            print("You are online")
        }
    }

}
