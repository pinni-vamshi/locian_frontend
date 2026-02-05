//
//  EditStreakModal.swift
//  locian
//

import SwiftUI
import Combine

struct EditStreakModal: View {
    @ObservedObject var appState: AppStateManager
    let pair: LanguagePair
    let streak: Int
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Done") { onDismiss() }
                    .font(.headline)
                    .padding()
            }
            
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 80))
                    .foregroundColor(ThemeColors.primaryAccent)
                
                Text("\(streak)")
                    .font(.system(size: 60, weight: .black))
                    .foregroundColor(.white)
                
                Text("DAY STREAK")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
    }
}
