import SwiftUI
import Combine

class LanguageLogic: ObservableObject {
    @ObservedObject var appState: AppStateManager
    
    struct NeuralStatus {
        let state: String // LOADING, LOADED, DOWN, FAILED
        let mode: String  // CONTEXTUAL, STATIC, LEVENSHTEIN (rendered as REGULAR)
    }
    
    @Published var neuralStatuses: [String: NeuralStatus] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    init(appState: AppStateManager) {
        self.appState = appState
        setupBindings()
        
        // Initial population
        checkNeuralStatus()
    }
    
    private func setupBindings() {
        // Automatically refresh status whenever anything changes in appState
        appState.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.checkNeuralStatus()
            }
            .store(in: &cancellables)
    }
    
    func checkNeuralStatus() {
        var codes = Set<String>()
        
        // 1. Add Native Language
        let native = appState.nativeLanguage.trimmingCharacters(in: .whitespacesAndNewlines)
        if !native.isEmpty {
            codes.insert(native)
        }
        
        // 2. Add all Target Languages from pairs
        appState.userLanguagePairs.forEach { pair in
            let target = pair.target_language.trimmingCharacters(in: .whitespacesAndNewlines)
            if !target.isEmpty {
                codes.insert(target)
            }
        }
        
        if codes.isEmpty { return }
        
        // Building status map for recognized codes
        for code in codes {
            let mode = EmbeddingService.getAvailableMode(for: code)
            let isAvailable = EmbeddingService.isModelAvailable(for: code)
            
            // If already loaded, don't flicker back to loading
            if isAvailable {
                if neuralStatuses[code]?.state != "LOADED" {
                    neuralStatuses[code] = NeuralStatus(state: "LOADED", mode: mode)
                }
            } else {
                // Not available yet
                if neuralStatuses[code] == nil || neuralStatuses[code]?.state == "FAILED" {
                   neuralStatuses[code] = NeuralStatus(state: "DOWN", mode: mode)
                   
                   // Request download
                   EmbeddingService.downloadModel(for: code) { success in
                       DispatchQueue.main.async {
                           let finalMode = EmbeddingService.getAvailableMode(for: code)
                           self.neuralStatuses[code] = NeuralStatus(state: success ? "LOADED" : "FAILED", mode: finalMode)
                       }
                   }
                }
            }
        }
    }
    
    func updateLevel(pair: LanguagePair, to level: String) {
        appState.updateLanguagePairLevel(nativeLanguage: pair.native_language, targetLanguage: pair.target_language, newLevel: level) { _ in }
    }
    
    func setDefault(pair: LanguagePair, completion: @escaping () -> Void) {
        appState.setDefaultLanguagePair(nativeLanguage: pair.native_language, targetLanguage: pair.target_language) { [weak self] _ in
            self?.appState.loadAvailableLanguagePairs { _ in completion() }
        }
    }
    
    func deletePair(pair: LanguagePair, completion: @escaping () -> Void) {
        appState.deleteLanguagePair(nativeLanguage: pair.native_language, targetLanguage: pair.target_language) { _ in completion() }
    }
}
