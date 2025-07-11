//
//  MPCManager.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/11.
//

import Foundation
import MultipeerConnectivity

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
    @Published var connectionState: String = "Disconnected"
    @Published var isAdvertising: Bool = false
    @Published var isBrowsing: Bool = false
    
    override init() {
        super.init()
        
        
    }
    
    func setPeerId(_ displayName: String) {
        self.peerID = MCPeerID(displayName: displayName)
    }
    
    func setupServices() {
        print(peerID.displayName)
        // For advertiser
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
        
        // For Browser
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser.delegate = self
        
        startServices()
    }
    
    func startServices() {
        stopServices() // Stop any existing services first
        
        
        // For session
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .optional)
        session.delegate = self

        
        // Start advertising
        advertiser.startAdvertisingPeer()
        isAdvertising = true
        print("Started advertising with service type: \(serviceType)")
        
        // Start browsing
        browser.startBrowsingForPeers()
        isBrowsing = true
        print("Started browsing for peers with service type: \(serviceType)")
    }
    
    func stopServices() {
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
    }
    
    func restartServices() {
        stopServices()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.startServices()
        }
    }
    
    // MARK: - MCSessionDelegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("✅ Connected to \(peerID.displayName)")
                self.connectionState = "Connected to \(peerID.displayName)"
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
            case .connecting:
                print("🔄 Connecting to \(peerID.displayName)")
                self.connectionState = "Connecting to \(peerID.displayName)"
            case .notConnected:
                print("❌ Disconnected from \(peerID.displayName)")
                self.connectionState = "Disconnected"
                self.connectedPeers.removeAll { $0 == peerID }
            @unknown default:
                print("❓ Unknown state for \(peerID.displayName)")
                self.connectionState = "Unknown state"
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            if let message = String(data: data, encoding: .utf8) {
                print("Received data: \(message)")
                self.receivedMessages.append("From \(peerID.displayName): \(message)")
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
            invitationHandler(true, self.session)
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        DispatchQueue.main.async {
            print("Failed to start advertising: \(error.localizedDescription)")
            self.connectionState = "Advertising failed: \(error.localizedDescription)"
            self.isAdvertising = false
        }
    }
    
    // MARK: - MCNearbyServiceBrowserDelegate
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            print("Found peer: \(peerID.displayName)")
            if !self.availablePeers.contains(peerID) {
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
            self.connectionState = "Browsing failed: \(error.localizedDescription)"
            self.isBrowsing = false
        }
    }
    
    // MARK: - Helper Methods
    func invitePeer(_ peerID: MCPeerID) {
        print("招待を送信する to \(peerID.displayName)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func send(message: String) {
        if session.connectedPeers.count > 0 {
            if let data = message.data(using: .utf8) {
                try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
            }
        }
    }
    
    func disconnect() {
        session.disconnect()
        connectedPeers.removeAll()
        connectionState = "Disconnected"
    }
}
