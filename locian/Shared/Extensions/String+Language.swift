//
//  String+Language.swift
//  locian
//

import Foundation

extension String {
    func getLanguageDisplayName() -> String {
        return LanguageMapping.shared.getDisplayNames(for: self).english
    }
}
