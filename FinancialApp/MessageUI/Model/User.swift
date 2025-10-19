//
//  UserType.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 20/08/25.
//

import Foundation

public enum UserType: Int, Codable, Sendable, Equatable {
    case current = 0, other, system
}

public struct User: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let avatarURL: URL?
    public let type: UserType
    public var isCurrentUser: Bool { type == .current }
    
    public init(id: String, name: String, avatarURL: URL?, isCurrentUser: Bool) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.type = isCurrentUser ? .current : .other
    }
    
    public init(id: String, name: String, avatarURL: URL?, type: UserType) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.type = type
    }
    
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.avatarURL == rhs.avatarURL &&
        lhs.type == rhs.type
    }
}
