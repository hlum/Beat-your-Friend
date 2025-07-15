//
//  HomeScreen.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/11.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var mpcManager: MPCManager
    
    @AppStorage("DisplayName") private var displayName = ""
    @State private var showNameInputAlert: Bool = false
    @State private var tempName: String = ""
    
    var body: some View {
       NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Game Logo/Title Section
                    VStack(spacing: 10) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("殴りましょう")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 40)
                    
                    // Welcome Section
                    VStack(spacing: 15) {
                        if displayName.isEmpty {
                            VStack(spacing: 10) {
                                Text("ゲームへようこそ！")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("始める前に名前を設定してください")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        } else {
                            VStack(spacing: 10) {
                                Text("おかえりなさい！")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("\(displayName)さん")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Action Buttons
                    VStack(spacing: 15) {
                        if displayName.isEmpty {
                            Button(action: {
                                showNameInputAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "person.fill")
                                    Text("名前を設定")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                        } else {
                            
                            NavigationLink {
                                GameScreen()
                                    .environmentObject(mpcManager)
                            } label: {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("ゲーム開始")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(mpcManager.connectionState == .connected ? .green : .gray)
                                .cornerRadius(12)
                            }
                            .disabled(mpcManager.connectionState != .connected)
                            
                            
                            Button(action: {
                                showNameInputAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("名前を変更")
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Footer
                    Text("楽しいゲーム体験をお楽しみください！")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                }
                
                
                if showNameInputAlert {
                    nameInputView
                }
            }
            .navigationTitle(mpcManager.connectionStatus.description)
            .onAppear {
                if displayName.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showNameInputAlert = true
                    }
                }
            }
        }

    }
    
    @ViewBuilder
    private var nameInputView: some View {
        VStack {
            Text("名前を入力してください")
                .font(.system(size: 20, weight: .bold, design: .default))
            
            
            Text("ゲームで使用する名前を入力してください。").font(.caption)
            
            TextField("あなたの名前", text: $tempName)
                .textInputAutocapitalization(.words)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            
            HStack {
                Button("キャンセル", role: .cancel) {
                    showNameInputAlert.toggle()
                    tempName = ""
                }
                .tint(.red)
                
                Spacer()
                
                
                Button {
                    if !tempName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        displayName = tempName.trimmingCharacters(in: .whitespacesAndNewlines)
                        tempName = ""
                        mpcManager.setDisplayName(displayName)
                        showNameInputAlert.toggle()
                    }
                } label: {
                    Text("保存")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(tempName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                        .foregroundStyle(.white)
                        .cornerRadius(70)
                        .padding(.leading)
                }
                .disabled(tempName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
            }
            .padding(.vertical, 10)
            
        }
        .padding(30)
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 200)
        .background(.white)
        .cornerRadius(30)
        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: -10)
        .padding(.horizontal, 50)
        .padding(.vertical)
    }
}


#Preview {
    NavigationStack {
        HomeScreen()
            .environmentObject(MPCManager())
    }
}
