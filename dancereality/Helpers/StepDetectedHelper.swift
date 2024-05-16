//
//  StepDetectedHelper.swift
//  dancereality
//
//  Created by Saad Bin Khalid on 12.07.23.
//

import Foundation
import CoreMotion

class StepDetectedHelper {
    let motionManager = CMMotionManager()
    let updateInterval = 0.1 // Update interval in seconds
    let accelerationThreshold = 1.1 // Acceleration threshold for step detection
    let completion : ()->()
    var accelerationSamples = [Double]()
    var window: Double
    let pedometer: CMPedometer = CMPedometer()
    var timer: Timer?
    let now = Date()
    
    init (window: Double, completion: @escaping ()->()){
        self.completion = completion
        self.window = window
        startDetection()
        //startPedometer()
    }
    
    private func startDetection() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = updateInterval
            motionManager.startAccelerometerUpdates(to: .main) { (accelerometerData, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else if let accelerometerData = accelerometerData {
                    let acceleration = sqrt(pow(accelerometerData.acceleration.x, 2) +
                                            pow(accelerometerData.acceleration.y, 2) +
                                            pow(accelerometerData.acceleration.z, 2))
                    self.processAccelerationData(acceleration)
                }
            }
        } else {
            print("Accelerometer is not available on this device.")
        }
    }
    
    private func startPedometer (){
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let oneSecondAgo = Date()
            self.fetchStepCount(dateFrom: self.now, dateTo: oneSecondAgo)
        }
    }
    
    private func fetchStepCount(dateFrom: Date, dateTo: Date) {
        if CMPedometer.isStepCountingAvailable() {
            pedometer.queryPedometerData(from: dateFrom, to: dateTo) { (pedometerData, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else if let pedometerData = pedometerData {
                    if(pedometerData.numberOfSteps.intValue != 0){
                        print("Footstep detected!")
                        DispatchQueue.main.async {
                            self.completion()
                            self.timer?.invalidate()
                        }
                    }
                }
            }
        } else {
            print("Step counting is not available on this device.")
        }
        
    }
    
    public func stopDetection() {
        motionManager.stopAccelerometerUpdates()
        accelerationSamples.removeAll()
        if let timer = self.timer {
            timer.invalidate()
        }
    }
    
    private func processAccelerationData(_ acceleration: Double) {
        accelerationSamples.append(acceleration)
        // Keep the acceleration sample window size to a certain number of samples (e.g., 50)
        let sampleWindowSize = Int(self.window)
        if accelerationSamples.count > sampleWindowSize {
            accelerationSamples.removeFirst(accelerationSamples.count - sampleWindowSize)
        }
        // Check if the latest acceleration peak exceeds the threshold and is larger than the previous sample
        if let currentPeak = accelerationSamples.last,
           let previousPeak = accelerationSamples.dropLast().max(),
           currentPeak > accelerationThreshold && currentPeak > previousPeak {
            print("Footstep detected!")
            self.completion()
            self.stopDetection()
        }
    }
}
