//
//  HowToPlayView.swift
//  77ChromaCore
//

import SwiftUI

struct HowToPlayView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            ChromaTheme.background
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("How to Play")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    
                    section(
                        title: "Goal",
                        text: "Create lines of 3 or more segments of the same color (green, red, or orange — any color). When a line is formed, you get points and the reactor’s energy, temperature, and stability change.\n\nYou do NOT need to make all circles green. Lines of any color count. Balance the three gauges to win."
                    )
                    
                    section(
                        title: "Two types of lines",
                        text: "• Radial: the same color on all three rings along one radius (from center to edge).\n\n• On a ring: 3 or more segments of the same color in a row on one ring."
                    )
                    
                    section(
                        title: "Controls",
                        text: "Tap on a ring to rotate it one step clockwise. Swipe left or right on a ring to rotate it in that direction. Only the ring you touch is rotated. The highlighted ring shows which one will move."
                    )
                    
                    section(
                        title: "Colors",
                        text: "All three colors are useful. You can make lines of any color.\n• Green (Stable): safe, cools the reactor.\n• Red (Critical): strong energy but heats the reactor.\n• Orange (Balancing): stabilizes temperature and balance."
                    )
                    
                    section(
                        title: "Winning",
                        text: "You have 25 moves per level. Keep energy in the green–orange zone (left scale), temperature in the safe zone (right scale), and stability near the center (bottom bar). If temperature reaches 100%, the reactor overloads and you lose. Complete the level by meeting the balance goals."
                    )
                    
                    Button("Got it") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundStyle(ChromaTheme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(ChromaTheme.stable)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 8)
                }
                .padding(24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Close") { dismiss() }
                    .foregroundStyle(ChromaTheme.balancing)
            }
        }
    }
    
    private func section(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(ChromaTheme.balancing)
            Text(text)
                .font(.body)
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}

#Preview {
    NavigationStack {
        HowToPlayView()
    }
}
