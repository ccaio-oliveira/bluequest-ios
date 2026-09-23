//
//  PhotoService.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 17/09/26.
//

import Foundation
import UIKit

final class PhotoService {
    static let shared = PhotoService()
    
    private let client = APIClient.shared
    
    private init() {}
    
    func uploadCompletionPhoto(_ image: UIImage) async throws -> String {
        guard let data = Self.jpegData(from: image) else {
            throw APIError.invalidImage
        }
        
        let dto: UploadedPhotoDTO = try await client.upload(
            "uploads/completion-photo",
            field: "photo",
            fileName: "foto.jpg",
            mimeType: "image/jpeg",
            data: data
        )
        
        return dto.path
    }
    
    private static func jpegData(from image: UIImage, maxDimension: CGFloat = 1280, quality: CGFloat = 0.8) -> Data? {
        let size = image.size
        let scale = min(1, maxDimension / max(size.width, size.height))
        let target = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: target, format: format)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
        
        return resized.jpegData(compressionQuality: quality)
    }
}

private struct UploadedPhotoDTO: Decodable {
    let path: String
}
