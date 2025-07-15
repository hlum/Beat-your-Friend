//
//  ContentView.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/11.
//

//import SwiftUI
//
//// MARK: - Main App View
//struct ContentView: View {
//    @StateObject private var mpcManager = MPCManager()
//    @State private var messageText = ""
//    @State private var showingAlert = false
//    @State private var alertMessage = ""
//    @State private var displayName: String = ""
//    
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 20) {
//                    // Status Section
//                    VStack(alignment: .leading, spacing: 10) {
//                        
//                        TextField("Enter your message...", text: $displayName)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                        
//                        
//                        Button(action: {
////                                mpcManager.setDisplayName(displayName)
////                                mpcManager.setupServices()
//                            
//                        }) {
//                            Text("Set DisplayName")
//                                .font(.caption)
//                                .foregroundColor(.white)
//                                .padding(.horizontal, 12)
//                                .padding(.vertical, 6)
//                                .background(Color.orange)
//                                .cornerRadius(8)
//                        }
//
//                        Text("Connection Status")
//                            .font(.headline)
//                            .foregroundColor(.primary)
//                        
//                        Text(mpcManager.connectionStatus)
//                            .font(.subheadline)
//                            .foregroundColor(mpcManager.connectedPeers.isEmpty ? .red : .green)
//                            .padding(.horizontal, 12)
//                            .padding(.vertical, 8)
//                            .background(Color.gray.opacity(0.1))
//                            .cornerRadius(8)
//                        
//                        Text("Your Device: \(mpcManager.peerID.displayName)")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                        
//                        HStack {
//                            Label("Advertising", systemImage: mpcManager.isAdvertising ? "wifi.circle.fill" : "wifi.slash")
//                                .font(.caption)
//                                .foregroundColor(mpcManager.isAdvertising ? .green : .red)
//                            
//                            Spacer()
//                            
//                            Label("Browsing", systemImage: mpcManager.isBrowsing ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
//                                .font(.caption)
//                                .foregroundColor(mpcManager.isBrowsing ? .green : .red)
//                        }
//                        
//                        Button(action: {
////                            mpcManager.restartServices()
//                        }) {
//                            Text("Restart Services")
//                                .font(.caption)
//                                .foregroundColor(.white)
//                                .padding(.horizontal, 12)
//                                .padding(.vertical, 6)
//                                .background(Color.orange)
//                                .cornerRadius(8)
//                        }
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding()
//                    .background(Color.gray.opacity(0.05))
//                    .cornerRadius(12)
//                    
//                    // Available Peers Section
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("Available Devices")
//                            .font(.headline)
//                            .foregroundColor(.primary)
//                        
//                        if mpcManager.availablePeers.isEmpty {
//                            Text("No devices found nearby")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                                .italic()
//                        } else {
//                            ForEach(mpcManager.availablePeers, id: \.self) { peer in
//                                HStack {
//                                    VStack(alignment: .leading) {
//                                        Text(peer.displayName)
//                                            .font(.subheadline)
//                                            .fontWeight(.medium)
//                                        Text("Tap to invite")
//                                            .font(.caption)
//                                            .foregroundColor(.secondary)
//                                    }
//                                    
//                                    Spacer()
//                                    
//                                    Button(action: {
//                                        mpcManager.invitePeer(peer)
//                                        alertMessage = "Invitation sent to \(peer.displayName)"
//                                        showingAlert = true
//                                    }) {
//                                        Text("Invite")
//                                            .font(.caption)
//                                            .foregroundColor(.white)
//                                            .padding(.horizontal, 12)
//                                            .padding(.vertical, 6)
//                                            .background(Color.blue)
//                                            .cornerRadius(8)
//                                    }
//                                }
//                                .padding(.horizontal, 12)
//                                .padding(.vertical, 8)
//                                .background(Color.blue.opacity(0.1))
//                                .cornerRadius(8)
//                            }
//                        }
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding()
//                    .background(Color.gray.opacity(0.05))
//                    .cornerRadius(12)
//                    
//                    // Connected Peers Section
//                    if !mpcManager.connectedPeers.isEmpty {
//                        VStack(alignment: .leading, spacing: 10) {
//                            Text("Connected Devices")
//                                .font(.headline)
//                                .foregroundColor(.primary)
//                            
//                            ForEach(mpcManager.connectedPeers, id: \.self) { peer in
//                                HStack {
//                                    Image(systemName: "checkmark.circle.fill")
//                                        .foregroundColor(.green)
//                                    Text(peer.displayName)
//                                        .font(.subheadline)
//                                        .fontWeight(.medium)
//                                    Spacer()
//                                }
//                                .padding(.horizontal, 12)
//                                .padding(.vertical, 8)
//                                .background(Color.green.opacity(0.1))
//                                .cornerRadius(8)
//                            }
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding()
//                        .background(Color.gray.opacity(0.05))
//                        .cornerRadius(12)
//                    }
//                    
//                    // Message Section
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("Send Message")
//                            .font(.headline)
//                            .foregroundColor(.primary)
//                        
//                        HStack {
//                            TextField("Enter your message...", text: $messageText)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                            
//                            Button(action: {
//                                if !messageText.isEmpty {
//                                    mpcManager.send(message: messageText)
//                                    mpcManager.receivedMessages.append("You: \(messageText)")
//                                    messageText = ""
//                                }
//                            }) {
//                                Text("Send")
//                                    .foregroundColor(.white)
//                                    .padding(.horizontal, 16)
//                                    .padding(.vertical, 8)
//                                    .background(mpcManager.connectedPeers.isEmpty ? Color.gray : Color.blue)
//                                    .cornerRadius(8)
//                            }
//                            .disabled(mpcManager.connectedPeers.isEmpty || messageText.isEmpty)
//                        }
//                        
//                        if mpcManager.connectedPeers.isEmpty {
//                            Text("Connect to a device to send messages")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                    .padding()
//                    .background(Color.gray.opacity(0.05))
//                    .cornerRadius(12)
//                    
//                    // Messages Section
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("Messages")
//                            .font(.headline)
//                            .foregroundColor(.primary)
//                        
//                        ScrollView {
//                            LazyVStack(alignment: .leading, spacing: 5) {
//                                if mpcManager.receivedMessages.isEmpty {
//                                    Text("No messages yet")
//                                        .font(.subheadline)
//                                        .foregroundColor(.secondary)
//                                        .italic()
//                                } else {
//                                    ForEach(mpcManager.receivedMessages, id: \.self) { message in
//                                        Text(message)
//                                            .font(.subheadline)
//                                            .padding(.horizontal, 12)
//                                            .padding(.vertical, 6)
//                                            .background(message.hasPrefix("You:") ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
//                                            .cornerRadius(8)
//                                            .frame(maxWidth: .infinity, alignment: .leading)
//                                    }
//                                }
//                            }
//                        }
//                        .frame(maxHeight: 200)
//                    }
//                    .padding()
//                    .background(Color.gray.opacity(0.05))
//                    .cornerRadius(12)
//                    
//                    // Disconnect Button
//                    if !mpcManager.connectedPeers.isEmpty {
//                        Button(action: {
//                            mpcManager.disconnect()
//                            alertMessage = "Disconnected from all devices"
//                            showingAlert = true
//                        }) {
//                            Text("Disconnect")
//                                .foregroundColor(.white)
//                                .font(.headline)
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.red)
//                                .cornerRadius(12)
//                        }
//                    }
//                    
//                    Spacer()
//                }
//                .padding()
//                .navigationTitle("Beat Your Friend")
//                .navigationBarTitleDisplayMode(.inline)
//                .alert("Notification", isPresented: $showingAlert) {
//                    Button("OK") { }
//                } message: {
//                    Text(alertMessage)
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//        .environmentObject(MPCManager())
//}
