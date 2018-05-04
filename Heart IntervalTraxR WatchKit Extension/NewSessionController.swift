//
//  NewSessionController.swift
//  Heart IntervalTraxR WatchKit Extension
//
//  Created by DJ McKay on 12/5/17.
//  Copyright © 2017 DJ McKay. All rights reserved.
//

import UIKit
import WatchKit

class NewSessionController: WKInterfaceController {

    
    @IBOutlet private weak var newSessionButton : WKInterfaceButton!
    
    var heartIntervalController: HeartIntervalController = HeartIntervalController.sharedInstance

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        heartIntervalController.delegate = self
        heartIntervalController.authorizeHealthKit()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func displayAlert(_ string: String) {
        
        
        
        let action = WKAlertAction(title: "OK",
                                   style: .default,
                                   handler: {
                                    
        })
        
        presentAlert(withTitle: nil, message: string, preferredStyle: .alert, actions: [action])
    }
    
}

extension NewSessionController: HeartIntervalDelegate {
    func sessionEnded() {
        
    }
    
    func sessionStarted() {
        
    }
    
    func updateCountdown() {
        
    }
    
    func updateHeartRate(_ heartRate: Int16) {
        
    }
    
    func updateDeviceName(_ name: String) {
        //deviceLabel.setText(name)
    }
    
    func timerNotStarted() {
    }
    
    func authorized() {
    }
    
    func notAuthorized() {
        self.displayAlert("Not Allowed")
    }
    
    func timerStarting(_ duration: TimeInterval) {
        
    }
    
    func timerStopping() {
       
    }
}


