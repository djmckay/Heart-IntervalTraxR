//
//  UserHealthProfile.swift
//  Heart IntervalTraxR WatchKit Extension
//
//  Created by DJ McKay on 12/5/17.
//  Copyright © 2017 DJ McKay. All rights reserved.
//

import HealthKit

public enum ZoneType:Int {
    case Fatburning=0, Fitness=1, AroebicAnaroebic = 2, Anaroebic = 3
    
    var name: String {
        get {
            switch self {
            case .Anaroebic:
                return "Anaroebic"
            case .Fatburning:
                return "Fatburning"
            case .Fitness:
                return "Fitness"
            case .AroebicAnaroebic:
                return "Aerobic-Anaerobic"
            }
        }
    }
}

class UserHealthProfile {
    
    var age: Int?
    var biologicalSex: HKBiologicalSex?
    var bloodType: HKBloodType?
    var heightInMeters: Double?
    var weightInKilograms: Double?
    var restingHeartRate: Int?
    
    var bodyMassIndex: Double? {
        
        guard let weightInKilograms = weightInKilograms,
            let heightInMeters = heightInMeters,
            heightInMeters > 0 else {
                return nil
        }
        
        return (weightInKilograms/(heightInMeters*heightInMeters))
    }
    
    var heartRateReserve: Int {
        get {
            var base = maxHeartRate
            if let restingHeartRate = self.restingHeartRate {
                base = base - restingHeartRate
            }
            return base
        }
    }
    
    var maxHeartRate: Int {
        get {
            var base = 220
            if let age = self.age {
                base = base - age
            }
            return base
        }
    }

    func getRange(for zone: ZoneType) -> (lower: Int, upper: Int) {
        switch zone {
        case .Fatburning:
            return aerobicFatBuring()
        case .Fitness:
            return aerobicFitness()
        case .AroebicAnaroebic:
            return aerobicAnaerobic()
        case .Anaroebic:
            return anaerobic()
        }
    }
    
    fileprivate func aerobicFatBuring() -> (lower: Int, upper: Int) {
        let lowerRangePercent = 50.0
        let upperRangePercent = 75.0
        return self.calculateRange(lower: lowerRangePercent, upper: upperRangePercent)
    }
    
    fileprivate func aerobicFitness() -> (lower: Int, upper: Int) {
        let lowerRangePercent = 75.0
        let upperRangePercent = 85.0
        return self.calculateRange(lower: lowerRangePercent, upper: upperRangePercent)
    }
    
    fileprivate func aerobicAnaerobic () -> (lower: Int, upper: Int) {
        let lowerRangePercent = 85.0
        let upperRangePercent = 90.0
        return self.calculateRange(lower: lowerRangePercent, upper: upperRangePercent)
    }
    
    fileprivate func anaerobic () -> (lower: Int, upper: Int) {
        let lowerRangePercent = 90.0
        let upperRangePercent = 100.0
        return self.calculateRange(lower: lowerRangePercent, upper: upperRangePercent)
    }
    
    fileprivate func calculateRange(lower: Double, upper: Double) -> (lower: Int, upper: Int) {
        return (Int(Double(heartRateReserve) * lower / 100) + (restingHeartRate ?? 0), Int (Double(heartRateReserve) * upper / 100) + (restingHeartRate ?? 0))
        
    }
}

