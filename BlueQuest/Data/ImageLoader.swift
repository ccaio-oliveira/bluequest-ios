//
//  ImageLoader.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 18/09/26.
//

import Foundation
import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    
    private let cache = NSCache<NSString, UIImage>()
    private let session = URLSession(configuration: .default)
    
    private init() {
        cache.countLimit = 200
    }
    
    func image(for url: URL, thumbnailSize: CGSize? = nil) async ->UIImage? {
        let key = cacheKey(for: url, size: thumbnailSize)
        
        if let cached = cache.object(forKey: key) {
            return cached
        }
        
        guard let (data, _) = try? await session.data(from: url),
              let image = UIImage(data: data)
        else { return nil }
        
        let result = thumbnailSize.flatMap { image.preparingThumbnail(of: $0) } ?? image
        cache.setObject(result, forKey: key)
        
        return result
    }
    
    private func cacheKey(for url: URL, size: CGSize?) -> NSString {
        guard let size else { return url.absoluteString as NSString }
        
        return "\(url.absoluteString)#\(Int(size.width))x\(Int(size.height))" as NSString
    }
}
