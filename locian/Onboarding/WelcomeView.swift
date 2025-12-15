//
//  WelcomeView.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            // App icon - try to load from regular image asset first
            // If "AppIconImage" asset doesn't exist, fall back to system icon
            if let appIcon = UIImage(named: "AppIconImage") {
                Image(uiImage: appIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .cornerRadius(45)
            } else {
                // Fallback to system icon if app icon asset not found
            Image(systemName: "app.fill")
                .font(.system(size: 100))
                .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    WelcomeView()
        .background(Color.black)
        .preferredColorScheme(.dark)
}
