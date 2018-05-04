//
//  InterfaceController.swift
//  Heart IntervalTraxR WatchKit Extension
//
//  Created by DJ McKay on 12/3/17.
//  Copyright © 2017 DJ McKay. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    @IBOutlet private weak var heartRateLabel: WKInterfaceLabel!
    @IBOutlet private weak var deviceLabel : WKInterfaceLabel!
    @IBOutlet private weak var heart: WKInterfaceImage!
    @IBOutlet private weak var startStopButton : WKInterfaceButton!
    @IBOutlet weak var watchTimer: WKInterfaceTimer!
    
    
    
    var heartIntervalController: HeartIntervalController = HeartIntervalController.sharedInstance
    var parentConnector: ParentConnector = ParentConnector.sharedInstance

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        parentConnector.delegate = self

        self.authorize()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func startBtnTapped() {
        self.startStop()
    }

}

extension InterfaceController: HeartIntervalDelegate {
    func sessionEnded() {
        self.parentConnector.send(message: ["Session": false, "SessionDuration": heartIntervalController.sessionTotalTime, "RangeTotalTime": heartIntervalController.rangeTotalTime, "TimeToTargetZone": heartIntervalController.timeToTargetZone])
    }
    
    func sessionStarted() {
        self.startStopButton.setTitle("Stop")
        self.watchTimer.stop()
        self.watchTimer.setDate(Date(timeIntervalSinceNow: 0))
        self.watchTimer.start()
        //self.parentConnector.send(key: "Session", value: true)
        self.parentConnector.send(message: ["Session": true,
                                            "RangeMin": self.heartIntervalController.range.lower,
                                            "RangeMax": self.heartIntervalController.range.upper])

    }
    
    func updateHeartRate(_ heartRate: Int16) {
        self.heartRateLabel.setText(String(heartRate))
        self.animateHeart()
        self.parentConnector.send(key: "HR", value: String(heartRate))

    }
    
    func updateDeviceName(_ name: String) {
        //deviceLabel.setText(name)
    }
    
    func timerNotStarted() {
        heartRateLabel.setText("cannot start")
    }
    
    func authorized() {
        self.startStopButton.setEnabled(true)
    }
    
    func notAuthorized() {
        self.displayNotAllowed()
    }
    
    func timerStarting(_ duration: TimeInterval) {
        self.watchTimer.stop()
        print(duration)
        print(Date(timeIntervalSinceNow: duration))
        watchTimer.setDate(Date(timeIntervalSinceNow: duration))
        watchTimer.start()
//        self.parentConnector.send(key: "TimerStarted", value: true)
//        self.parentConnector.send(key: "TimerDuration", value: duration)
        self.parentConnector.send(message: ["TimerStarted": true, "TimerDuration": duration])

    }
    
    func timerStopping() {
        watchTimer.stop()
        self.startStopButton.setTitle("Start")
        self.parentConnector.send(key: "TimerStopped", value: true)

    }
}

extension InterfaceController: InterfaceControllerProtocol {
    
    func startStop() {
        heartIntervalController.startStop()
        
    }
    
    func authorize() {
        self.startStopButton.setEnabled(false)
        heartIntervalController.delegate = self
        heartIntervalController.authorizeHealthKit()
    }
    
    
    func displayNotAllowed() {
        heartRateLabel.setText("not allowed")
    }
    
    func animateHeart() {
        self.animate(withDuration: 0.5) {
            self.heart.setWidth(12)
            self.heart.setHeight(12)
        }
        
        let when = DispatchTime.now() + Double(Int64(0.5 * double_t(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.animate(withDuration: 0.5, animations: {
                    self.heart.setWidth(10)
                    self.heart.setHeight(10)
                })
                
            }
            
            
        }
    }
    
}

extension InterfaceController: ParentConnectorDelegate {
    func didReceiveMessage(messages: [String : Any]) {
        print(messages)
    }
    
    
}


