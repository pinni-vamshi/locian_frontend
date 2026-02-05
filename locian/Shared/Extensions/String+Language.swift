//
//  String+Language.swift
//  locian
//

import Foundation

extension String {
    func getLanguageDisplayName() -> String {
        return TargetLanguageMapping.shared.getDisplayNames(for: self).english
    }
}
