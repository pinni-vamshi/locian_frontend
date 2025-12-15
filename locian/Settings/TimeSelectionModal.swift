//
//  TimeSelectionModal.swift
//  locian
//
//  Created by AI Assistant
//

import SwiftUI

struct TimeSelectionModal: View {
    let selectedColor: Color
    let onTimeSelected: (String) -> Void
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedHour: Int = 8
    @State private var selectedMinute: Int = 0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            HStack {
                Text(LocalizationManager.shared.string(.selectTime))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(LocalizationManager.shared.string(.cancel)) {
                    dismiss()
                }
                .font(.system(size: 16))
                .foregroundColor(selectedColor)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Time picker
            HStack(spacing: 20) {
                // Hour picker
                VStack(spacing: 10) {
                    Text(LocalizationManager.shared.string(.hour))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black.opacity(0.6))
                    
                    Picker(LocalizationManager.shared.string(.hour), selection: $selectedHour) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(String(format: "%02d", hour))
                                .tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                }
                
                Text(":")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 30)
                
                // Minute picker
                VStack(spacing: 10) {
                    Text(LocalizationManager.shared.string(.minute))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black.opacity(0.6))
                    
                    Picker(LocalizationManager.shared.string(.minute), selection: $selectedMinute) {
                        ForEach(0..<60, id: \.self) { minute in
                            Text(String(format: "%02d", minute))
                                .tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                }
            }
            .padding(.horizontal, 20)
            
            // Add button
            Button(action: {
                let timeString = String(format: "%02d:%02d", selectedHour, selectedMinute)
                onTimeSelected(timeString)
            }) {
                Text(LocalizationManager.shared.string(.addTime))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(selectedColor)
                    .cornerRadius(15)
            }
            .buttonStyle(PlainButtonStyle())
            .buttonPressAnimation()
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(selectedColor)
        .ignoresSafeArea()
    }
}


