//
//  SettingsView.swift
//  77ChromaCore
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @AppStorage("settings_sound") private var soundEnabled = true
    @AppStorage("settings_haptics") private var hapticsEnabled = true
    
    var body: some View {
        ZStack {
            ChromaTheme.background
                .ignoresSafeArea()
            gridOverlay
            Form {
                Section {
                    Toggle("Sound effects", isOn: $soundEnabled)
                        .tint(ChromaTheme.stable)
                    Toggle("Haptic feedback", isOn: $hapticsEnabled)
                        .tint(ChromaTheme.stable)
                } header: {
                    Text("Audio & Feedback")
                        .foregroundStyle(ChromaTheme.balancing)
                }
                .listRowBackground(Color.white.opacity(0.08))
                .foregroundStyle(.white)
                
                Section {
                    Button {
                        rateApp()
                    } label: {
                        HStack {
                            Text("Rate Us")
                            Spacer()
                            Image(systemName: "star.fill")
                                .foregroundStyle(ChromaTheme.balancing)
                        }
                        .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.white.opacity(0.08))
                    Button {
                        openURL("https://www.termsfeed.com/live/10337594-9955-4e1a-aa09-4e343660d86b")
                    } label: {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "hand.raised.fill")
                                .foregroundStyle(ChromaTheme.balancing)
                        }
                        .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.white.opacity(0.08))
                    Button {
                        openURL("https://www.termsfeed.com/live/bea0159e-7045-443a-b0d5-9e79c0edbb84")
                    } label: {
                        HStack {
                            Text("Terms of Use")
                            Spacer()
                            Image(systemName: "doc.text.fill")
                                .foregroundStyle(ChromaTheme.balancing)
                        }
                        .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.white.opacity(0.08))
                } header: {
                    Text("Support")
                        .foregroundStyle(ChromaTheme.balancing)
                }
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.white.opacity(0.6))
                    }
                } header: {
                    Text("About")
                        .foregroundStyle(ChromaTheme.balancing)
                }
                .listRowBackground(Color.white.opacity(0.08))
                .foregroundStyle(.white)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Settings")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
    }
    
    private func openURL(_ string: String) {
        if let url = URL(string: string) {
            UIApplication.shared.open(url)
        }
    }
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private var gridOverlay: some View {
        GeometryReader { g in
            Path { p in
                let step: CGFloat = 24
                var x: CGFloat = 0
                while x <= g.size.width {
                    p.move(to: CGPoint(x: x, y: 0))
                    p.addLine(to: CGPoint(x: x, y: g.size.height))
                    x += step
                }
                var y: CGFloat = 0
                while y <= g.size.height {
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: g.size.width, y: y))
                    y += step
                }
            }
            .stroke(Color.white.opacity(ChromaTheme.gridOpacity), lineWidth: 1)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
