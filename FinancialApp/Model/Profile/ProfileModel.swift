//
//  ProfileModel.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 21/10/25.
//

import Foundation

struct ProfileModel: Identifiable, Codable, Sendable {
  let id: String
  let email: String?
  let fullName: String?
  let avatarUrl: String?
  let createdAt: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case email
    case fullName = "full_name"
    case avatarUrl = "avatar_url"
    case createdAt = "created_at"
  }

  // MARK: - Computed Properties
  var displayName: String {
    fullName ?? email ?? "User"
  }

  var initials: String {
    if let fullName = fullName, !fullName.isEmpty {
      let components = fullName.split(separator: " ")
      if components.count >= 2 {
        return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
      } else if let first = components.first {
        return String(first.prefix(2)).uppercased()
      }
    }

    if let email = email, !email.isEmpty {
      return String(email.prefix(2)).uppercased()
    }

    return "U"
  }
}

// MARK: - Mock Data
extension ProfileModel {
  static let mock = ProfileModel(
    id: "user123",
    email: "rifqi@example.com",
    fullName: "Rifqi Fadhlillah",
    avatarUrl: nil,
    createdAt: Date()
  )

  static let mockWithAvatar = ProfileModel(
    id: "user456",
    email: "john@example.com",
    fullName: "John Doe",
    avatarUrl: "https://example.com/avatar.jpg",
    createdAt: Date()
  )
}
