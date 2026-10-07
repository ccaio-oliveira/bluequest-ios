//
//  Invite.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 26/07/26.
//

import Foundation

enum InviteState: String {
    case valid
    case invalid
    case challengeClosed = "challenge_closed"
    case alreadyParticipant = "already_participant"
}
