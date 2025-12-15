//
//  CameraPromptView.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI

struct CameraPromptView: View {
    let selectedColor: Color
    let onCamera: () -> Void
    let onGallery: () -> Void
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                let totalHeight = geo.size.height
                let verticalPadding: CGFloat = 12
                let spacing: CGFloat = 12
                let buttonHeight = max(0, (totalHeight - (verticalPadding * 2) - spacing) / 2)
                
                VStack(spacing: spacing) {
                    // Top: Camera
                Button(action: onCamera) {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(selectedColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: buttonHeight)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                            )
                    }
                    .buttonPressAnimation()
                    
                    // Bottom: Gallery
                Button(action: onGallery) {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(selectedColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: buttonHeight)
                            .overlay(
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                            )
                    }
                    .buttonPressAnimation()
                }
                .padding(.top, verticalPadding)
                .padding(.bottom, verticalPadding)
                .padding(.horizontal, 12)
                }
            }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

