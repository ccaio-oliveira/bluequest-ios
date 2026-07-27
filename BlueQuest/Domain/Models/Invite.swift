//
//  Invite.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 26/07/26.
//

import Foundation

struct Invite: Identifiable, Codable {
    let id: Int
    var challengeID: Int
    var code: String
    var createdByUserID: Int
    var createdAt: Date
    var usedByUserID: Int?
    var usedAt: Date?
    var revokedAt: Date?
}

enum InviteState: Equatable {
    case valid
    case used
    case revoked
    case challengeClosed
    case alreadyParticipant
}

func inviteState(
    for invite: Invite,
    challengeState: ChallengeState,
    requestingUserIsParticipant: Bool,
    now: Date
) -> InviteState {
    // Fase 2
    return .valid
}
