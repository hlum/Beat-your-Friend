//
//  MPCManager.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/11.
//

import Foundation
import SwiftUI
import MultipeerConnectivity


enum MessageType: String, Codable {
    case punch
    case health
    case score
}

struct GameMessage: Codable {
    let type: MessageType
    let payload: Data
}


// MARK: - Updated MPCManager with ObservableObject properties
class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, ObservableObject {
    let serviceType = "beatyourfriend"  // Changed: lowercase, no special characters
    var peerID = MCPeerID(displayName:UIDevice.current.name)
    
    var session: MCSession!
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    
    // Published properties for UI updates
    @Published var connectedPeers: [MCPeerID] = []
    @Published var availablePeers: [MCPeerID] = []
    @Published var receivedMessages: [String] = []
    @Published var connectionStatus: String = "Disconnected"
    @Published var connectionState: ConnectionState = .notConnected
    @Published var isAdvertising: Bool = false
    @Published var isBrowsing: Bool = false
    
    @Published var showInvitationPrompt: Bool = false
    @Published var pendingInvitation: (peerID: MCPeerID, handler: (Bool, MCSession?) -> Void)?
    
    @Published var enemyPunchDirection: PunchDirection?
    @Published var enemyHealth: Double = 100

    
    override init() {
        super.init()
    }
    
    func setDisplayName(_ displayName: String) {
        self.peerID = MCPeerID(displayName: displayName)
        // Recreate services with the new peerID if they were already set up
        if session != nil {
            restartServices()
        }
    }
    
    private func setupServices() {
        print("🔧 Setting up MPC services with peerID: \(peerID.displayName)")
        
        // For session
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .optional)
        session.delegate = self
        print("✅ Session created")
        
        
        // For advertiser
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
        print("✅ Advertiser created")
        
