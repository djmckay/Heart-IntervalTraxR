//
//  ViewController.swift
//  Heart IntervalTraxR
//
//  Created by DJ McKay on 12/3/17.
//  Copyright © 2017 DJ McKay. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController {

    @IBOutlet private weak var heartRateLabel: UILabel!
    @IBOutlet private weak var deviceLabel : UILabel!
    @IBOutlet private weak var heart: UIImage!
    @IBOutlet private weak var startButton : UIButton!
    @IBOutlet private weak var stopButton : UIButton!

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var maxRangeLabel: UILabel!
    @IBOutlet weak var minRangeLabel: UILabel!

    @IBOutlet weak var durationLabel: UILabel!

    var heartIntervalController: HeartIntervalController = HeartIntervalController.sharedInstance
    let watchManager: WatchManager = WatchManager.sharedInstance
    var timer: Timer?
    var duration: TimeInterval?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.authorize()
        self.watchManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func startBtnTapped() {
        self.startStop()
    }
    
}

extension ViewController: HeartIntervalDelegate {
    func sessionEnded() {
        
    }
    
    func sessionStarted() {
        self.startButton.isHidden = true
        self.stopButton.isHidden = false
    }
    
    func updateHeartRate(_ heartRate: Int16) {
        DispatchQueue.main.async {
            self.heartRateLabel.text = (String(heartRate))
            self.animateHeart()
        }
        
    }
    
    func updateDeviceName(_ name: String) {
        //deviceLabel.setText(name)
    }
    
    func timerNotStarted() {
        heartRateLabel .text = ("cannot start")
    }
    
    func authorized() {
        self.startButton.isEnabled = true
    }
    
    func notAuthorized() {
        self.displayNotAllowed()
    }
    
    func timerStarting(_ duration: TimeInterval) {
        
        
    }
    
    func timerStopping() {
        self.startButton.isHidden = false
        self.stopButton.isHidden = true
    }
    
   
    
}

extension ViewController: InterfaceControllerProtocol {
    
    func startStop() {
        heartIntervalController.startStop()
        
    }
    
    func authorize() {
        self.startButton.isEnabled = false
        self.timerStopping()
        heartIntervalController.delegate = self
        heartIntervalController.authorizeHealthKit()
    }
    
    
    func displayNotAllowed() {
        heartRateLabel.text = ("not allowed")
    }
    
    func animateHeart() {
//        self.animate(withDuration: 0.5) {
//            self.heart.setWidth(12)
//            self.heart.setHeight(12)
//        }
//        
//        let when = DispatchTime.now() + Double(Int64(0.5 * double_t(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//        
//        DispatchQueue.global(qos: .default).async {
//            DispatchQueue.main.asyncAfter(deadline: when) {
//                self.animate(withDuration: 0.5, animations: {
//                    self.heart.setWidth(10)
//                    self.heart.setHeight(10)
//                })
//                
//            }
//            
//            
//        }
    }
    

}

extension ViewController: WatchConnectorDelegate {
    func didReceiveMessage(message: [String : Any]) {
        print(message)
        for state in message {
//            if let value = state.value as? String {
//                self.statusLabel.text = self.statusLabel.text! + value
//            } else {
//                self.statusLabel.text = self.statusLabel.text! + "?"
//            }
            if state.key == "HR" {
                self.heartRateLabel.text = state.value as! String
            }
            if state.key == "TimerStarted" {
                if (state.value as! Bool) {
                    self.statusLabel.text = "Timer Started"
                    
                }
            }
            if state.key == "Session" {
                if (state.value as! Bool) {
                    self.statusLabel.text = "Session Started"
                } else if !(state.value as! Bool) {
                    self.statusLabel.text = "Session Ended"
                }
            }
            if state.key == "TimerStopped" {
                if (state.value as! Bool) {
                    self.statusLabel.text = "Timer Stopped"
                    self.timer?.invalidate()
                }
            }
            if state.key == "TimerDuration" {
                if let duration = state.value as? TimeInterval {
                    self.durationLabel.text = duration.description
                    self.duration = duration
                    DispatchQueue.main.async {
                        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                            self.duration! -= 1.0
                            self.durationLabel.text = self.duration!.description
                        }
                    }
                }
            }
            if state.key == "RangeMax" {
                if let upper = state.value as? Int {
                    self.maxRangeLabel.text = upper.description
                }
            }
            if state.key == "RangeMin" {
                if let lower = state.value as? Int {
                    self.minRangeLabel.text = lower.description
                }
            }
        }
    }
    
    
}

