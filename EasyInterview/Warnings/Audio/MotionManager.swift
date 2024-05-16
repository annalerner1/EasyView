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
    @Published var warning = false // need to modify this if problem with data
    
    init() {
        startAccelerometersAndGyroscope()
    }
    
    func startAccelerometersAndGyroscope() {
        if self.motion.isAccelerometerAvailable && self.motion.isGyroAvailable {
            self.motion.accelerometerUpdateInterval = 0.25 // right now checkign every 0.25 second
            self.motion.startAccelerometerUpdates()
            
            self.motion.gyroUpdateInterval = 0.25 // checking the gyroscope every 0.25 seconds
            self.motion.startGyroUpdates()
            
            
            self.timer = Timer(fire: Date(), interval: 0.25, repeats: true, block: { timer in
                if let accelerometerDate = self.motion.accelerometerData {
                    let x = accelerometerDate.acceleration.x
                    let y = accelerometerDate.acceleration.y
                    let z = accelerometerDate.acceleration.z

                    // print("acclo data is x: \(x), y: \(y), z: \(z)")
                    if x > 0.25 || y > 0.25 || z > 0.25 {
                        print("bad accelo rate")
                        self.warning = true
                    } else {
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
                        // self.warning = false
                    }
                }
                

            })
            RunLoop.current.add(self.timer, forMode: .default)
        }
        
    }
    func stopAccelerometersAndGyroscope() {
        self.motion.stopGyroUpdates()
        self.motion.stopAccelerometerUpdates()
    }
}
