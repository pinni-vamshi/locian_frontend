//
//  PersistedPropertyWrapper.swift
//  locian
//
//  Created for automatic UserDefaults persistence
//

import Foundation

/// Property wrapper that automatically persists values to UserDefaults
@propertyWrapper
struct Persisted<Value> {
    let key: String
    let defaultValue: Value
    
    var wrappedValue: Value {
        get {
            if let value = UserDefaults.standard.object(forKey: key) as? Value {
                return value
            }
            return defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
    init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
}

/// Specialized wrapper for optional String values
@propertyWrapper
struct PersistedOptionalString {
    let key: String
    
    var wrappedValue: String? {
        get {
            return UserDefaults.standard.string(forKey: key)
        }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
    
    init(key: String) {
        self.key = key
    }
}

/// Specialized wrapper for optional Data values
@propertyWrapper
struct PersistedOptionalData {
    let key: String
    
    var wrappedValue: Data? {
        get {
            return UserDefaults.standard.data(forKey: key)
        }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
    
    init(key: String) {
        self.key = key
    }
}

