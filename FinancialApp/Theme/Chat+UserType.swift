//
//  Chat+UserType.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 21/08/25.
//

import SwiftUI

extension ChatTheme.Colors {
    func messageBG(_ type: UserType) -> Color {
        switch type {
        case .current: messageMyBG
        case .other: messageFriendBG
        case .system: messageSystemBG
        }
    }
    
    func messageText(_ type: UserType) -> Color {
        switch type {
        case .current: messageMyText
        case .other: messageFriendText
        case .system: messageSystemText
        }
    }
    
    func messageTimeText(_ type: UserType) -> Color {
        switch type {
        case .current: messageMyTimeText
        case .other: messageFriendTimeText
        case .system: messageSystemTimeText
        }
    }
}
