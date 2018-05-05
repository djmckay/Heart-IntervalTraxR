//
//  ConfigureDurationController.swift
//  Heart IntervalTraxR WatchKit Extension
//
//  Created by DJ McKay on 12/6/17.
//  Copyright © 2017 DJ McKay. All rights reserved.
//

import UIKit
import WatchKit

class ConfigureDurationController: WKInterfaceController {

    @IBOutlet var timeSlider: WKInterfaceSlider!
    
    @IBOutlet var doneButton : WKInterfaceButton!
    @IBOutlet weak var watchTimer: WKInterfaceTimer!

    var heartIntervalController: HeartIntervalController = HeartIntervalController.sharedInstance

    
    @IBAction func zoneSliderDidChange(_ value: Float) {
        var time = value
        time = time.rounded()
        print(time)
        self.watchTimer.setDate(Date(timeIntervalSinceNow: Double(time) + 1.0))
        self.heartIntervalController.duration = Double(time) 
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print(self.heartIntervalController.duration.rounded())
        self.watchTimer.setDate(Date(timeIntervalSinceNow: self.heartIntervalController.duration.rounded() + 1.0))
        print(Float(self.heartIntervalController.duration.rounded()))
        self.timeSlider.setValue(Float(self.heartIntervalController.duration.rounded()))
    }
}