        // For Browser
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser.delegate = self
        print("✅ Browser created")
    }
        
    func startAllServices() {
        restartServices()
                
        // Start advertising
        startAdvertising()
        
        // Start browsing
        startBrowsing()
    }
    
    
    func startBrowsing() {
        browser.startBrowsingForPeers()
        isBrowsing = true
        print("Started browsing for peers with service type: \(serviceType)")
    }
    
    
    func startAdvertising() {
        advertiser.startAdvertisingPeer()
        isAdvertising = true
        print("Started advertising with service type: \(serviceType)")
    }
    
    private func stopServices() {
        
        if isAdvertising {
            advertiser.stopAdvertisingPeer()
            isAdvertising = false
            print("Stopped advertising")
        }
        
        if isBrowsing {
            browser.stopBrowsingForPeers()
            isBrowsing = false
            print("Stopped browsing")
        }
        
        if let session {
            session.disconnect()
        }
    }
    
    private func restartServices() {
        stopServices() // Stop any existing services first
        
        self.setupServices()

    }
    
    // MARK: - MCSessionDelegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("✅ Connected to \(peerID.displayName)")
                self.connectionStatus = "Connected to \(peerID.displayName)"
                self.connectionState = .connected

                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
            case .connecting:
                print("🔄 Connecting to \(peerID.displayName)")
                self.connectionStatus = "Connecting to \(peerID.displayName)"
                self.connectionState = .connecting
            case .notConnected:
                print("❌ Disconnected from \(peerID.displayName)")
                self.connectionStatus = "Disconnected"
                self.connectionState = .notConnected
                self.connectedPeers.removeAll { $0 == peerID }
            @unknown default:
                print("❓ Unknown state for \(peerID.displayName)")
                self.connectionState = .unknown
                self.connectionStatus = "Unknown state"
            }
            
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {

            guard let gameMessage = self.decodeGameMessage(from: data) else {
                print("Fail to decode game message")
                return
            }
            
            switch gameMessage.type {
            case .punch:
                self.enemyPunchDirection = self.decodePunchDirection(from: gameMessage.payload)
            case .health:
                let health = gameMessage.payload.withUnsafeBytes { $0.load(as: Double.self) }
                self.enemyHealth = health
                print("Enemy health updated: \(health)")
            case .score:
                // TODO: -
                return
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
        
    }
    
    // MARK: - MCNearbyServiceAdvertiserDelegate
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            print("招待を受けました from \(peerID.displayName)")
            // Auto-accept invitations for this demo
            self.pendingInvitation = (peerID, invitationHandler)
            self.showInvitationPrompt = true
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        DispatchQueue.main.async {
            print("Failed to start advertising: \(error.localizedDescription)")
            self.connectionStatus = "Advertising failed: \(error.localizedDescription)"
            self.isAdvertising = false
        }
    }
    
    // MARK: - MCNearbyServiceBrowserDelegate
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            print("Found peer: \(peerID.displayName)")
            if !self.availablePeers.contains(peerID) && peerID != self.peerID {
                self.availablePeers.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            print("Lost peer: \(peerID.displayName)")
            self.availablePeers.removeAll { $0 == peerID }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        DispatchQueue.main.async {
            print("Failed to start browsing: \(error.localizedDescription)")
            self.connectionStatus = "Browsing failed: \(error.localizedDescription)"
            self.isBrowsing = false
        }
    }
    
    // MARK: - Helper Methods
    func invitePeer(_ peerID: MCPeerID) {
        print("招待を送信する to \(peerID.displayName)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func send(punchDirection: PunchDirection) {
        print("🔍 Attempting to send punch: \(punchDirection)")
        print("🔍 Session exists: \(session != nil)")
        print("🔍 Connected peers count: \(session?.connectedPeers.count ?? 0)")
        
        guard self.session != nil else {
            print("❌ No session found")
            return
        }
        
        if session.connectedPeers.count > 0 {
            if let punchData = encodePunchDirection(punchDirection) {
                do {
                    let gameMessage = GameMessage(type: .punch, payload: punchData)
                    
                    guard let data = encodeGameMessage(gameMessage) else {
                        print("Failed to encode game message")
                        return
                    }
                    
                    try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                    print("✅ Successfully sent punch data")
                } catch {
                    print("❌ Failed to send punch data: \(error)")
                }
            } else {
                print("❌ Failed to encode punch direction")
            }
        } else {
            print("❌ No connected peers to send to")
        }
    }
    
    func send(playerHealth: Double) {
        print("Player health sent")
        guard self.session != nil else {
            print("No session found")
            return
        }
        
            
        guard session.connectedPeers.count > 0 else {
            print("no connected peers to send to")
            return
        }
        
        do {
            let healthData = withUnsafeBytes(of: playerHealth) { Data($0) }
            let gameMessage = GameMessage(type: .health, payload: healthData)
            guard let data = try encodeGameMessage(gameMessage) else {
                print("Error encoding game message")
                return
            }
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending player health: \(error.localizedDescription)")
        }
    }
    
    func disconnect() {
        session.disconnect()
        connectedPeers.removeAll()
        connectionStatus = "Disconnected"
    }
    
    func encodeGameMessage(_ message: GameMessage) -> Data? {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(message)
            return data
        } catch {
            print("Failed to encode GameMessage: \(error)")
            return nil
        }
    }
    
    
    func decodeGameMessage(from data: Data) -> GameMessage? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(GameMessage.self, from: data)
        } catch {
            print("Failed to decode: \(error)")
            return nil
        }
    }
    
    func encodePunchDirection(_ punchDirection: PunchDirection) -> Data? {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(punchDirection)
            return data
        } catch {
            print("Failed to encode PunchDirection: \(error)")
            return nil
        }
    }

    
    func decodePunchDirection(from data: Data) -> PunchDirection? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(PunchDirection.self, from: data)
        } catch {
            print("Failed to decode: \(error)")
            return nil
        }
    }
}
