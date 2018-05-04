//
//  HealthKitManager.swift
//  Heart IntervalTraxR WatchKit Extension
//
//  Created by DJ McKay on 12/3/17.
//  Copyright © 2017 DJ McKay. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitManager {
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    var authorized: Bool {
        get {
            return UserDefaultsManager.HKAuthorized
        }
        set {
            UserDefaultsManager.HKAuthorized = newValue
        }
    }
    
    static let sharedInstance: HealthKitManager = {
        let instance = HealthKitManager()
        // setup code
        return instance
    }()
    
    func authorizeHealthKit(completion: ((_ success:Bool, _ error:NSError?) -> Void)!)
    {
        
        if self.authorized {
            completion(self.authorized, nil)
            return
        }
//        guard HKHealthStore.isHealthDataAvailable() == true else {
//            label.setText("not available")
//            return
//        }
//
//        guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
//            displayNotAllowed()
//            return
//        }
//
//        let dataTypes = Set(arrayLiteral: quantityType)
//        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, error) -> Void in
//            if success == false {
//                self.displayNotAllowed()
//            }
//        }
        
        // 1. Set the types you want to read from HK Store
        guard   let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
            let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
            let height = HKObjectType.quantityType(forIdentifier: .height),
            let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let restingHeartRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate),
            let heartRate = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
                completion(false, nil)
                return
        }
            
        let healthKitTypesToRead = Set(arrayLiteral: dateOfBirth,
                                       biologicalSex,
                                       bodyMassIndex,
                                       height,
                                       bodyMass, restingHeartRate,
                                    heartRate
        )
        // 2. Set the types you want to write to HK Store
        let healthKitTypesToWrite = Set<HKSampleType>()
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "com.jeanoelyse.HeartIntervalTraxR", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(false, error)
            }
            return
        }
        
        // 4.  Request HealthKit authorization
        healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) -> Void in
            self.authorized = success

            if( completion != nil )
            {
                if let error = error as NSError? {
                    completion(success, error)
                }
                completion(success, nil)
            }
        }
    }
    
    func execute(query: HKQuery) {
        healthKitStore.execute(query)
    }
    
    func stop(query: HKQuery) {
        healthKitStore.stop(query)
    }
    
    func createHeartRateStreamingQuery(_ workoutStartDate: Date?, _ handler: @escaping (_ sample: HKQuantitySample) -> ()) -> HKQuery? {
        
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else { return nil }
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate )
        //let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])
        
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            //guard let newAnchor = newAnchor else {return}
            //self.anchor = newAnchor
            self.updateHeartRate(sampleObjects, handler)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            //self.anchor = newAnchor!
            self.updateHeartRate(samples, handler)
        }
        return heartRateQuery
    }
    
    
    func updateHeartRate(_ samples: [HKSample]?, _ handler: (_ sample: HKQuantitySample) -> ()) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
        
        guard let sample = heartRateSamples.first else{return}

        handler(sample)
        
    }
}
