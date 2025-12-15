//
//  SceneActions.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import Foundation
import UIKit

struct SceneActions {
    static func analyzeImage(_ image: UIImage, appState: AppStateManager, completion: @escaping (Bool) -> Void) {
        appState.analyzeImage(image) { success in
            completion(success)
        }
    }
}
