
//
//  ParentConnector.swift
//  Heart IntervalTraxR WatchKit Extension
//
//  Created by DJ McKay on 12/4/17.
//  Copyright © 2017 DJ McKay. All rights reserved.
//

import WatchConnectivity

protocol ParentConnectorDelegate {
    func didReceiveMessage(messages: [String:Any])
}

class ParentConnector: NSObject, WCSessionDelegate {
    
    static let sharedInstance: ParentConnector = {
        let instance = ParentConnector()
        // setup code
        return instance
    }()
    
    // MARK: Properties
    
    var wcSession: WCSession!
    var delegate: ParentConnectorDelegate?
    var statesToSend = [String:Any]()
    
    override init() {
        super.init()
        
        if (WCSession.isSupported()) {
            wcSession = WCSession.default
            wcSession.delegate = self
            wcSession.activate()
        }
        
    }
    // MARK: Utility methods
    
    func send(state: String) {
        if let session = wcSession {
            if session.isReachable {
                session.sendMessage(["State": state], replyHandler: nil)
            }
        } else {
            WCSession.default.delegate = self
            WCSession.default.activate()
            statesToSend["State"] = state
        }
    }
    
    func send(message: [String : Any]) {
        if let session = wcSession {
            if session.isReachable {
                session.sendMessage(message, replyHandler: nil)
            }
        } else {
            WCSession.default.delegate = self
            WCSession.default.activate()
            for item in message {
                statesToSend[item.key] = item.value
            }
        }
    }
    
    func send(key: String, value: Any) {
        if let session = wcSession {
            if session.isReachable {
                session.sendMessage([key: value], replyHandler: nil)
            }
        } else {
            WCSession.default.delegate = self
            WCSession.default.activate()
            statesToSend[key] = value
        }
    }
    
    // MARK : WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if activationState == .activated {
            wcSession = session
            sendPending()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void) {
        let value = message["State"] as? String
        if let authorization = message["Authorization"] as? Bool {
            HealthKitManager.sharedInstance.authorized = authorization
        }
        delegate?.didReceiveMessage(messages: message)
        
    }
    
    private func sendPending() {
        if let session = wcSession, session.isReachable {
            for state in statesToSend {
                session.sendMessage([state.key: state.value], replyHandler: nil)
            }
            statesToSend.removeAll()
        }
    }
}

