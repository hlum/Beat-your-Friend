//
//  GameScreenViewModel.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/15.
//

import SwiftUI
import CoreMotion
import Combine


class GameScreenViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var punchDirection: PunchDirection? = .up(strength: 100)
    @Published var isMotionActive = false
    @Published var accelerationData: (x: Double, y: Double, z: Double) = (0, 0, 0)
    @Published var punchStrength: Double = 0
    @Published var cooldownProgress: Double = 0.0
    @Published var isInCooldown = false

    
    // MARK: - Private Properties
    private let motionManager = CMMotionManager()
    private var punchThreshold: Double = 2.0
    private var lastPunchTime: Date = Date()
    private let punchCooldown: TimeInterval = 3
    private var cancellables = Set<AnyCancellable>()
    private var cooldownTimer: Timer?

    @Published var playerHealth: Double = 100
    @Published var enemyHealth: Double = 100

    private var mpcManager: MPCManager
    
    // MARK: - Initialization
    init(mpcManager: MPCManager) {
        self.mpcManager = mpcManager
        setupMotionManager()
    }
    
    deinit {
        stopAccelerometer()
    }
    
    // MARK: - Public Methods
    
    func startAccelerometer() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer not available")
            return
        }
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let self = self, let data = data else { return }
            
            self.processAccelerometerData(data)
        }
        
        isMotionActive = true
    }
    
    func stopAccelerometer() {
        motionManager.stopAccelerometerUpdates()
        isMotionActive = false
    }
    
    func setPunchThreshold(_ threshold: Double) {
        punchThreshold = max(0.5, min(5.0, threshold))
    }
    
    func resetPunchDirection() {
        punchDirection = nil
        punchStrength = 0
    }
    
    func updateMPCManager(_ newMPCManager: MPCManager) {
        self.mpcManager = newMPCManager
    }
    
    // MARK: - Private Methods
    
    private func setupMotionManager() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer not available on this device")
            return
        }
    }
    
    private func processAccelerometerData(_ data: CMAccelerometerData) {
        let acceleration = data.acceleration
        
        // Update published acceleration data
        accelerationData = (acceleration.x, acceleration.y, acceleration.z)
        
        // Calculate total acceleration magnitude
        let totalAcceleration = sqrt(
            acceleration.x * acceleration.x +
            acceleration.y * acceleration.y +
            acceleration.z * acceleration.z
        )
        
        // Check if punch threshold is exceeded and cooldown period has passed
        let currentTime = Date()
        guard totalAcceleration > punchThreshold,
              !isInCooldown else {
            return
        }
        
        // Determine punch direction and strength
        let direction = determinePunchDirection(from: acceleration)
        let strength = calculatePunchStrength(from: totalAcceleration)
        
        // Update punch data
        punchDirection = direction
        mpcManager.send(punchDirection: direction)
        punchStrength = strength
        lastPunchTime = currentTime
        startCooldownTimer()
//        // Auto-reset after animation time
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
//            self?.resetPunchDirection()
//        }
    }
    
    private func determinePunchDirection(from acceleration: CMAcceleration) -> PunchDirection {
        let strength = calculatePunchStrength(from: sqrt(
            acceleration.x * acceleration.x +
            acceleration.y * acceleration.y +
            acceleration.z * acceleration.z
        ))
        
        // Determine primary direction based on largest acceleration component
        let absX = abs(acceleration.x)
        let absY = abs(acceleration.y)
        let absZ = abs(acceleration.z)
        
        if absY > absX && absY > absZ {
            // Vertical movement
            return acceleration.y > 0 ? .down(strength: strength) : .up(strength: strength)
        } else if absX > absZ {
            // Horizontal movement
            return acceleration.x > 0 ? .left(strength: strength) : .right(strength: strength)
        } else {
            // Forward/backward movement (using Z-axis)
//            return acceleration.z > 0 ? .up(strength: strength) : .down(strength: strength)
            return .down(strength: 0)
        }
    }
    
    private func calculatePunchStrength(from totalAcceleration: Double) -> Double {
        // Normalize strength between 0 and 1000
        let normalizedStrength = min(1000, max(0, (totalAcceleration - 1.0) * 200))
        return normalizedStrength
    }
    
    // MARK: - Calibration Methods
    
    func calibrateAccelerometer() {
        var calibrationSamples: [CMAcceleration] = []
        let calibrationDuration: TimeInterval = 3.0
        let startTime = Date()
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let self = self, let data = data else { return }
            
            calibrationSamples.append(data.acceleration)
            
            if Date().timeIntervalSince(startTime) >= calibrationDuration {
                self.finishCalibration(with: calibrationSamples)
            }
        }
    }
    
    private func finishCalibration(with samples: [CMAcceleration]) {
        guard !samples.isEmpty else { return }
        
        // Calculate average acceleration during calibration
        let avgAcceleration = samples.reduce((x: 0.0, y: 0.0, z: 0.0)) { result, sample in
            (result.x + sample.x, result.y + sample.y, result.z + sample.z)
        }
        
        let count = Double(samples.count)
        let baselineAcceleration = sqrt(
            pow(avgAcceleration.x / count, 2) +
            pow(avgAcceleration.y / count, 2) +
            pow(avgAcceleration.z / count, 2)
        )
        
        // Adjust threshold based on baseline
        setPunchThreshold(baselineAcceleration + 1.5)
        
        // Restart normal accelerometer updates
        startAccelerometer()
    }
    
    // MARK: - Cooldown Methods
    
    private func startCooldownTimer() {
        isInCooldown = true
        cooldownProgress = 1.0
        
        cooldownTimer?.invalidate()
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let currentTime = Date()
            let timeSinceLastPunch = currentTime.timeIntervalSince(self.lastPunchTime)
            let remainingCooldown = self.punchCooldown - timeSinceLastPunch
            
            if remainingCooldown <= 0 {
                self.stopCooldownTimer()
            } else {
                self.cooldownProgress = remainingCooldown / self.punchCooldown
            }
        }
    }
    
    private func stopCooldownTimer() {
        cooldownTimer?.invalidate()
        cooldownTimer = nil
        isInCooldown = false
        cooldownProgress = 0.0
    }
    
    
    // MARK: - Debug Methods
    
    func getMotionStatus() -> String {
        return """
        Motion Active: \(isMotionActive)
        Accelerometer Available: \(motionManager.isAccelerometerAvailable)
        Current Acceleration: x=\(String(format: "%.2f", accelerationData.x)), y=\(String(format: "%.2f", accelerationData.y)), z=\(String(format: "%.2f", accelerationData.z))
        Punch Threshold: \(punchThreshold)
        Current Punch Strength: \(String(format: "%.2f", punchStrength))
        """
    }
}
