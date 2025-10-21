//
//  ProfileService.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 21/10/25.
//

import Dependencies
import Foundation
import Supabase

struct ProfileService: Sendable {
  var getCurrentUser: @Sendable () async throws -> ProfileModel?
  var updateUserMetadata: @Sendable (_ params: UpdateProfileParams) async throws -> ProfileModel
  var signOut: @Sendable () async throws -> Void
}

// MARK: - Request Parameters
struct UpdateProfileParams: Codable, Sendable {
  let fullName: String?
  let avatarUrl: String?

  enum CodingKeys: String, CodingKey {
    case fullName = "full_name"
    case avatarUrl = "avatar_url"
  }

  var asDictionary: [String: String] {
    var dict: [String: String] = [:]
    if let fullName = fullName {
      dict["full_name"] = fullName
    }
    if let avatarUrl = avatarUrl {
      dict["avatar_url"] = avatarUrl
    }
    return dict
  }
}

// MARK: - Dependency Key
extension ProfileService: DependencyKey {
  static let liveValue = ProfileService(
    getCurrentUser: {
      // Get current user session
      let session = try await SupabaseManager.shared.client.auth.session

      // Create profile from session user data
      return ProfileModel(
        id: session.user.id.uuidString,
        email: session.user.email,
        fullName: session.user.userMetadata["full_name"] as? String,
        avatarUrl: session.user.userMetadata["avatar_url"] as? String,
        createdAt: session.user.createdAt
      )
    },
    updateUserMetadata: { params in
      // Update user metadata in Supabase Auth
      let updatedUser = try await SupabaseManager.shared.client.auth.update(
        user: UserAttributes(data: params.asDictionary)
      )

      // Return updated profile
      return ProfileModel(
        id: updatedUser.id.uuidString,
        email: updatedUser.email,
        fullName: updatedUser.userMetadata["full_name"] as? String,
        avatarUrl: updatedUser.userMetadata["avatar_url"] as? String,
        createdAt: updatedUser.createdAt
      )
    },
    signOut: {
      try await SupabaseManager.shared.client.auth.signOut()
    }
  )

  static let testValue = ProfileService(
    getCurrentUser: {
      ProfileModel.mock
    },
    updateUserMetadata: { _ in
      ProfileModel.mock
    },
    signOut: {}
  )
}

// MARK: - Dependency Values
extension DependencyValues {
  var profileService: ProfileService {
    get { self[ProfileService.self] }
    set { self[ProfileService.self] = newValue }
  }
}
