//
//  WatchManager.swift
//  Heart IntervalTraxR
//
//  Created by DJ McKay on 12/4/17.
//  Copyright © 2017 DJ McKay. All rights reserved.
//

import Foundation
import WatchConnectivity

protocol WatchConnectorDelegate {
    func didReceiveMessage(message: [String:Any])
}

class WatchManager: NSObject, WCSessionDelegate {
    
    static let sharedInstance: WatchManager = {
        let instance = WatchManager()
        // setup code
        return instance
    }()
    
    private var wcSessionActivationCompletion: ((WCSession) -> Void)?
    private var watchConnectivitySession: WCSession = WCSession.default
    var delegate: WatchConnectorDelegate?
    
    func send(state: String) {
        getActiveWCSession { (session) in
            session.sendMessage(["State":state], replyHandler: { (message) in
                
            }, errorHandler: { (error) in
                
            })
        }
    }
    
    func send(key: String, value: Any) {
        getActiveWCSession { (session) in
            session.sendMessage([key: value], replyHandler: { (message) in
                
            }, errorHandler: { (error) in
                
            })
        }
    }
    
    private func getActiveWCSession(completion: @escaping (WCSession) -> Void) {
        guard WCSession.isSupported() else {
            // ... Alert the user that their iOS device does not support watch connectivity
            fatalError("watch connectivity session not supported")
        }
        
        watchConnectivitySession.delegate = self
        
        switch watchConnectivitySession.activationState {
        case .activated:
            completion(watchConnectivitySession)
        case .inactive, .notActivated:
            watchConnectivitySession.activate()
            wcSessionActivationCompletion = completion
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated, let activationCompletion = wcSessionActivationCompletion {
            activationCompletion(session)
            wcSessionActivationCompletion = nil
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.updateSessionState(message)
        }
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
    }
    
    private func updateSessionState(_ message: [String : Any]) {
        print(message)
        print("updateSessionState")
        self.delegate?.didReceiveMessage(message: message)
        
    }
    
}
