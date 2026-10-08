//
//  ProfileViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 07/10/26.
//

import Foundation
import AVFoundation
import UserNotifications

@MainActor
final class ProfileViewModel {
    private(set) var stats: ProfileStats?
    private(set) var permissionsText = "Câmera e notificações"
    
    var onChange: (() -> Void)?
    
    func load() async {
        async let statsRequest = try? ProfileService.shared.stats()
        async let notificationStatus = NotificationPermission.status()
        
        if let stats = await statsRequest {
            self.stats = stats
        }
        
        permissionsText = Self.permissionsText(
            camera: AVCaptureDevice.authorizationStatus(for: .video),
            notifications: await notificationStatus
        )
        
        onChange?()
    }
    
    private static func permissionsText(camera: AVAuthorizationStatus, notifications: UNAuthorizationStatus) -> String {
        let cameraText = switch camera {
        case .authorized: "permitida"
        case .notDetermined: "não solicitada"
        default: "negada"
        }
        
        let notificationsText = switch notifications {
        case .authorized, .provisional, .ephemeral: "ativadas"
        case .notDetermined: "não solicitadas"
        default: "desativadas"
        }
        
        return "Câmera: \(cameraText) · Notificações: \(notificationsText)"
    }
}
