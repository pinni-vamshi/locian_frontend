//
//  PhotoLibraryManager.swift
//  locian
//
//  Created for fetching recent images from the system photo library.
//

import SwiftUI
import Photos
import PhotosUI
import Combine

class PhotoLibraryManager: ObservableObject {
    @Published var recentImages: [UIImage] = []
    @Published var isLoading: Bool = false
    
    func fetchRecentImages(count: Int = 10) {
        isLoading = true
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = count
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        var images: [UIImage] = []
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        
        let group = DispatchGroup()
        
        fetchResult.enumerateObjects { (asset, index, stop) in
            group.enter()
            let targetSize = CGSize(width: 300, height: 300) // Thumbnails
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
                if let image = image {
                    images.append(image)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.recentImages = images
            self.isLoading = false
        }
    }
}
