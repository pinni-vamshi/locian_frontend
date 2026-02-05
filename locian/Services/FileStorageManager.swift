//
//  FileStorageManager.swift
//  locian
//
//  Created for storing large data in file system instead of UserDefaults
//

import Foundation
import UIKit

class FileStorageManager {
    static let shared = FileStorageManager()
    
    private let documentsDirectory: URL
    
    private init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - Save Large Data
    
    func save<T: Codable>(_ object: T, forKey key: String) -> Bool {
        guard let data = try? JSONEncoder().encode(object) else { return false }
        let fileURL = documentsDirectory.appendingPathComponent("\(key).json")
        
        do {
            try data.write(to: fileURL)
            return true
        } catch {
            return false
        }
    }
    
    func saveData(_ data: Data, forKey key: String) -> Bool {
        let fileURL = documentsDirectory.appendingPathComponent("\(key).data")
        
        do {
            try data.write(to: fileURL)
            return true
        } catch {
            return false
        }
    }
    
    func saveString(_ string: String, forKey key: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return saveData(data, forKey: key)
    }
    
    func saveImageArray(_ images: [UIImage], forKey key: String) -> Bool {
        let imageDataArray = images.compactMap { image in
            image.jpegData(compressionQuality: 0.7)
        }
        return save(imageDataArray, forKey: key)
    }
    
    func loadImageArray(forKey key: String) -> [UIImage] {
        guard let dataArray: [Data] = load([Data].self, forKey: key) else { return [] }
        return dataArray.compactMap { UIImage(data: $0) }
    }
    
    // MARK: - Load Large Data
    
    func load<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        let fileURL = documentsDirectory.appendingPathComponent("\(key).json")
        
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
    
    func loadData(forKey key: String) -> Data? {
        let fileURL = documentsDirectory.appendingPathComponent("\(key).data")
        return try? Data(contentsOf: fileURL)
    }
    
    func loadString(forKey key: String) -> String? {
        guard let data = loadData(forKey: key),
              let string = String(data: data, encoding: .utf8) else { return nil }
        return string
    }
    
    // MARK: - Delete
    
    func delete(forKey key: String) {
        let jsonURL = documentsDirectory.appendingPathComponent("\(key).json")
        let dataURL = documentsDirectory.appendingPathComponent("\(key).data")
        
        try? FileManager.default.removeItem(at: jsonURL)
        try? FileManager.default.removeItem(at: dataURL)
    }
    
    // MARK: - Check Size
    
    func getSize(forKey key: String) -> Int64? {
        let jsonURL = documentsDirectory.appendingPathComponent("\(key).json")
        let dataURL = documentsDirectory.appendingPathComponent("\(key).data")
        
        if let attributes = try? FileManager.default.attributesOfItem(atPath: jsonURL.path),
           let size = attributes[.size] as? Int64 {
            return size
        }
        
        if let attributes = try? FileManager.default.attributesOfItem(atPath: dataURL.path),
           let size = attributes[.size] as? Int64 {
            return size
        }
        
        return nil
    }
}

