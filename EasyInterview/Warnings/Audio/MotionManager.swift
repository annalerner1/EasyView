//
//  MotionManager.swift
//  EasyInterview
//
//  Created by Anna Lerner on 4/26/24.
//

import Foundation
import CoreMotion

class MotionManager: ObservableObject {
    
    let motion = CMMotionManager()
    private var timer = Timer()
    @Published var warning = false
    @Published var direWarning = false
    
    private var warningStart: Date?
    private var warningTimer = Timer()
    
    init() {
        startAccelerometersAndGyroscope()
        startWarningTimer()
    }
    
    func startAccelerometersAndGyroscope() {
        if self.motion.isAccelerometerAvailable && self.motion.isGyroAvailable {
            self.motion.accelerometerUpdateInterval = 0.5
            self.motion.startAccelerometerUpdates()
            
            self.motion.gyroUpdateInterval = 0.5
            self.motion.startGyroUpdates()
            
            
            self.timer = Timer(fire: Date(), interval: 0.5, repeats: true, block: { timer in
                if let accelerometerDate = self.motion.accelerometerData {
                    let x = accelerometerDate.acceleration.x
                    let y = accelerometerDate.acceleration.y
                    let z = accelerometerDate.acceleration.z

                    if x > 0.3 || y > 0.3 || z > 0.3 {
                        print("bad accelo rate")
                        self.warning = true
                    } else {
                        /*
                        if let gyroscopeDate = self.motion.gyroData {
                            let rotoRate = gyroscopeDate.rotationRate
                            // print("gyro data is: \(rotoRate)")

                            if rotoRate.x > 0.5 || rotoRate.y > 0.5 || rotoRate.z > 0.5 {
                                print("bad roto rate")
                                self.warning = true
                            } else {
                                self.warning = false
                            }
                        }
                        */
                        self.warning = false
                    }
                }
                

            })
            RunLoop.current.add(self.timer, forMode: .default)
        }
        
    }
    
    func startWarningTimer() {
        self.warningTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
            if self.warning {
                if self.warningStart == nil {
                    self.warningStart = Date()
                } else if let startTime = self.warningStart {
                    if Date().timeIntervalSince(startTime) >= 1.5 { // right now seeing if shaky for 2 secs
                        self.direWarning = true
                    }
                }
            } else {
                self.warningStart = nil
                self.direWarning = false
            }
        })
    }
    
    
    func stopAccelerometersAndGyroscope() {
        self.motion.stopGyroUpdates()
        self.motion.stopAccelerometerUpdates()
        self.timer.invalidate()
        self.warningTimer.invalidate()
    }
}
