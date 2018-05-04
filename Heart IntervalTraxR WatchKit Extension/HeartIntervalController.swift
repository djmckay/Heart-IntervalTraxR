//
//  HeartIntervalController.swift
//  Heart IntervalTraxR WatchKit Extension
//
//  Created by DJ McKay on 12/3/17.
//  Copyright © 2017 DJ McKay. All rights reserved.
//

import Foundation
import HealthKit

protocol HeartIntervalDelegate {
    func authorized()
    func notAuthorized()
    func timerNotStarted()
    func updateHeartRate(_ heartRate: Int16)
    func updateDeviceName(_ name: String)
    func timerStarting(_ duration: TimeInterval)
    func timerStopping()
    func sessionStarted()
    func sessionEnded()

}

class HeartIntervalController {
    
    var delegate: HeartIntervalDelegate?
    
    let healthKitManager:HealthKitManager = HealthKitManager.sharedInstance
    var userHealthProfile: UserHealthProfile?

    var sessionActive: Bool = false
    var intervalActive: Bool = false

    var currentQuery : HKQuery?
    let heartRateUnit = HKUnit(from: "count/min")
    
    var doneTimer: Timer?
    var duration: TimeInterval = 30.0
    
    var elapsedTime : TimeInterval = 0.0 //time that has passed between pause/resume

    var currentZoneValue: ZoneType = ZoneType.Fatburning
    var range: (lower: Int, upper: Int)!
    
    var sessionTotalTime: TimeInterval {
        get {
            return endSessionTime?.timeIntervalSince(startSessionTime!) ?? 0
        }
    }
    
    var rangeTotalTime: TimeInterval {
        get {
            if let time = startRangeTime {
                return endSessionTime?.timeIntervalSince(time) ?? 0
            } else { return 0 }
        }
    }
    var timeToTargetZone: TimeInterval {
        get {
            return startRangeTime?.timeIntervalSince(startSessionTime!) ?? 0
        }
    }
    
    static let sharedInstance: HeartIntervalController = {
        let instance = HeartIntervalController()
        // setup code
        return instance
    }()
    
    func startStop() {
        if (self.sessionActive) {
            self.end()
        } else {
            self.start()
        }
        
    }
    
    var startSessionTime: Date?
    var startRangeTime: Date?
    var endSessionTime: Date?
    
    fileprivate func start() {
        if let profile = userHealthProfile {
            range = profile.getRange(for: self.currentZoneValue)
            print(range.lower)
            print(range.upper)
        }
        print("User Duration: \(self.duration)")
        if let query = healthKitManager.createHeartRateStreamingQuery(nil, updateHeartRate) {
            self.currentQuery = query
            healthKitManager.execute(query: query)
            self.sessionActive = true
            self.delegate?.sessionStarted()
            startSessionTime = Date()

        } else {
            self.delegate?.timerNotStarted()
            self.delegate?.timerStopping()
        }
        
    }
    
    @objc fileprivate func endSession() {
        self.startStop()
        
    }
    
    fileprivate func end() {
        self.endSessionTime = Date()
        self.delegate?.timerStopping()
        self.delegate?.sessionEnded()

        doneTimer?.invalidate()
        print("Time elapsed before hitting target zone: \(self.timeToTargetZone)")
        print("Time elapsed in target zone: \(self.rangeTotalTime)")
        print("Total session time elapsed: \(self.sessionTotalTime)")
        if let query = self.currentQuery {
            healthKitManager.stop(query: query)
            self.sessionActive = false
        }
    }
    
    func authorizeHealthKit()
    {
//        print(healthKitManager.authorized)
//        self.delegate?.authorized()
//        if healthKitManager.authorized {
//            self.delegate?.authorized()
//        } else {
//            self.delegate?.notAuthorized()
//        }
        
        healthKitManager.authorizeHealthKit { (success, error) in
            if let error = error {
                print(error)
            }
            if success {
                self.delegate?.authorized()
            } else {
                self.delegate?.notAuthorized()
            }
        }
    }
    
    func updateHeartRate(_ sample: HKQuantitySample) {
        let value = sample.quantity.doubleValue(for: self.heartRateUnit)
        
        self.delegate?.updateHeartRate(Int16(value))
        self.delegate?.updateDeviceName(sample.sourceRevision.source.name)
        if Int(value) > self.range.lower {
            self.delegate?.timerStarting(duration)
            self.startRangeTime = Date()
            //doneTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.endSession), userInfo: nil, repeats: false)
            DispatchQueue.main.async {
                self.doneTimer = Timer.scheduledTimer(withTimeInterval: self.duration, repeats: false) { _ in
                    self.endSession()
                }
            }
            
        } else if Int(value) > self.range.upper {
            self.endSession()
        }
        
        
    }
    

}



