//
//  GameScreenViewModel.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/15.
//

import Foundation
import CoreMotion
import Combine
import SwiftUI


// MARK: - Game Enums
enum GameState {
    case waiting
    case myTurn
    case enemyTurn
    case roundResult
    case gameOver
}

enum GameResult {
    case win
    case lose
    case tie
}

enum TurnResult {
    case blocked
    case missed
    case hit
    case tie
}

class GameScreenViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var punchDirection: PunchDirection?
    @Published var isMotionActive = false
    @Published var accelerationData: (x: Double, y: Double, z: Double) = (0, 0, 0)
    @Published var punchStrength: Double = 0
    @Published var cooldownProgress: Double = 0.0
    @Published var isInCooldown = false
    
    // MARK: - Game State Properties
    @Published var gameState: GameState = .waiting
    @Published var gameResult: GameResult?
    @Published var turnResult: TurnResult?
    @Published var currentRound = 1
    @Published var playerScore = 0
    @Published var enemyScore = 0
    @Published var isMyTurn = false
    @Published var showResetButton = false
    
    // MARK: - Private Properties
    private let motionManager = CMMotionManager()
    private var punchThreshold: Double = 2.0
    private var lastPunchTime: Date = Date()
    private let punchCooldown: TimeInterval = 3
    private var cancellables = Set<AnyCancellable>()
    private var cooldownTimer: Timer?
    
    // MARK: - Game Constants
    private let maxRounds = 3
    private let maxScore = 3
    
    // MARK: - TimeOut Properties
    private let timeOutInterval: TimeInterval = 5
    private var timeOutTimer: Timer?
    @Published var timeOutProgress: Double = 5
    
    private var mpcManager: MPCManager
    
    // MARK: - Initialization
    init(mpcManager: MPCManager) {
        self.mpcManager = mpcManager
        setupMotionManager()
        setupGameLogic()
    }
    
    deinit {
        stopAccelerometer()
        stopAllTimers()
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
        self.setupGameLogic()
    }
    
    // MARK: - Game Control Methods
    
    func startGame() {
        resetGame()
        gameState = .myTurn
        isMyTurn = true
        startTurnTimer()
    }
    
    func resetGame() {
        gameState = .waiting
        gameResult = nil
        turnResult = nil
        currentRound = 1
        playerScore = 0
        enemyScore = 0
        isMyTurn = false
        showResetButton = false
        punchDirection = nil
        punchStrength = 0
        stopAllTimers()
        mpcManager.clearEnemyPunch() // You'll need to implement this in MPCManager
    }
    
    // MARK: - Private Methods
    
    private func setupMotionManager() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer not available on this device")
            return
        }
    }
    
    private func setupGameLogic() {
        // Listen for enemy punches
        mpcManager.$enemyPunchDirection
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enemyPunch in
                guard let self = self, let enemyPunch = enemyPunch else { return }
                self.handleEnemyPunch(enemyPunch)
            }
            .store(in: &cancellables)
    }
    
    private func processAccelerometerData(_ data: CMAccelerometerData) {
        // Only process punches during player's turn
        guard gameState == .myTurn || gameState == .enemyTurn,
              !isInCooldown else {
            return
        }
        
        let acceleration = data.acceleration
        
        // Update published acceleration data
        accelerationData = (acceleration.x, acceleration.y, acceleration.z)
        
        // Calculate total acceleration magnitude
        let totalAcceleration = sqrt(
            acceleration.x * acceleration.x +
            acceleration.y * acceleration.y +
            acceleration.z * acceleration.z
        )
        
        // Check if punch threshold is exceeded
        guard totalAcceleration > punchThreshold else {
            return
        }
        
        // Determine punch direction and strength
        let direction = determinePunchDirection(from: acceleration)
        let strength = calculatePunchStrength(from: totalAcceleration)
        
        // Handle punch based on game state
        if gameState == .myTurn {
            handleMyPunch(direction: direction, strength: strength)
        } else if gameState == .enemyTurn {
            handleMyBlock(direction: direction, strength: strength)
        }
    }
    
    private func handleMyPunch(direction: PunchDirection, strength: Double) {
        punchDirection = direction
        punchStrength = strength
        lastPunchTime = Date()
        
        // Send punch to opponent
        mpcManager.send(punchDirection: direction)
        
        // Switch to enemy turn
        gameState = .enemyTurn
        isMyTurn = false
        stopTurnTimer()
        startTurnTimer() // Start timer for enemy to respond
        
        startCooldownTimer()
    }
    
    private func handleMyBlock(direction: PunchDirection, strength: Double) {
        guard let enemyPunch = mpcManager.enemyPunchDirection else { return }
        
        punchDirection = direction
        punchStrength = strength
        
        // Check if block is successful (opposite direction)
        let blockResult = evaluateBlock(enemyPunch: enemyPunch, myBlock: direction, myStrength: strength)
        
        processTurnResult(blockResult)
        startCooldownTimer()
    }
    
    private func handleEnemyPunch(_ enemyPunch: PunchDirection) {
        if gameState == .myTurn {
            // Enemy punched while it was my turn - they get the point
            processTurnResult(.missed)
        } else if gameState == .enemyTurn {
            // This is expected - enemy is responding to my punch
            startTurnTimer() // Give player time to block
        }
    }
    
    private func evaluateBlock(enemyPunch: PunchDirection, myBlock: PunchDirection, myStrength: Double) -> TurnResult {
        let requiredBlockDirection = getBlockDirection(for: enemyPunch)
        
        // Check if player blocked in correct direction
        guard myBlock.overlayPlacement == requiredBlockDirection.overlayPlacement else {
            return .hit // Wrong direction = enemy scores
        }
        
        // Compare strengths
        let enemyStrength = enemyPunch.strength
        if myStrength > enemyStrength {
            return .blocked // Successful block - player scores
        } else if myStrength < enemyStrength {
            return .hit // Weak block - enemy scores
        } else {
            return .tie // Equal strength - no score
        }
    }
    
    private func getBlockDirection(for enemyPunch: PunchDirection) -> PunchDirection {
        // Return opposite direction for blocking
        switch enemyPunch {
        case .left(let strength):
            return .right(strength: strength)
        case .right(let strength):
            return .left(strength: strength)
        case .up(let strength):
            return .down(strength: strength)
        case .down(let strength):
            return .up(strength: strength)
        }
    }
    
    private func processTurnResult(_ result: TurnResult) {
        turnResult = result
        gameState = .roundResult
        stopTurnTimer()
        
        // Update scores based on result
        switch result {
        case .blocked:
            playerScore += 1
        case .hit:
            enemyScore += 1
        case .missed:
            enemyScore += 1
        case .tie:
            break // No score change
        }
        
        // Check for game end conditions
        if playerScore >= maxScore || enemyScore >= maxScore {
            endGame()
        } else if currentRound >= maxRounds {
            endGame()
        } else {
            // Continue to next round
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.startNextRound()
            }
        }
    }
    
    private func startNextRound() {
        currentRound += 1
        turnResult = nil
        punchDirection = nil
        punchStrength = 0
        
        // Alternate who starts (or implement your preferred logic)
        isMyTurn = !isMyTurn
        gameState = isMyTurn ? .myTurn : .enemyTurn
        
        if isMyTurn {
            startTurnTimer()
        }
    }
    
    private func endGame() {
        gameState = .gameOver
        stopAllTimers()
        
        // Determine final result
        if playerScore > enemyScore {
            gameResult = .win
        } else if playerScore < enemyScore {
            gameResult = .lose
        } else {
            gameResult = .tie
        }
        
        showResetButton = true
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
            // Default to down for forward/backward movement
            return .down(strength: strength)
        }
    }
    
    private func calculatePunchStrength(from totalAcceleration: Double) -> Double {
        // Normalize strength between 0 and 1000
        let normalizedStrength = min(1000, max(0, (totalAcceleration - 1.0) * 200))
        return normalizedStrength
    }
    
    // MARK: - Timer Methods
    
    private func startTurnTimer() {
        timeOutProgress = timeOutInterval
        
        timeOutTimer?.invalidate()
        timeOutTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.timeOutProgress -= 1
            
            if self.timeOutProgress <= 0 {
                self.handleTurnTimeout()
            }
        }
    }
    
    private func stopTurnTimer() {
        timeOutTimer?.invalidate()
        timeOutTimer = nil
        timeOutProgress = timeOutInterval
    }
    
    private func handleTurnTimeout() {
        stopTurnTimer()
        
        if gameState == .myTurn {
            // Player failed to punch - enemy gets point
            processTurnResult(.missed)
        } else if gameState == .enemyTurn {
            // Player failed to block - enemy gets point
            processTurnResult(.hit)
        }
    }
    
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
                self.cooldownProgress = (remainingCooldown / self.punchCooldown) * 3
            }
        }
    }
    
    private func stopCooldownTimer() {
        cooldownTimer?.invalidate()
        cooldownTimer = nil
        isInCooldown = false
        cooldownProgress = 0.0
    }
    
    private func stopAllTimers() {
        stopTurnTimer()
        stopCooldownTimer()
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
    
    // MARK: - Debug Methods
    
    func getMotionStatus() -> String {
        return """
        Motion Active: \(isMotionActive)
        Accelerometer Available: \(motionManager.isAccelerometerAvailable)
        Current Acceleration: x=\(String(format: "%.2f", accelerationData.x)), y=\(String(format: "%.2f", accelerationData.y)), z=\(String(format: "%.2f", accelerationData.z))
        Punch Threshold: \(punchThreshold)
        Current Punch Strength: \(String(format: "%.2f", punchStrength))
        Game State: \(gameState)
        Round: \(currentRound)/\(maxRounds)
        Score: Player \(playerScore) - \(enemyScore) Enemy
        """
    }
    
    // MARK: - Game Status Methods
    
    func getGameStatusMessage() -> String {
        switch gameState {
        case .waiting:
            return "Waiting to start game..."
        case .myTurn:
            return "Your turn! Punch to attack!"
        case .enemyTurn:
            return "Enemy's turn! Block their punch!"
        case .roundResult:
            guard let result = turnResult else { return "Processing..." }
            switch result {
            case .blocked:
                return "Great block! You scored!"
            case .hit:
                return "Enemy hit! They scored!"
            case .missed:
                return "Missed! Enemy scored!"
            case .tie:
                return "Tie! Same strength!"
            }
        case .gameOver:
            guard let result = gameResult else { return "Game over!" }
            switch result {
            case .win:
                return "You won! 🎉"
            case .lose:
                return "You lost! 😔"
            case .tie:
                return "It's a tie! 🤝"
            }
        }
    }
}
