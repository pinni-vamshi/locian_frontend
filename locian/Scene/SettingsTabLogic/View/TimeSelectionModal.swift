//
//  TimeSelectionModal.swift
//  locian
//

import SwiftUI
import Combine

struct TimeSelectionModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    var onSave: (String) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 32) {
                    Text("SELECT TIME")
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    
                    Button(action: {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "h:mm a"
                        onSave(formatter.string(from: selectedDate))
                    }) {
                        Text("CONFIRM TIME")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(ThemeColors.primaryAccent)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}
