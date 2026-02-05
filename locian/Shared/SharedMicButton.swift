//
//  SharedMicButton.swift
//  locian
//
//  Shared Microphone Button Component
//  Standardized "Pink Square" design for all speaking drills.
//

import SwiftUI

struct SharedMicButton: View {
    let isRecording: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                // 1. Mic Part (Pink Square)
                ZStack {
                    CyberColors.neonPink
                    
                    Image(systemName: isRecording ? "waveform" : "mic.fill")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.black)
                }
                .frame(width: 80, height: 80)
                
                // 2. Text Part (White Rect)
                ZStack {
                    Color.white
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isRecording ? "LISTENING..." : "TAP TO SPEAK")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                        
                        Text(isRecording ? "SAY IT NOW" : "USE MICROPHONE")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.black.opacity(0.5))
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 80)
            }
            .background(Color.white)
            .overlay(
                Rectangle()
                    .stroke(Color.white, lineWidth: 2)
            )
            .fixedSize(horizontal: true, vertical: true)
        }
    }
}
