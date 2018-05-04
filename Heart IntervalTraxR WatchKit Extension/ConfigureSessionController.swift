//
//  ConfigureSessionController.swift
//  Heart IntervalTraxR WatchKit Extension
//
//  Created by DJ McKay on 12/5/17.
//  Copyright © 2017 DJ McKay. All rights reserved.
//

import UIKit
import WatchKit
import HealthKit



class ConfigureSessionController: WKInterfaceController {

    @IBOutlet var maxHRZoneLabel: WKInterfaceLabel!
    @IBOutlet var minHRZoneLabel: WKInterfaceLabel!
    @IBOutlet var zoneSlider: WKInterfaceSlider!
    
    @IBOutlet var doneButton : WKInterfaceButton!

    @IBOutlet var targetZoneLabel: WKInterfaceLabel!
    
    var userHealthProfile: UserHealthProfile = UserHealthProfile()
    var heartIntervalController: HeartIntervalController = HeartIntervalController.sharedInstance

    fileprivate func updateRange() {
        let range = self.userHealthProfile.getRange(for: self.heartIntervalController.currentZoneValue)
        print(range.upper)
        print(range.lower)
        self.maxHRZoneLabel.setText(range.upper.description)
        self.minHRZoneLabel.setText(range.lower.description)
        self.targetZoneLabel.setText(self.heartIntervalController.currentZoneValue.name)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        do {
            let userAgeSexAndBloodType = try ProfileDataStore.getAgeAndSex()
            userHealthProfile.age = userAgeSexAndBloodType.age
            userHealthProfile.biologicalSex = userAgeSexAndBloodType.biologicalSex
            HeartIntervalController.sharedInstance.userHealthProfile = userHealthProfile
            getMostRecetRestingHeartRate() {
                self.updateRange()
            }
            //calculate zone if age/resting
            //calculate zone by age
            //display zone
            
            
        } catch let error {
            print(error)
            //self.displayAlert(for: error)
        }
        
        DispatchQueue.main.async {
            self.zoneSlider.setValue(Float(self.heartIntervalController.currentZoneValue.rawValue))

        }
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        
        
    }
    
    
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    
    @IBAction func zoneSliderDidChange(_ value: Float) {
        print(value)
        print(Float(self.heartIntervalController.currentZoneValue.rawValue))
        heartIntervalController.currentZoneValue = ZoneType(rawValue: Int(value))!
//        if Float(self.currentZoneValue.rawValue) < value {
//            currentZoneValue = ZoneType(rawValue: self.currentZoneValue.rawValue + 1)!
//        } else if Float(self.currentZoneValue.rawValue) > value {
//
//        }
        self.targetZoneLabel.setText(self.heartIntervalController.currentZoneValue.name)
        updateRange()
    }
    
    let heartRateUnit = HKUnit(from: "count/min")

    private func getMostRecetRestingHeartRate(_ completion: @escaping () -> ()) {
        
        guard let restingHeartRate = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.restingHeartRate)
        
        //restingHeartRate = HKSampleType.quantityType(forIdentifier: .restingHeartRate)
            else {
            print("Resting heart rate is no longer available in HealthKit")
            return
        }
        
        ProfileDataStore.getMostRecentSample(for: restingHeartRate) { (sample, error) in
            
            guard let sample = sample else {
                
                if let error = error {
                    self.displayAlert(for: error)
                }
                return
            }
            
            let value = sample.quantity.doubleValue(for: self.heartRateUnit)
            //let value = sample.quantity.doubleValue(for: HKUnit.count())
            self.userHealthProfile.restingHeartRate = Int(value)
            print(value)
            completion()
        }
    }
    
    private func updateLabels() {
        print(userHealthProfile.age)
        
    }
    
    private func displayAlert(for error: Error) {
        
    
        
        let action = WKAlertAction(title: "OK",
                                      style: .default,
                                      handler: {
                                        
        })
        
        presentAlert(withTitle: nil, message: error.localizedDescription, preferredStyle: .alert, actions: [action])
    }
}

