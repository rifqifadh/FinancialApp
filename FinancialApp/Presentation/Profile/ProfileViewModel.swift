//
//  ProfileViewModel.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 21/10/25.
//

import Dependencies
import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {
  @ObservationIgnored
  @Dependency(\.profileService) var profileService

  // MARK: - State
  var profile: ProfileModel?
  var isLoading = false
  var errorMessage: String?
  var showError = false
  var profileState: ViewState<ProfileModel> = .idle
  var isSigningOut = false

  // MARK: - Computed Properties
  var displayName: String {
    profile?.displayName ?? "User"
  }

  var email: String {
    profile?.email ?? ""
  }

  var initials: String {
    profile?.initials ?? "U"
  }

  var hasAvatar: Bool {
    profile?.avatarUrl != nil
  }

  // MARK: - Actions
  func loadProfile() async {
    profileState = .loading
    do {
      if let profile = try await profileService.getCurrentUser() {
        self.profile = profile
        profileState = .success(profile)
      }
    } catch {
      let errorMessage = "Failed to load profile: \(error.localizedDescription)"
      self.errorMessage = errorMessage
      profileState = .error(error)
    }
  }

  func refresh() async {
    await loadProfile()
  }

  func signOut() async {
    isSigningOut = true
    defer { isSigningOut = false }

    do {
      try await profileService.signOut()
      // AuthenticationStore will handle the state change
    } catch {
      errorMessage = "Failed to sign out: \(error.localizedDescription)"
      showError = true
    }
  }

  func updateProfile(fullName: String?, avatarUrl: String?) async -> Bool {
    isLoading = true
    defer { isLoading = false }

    do {
      let params = UpdateProfileParams(fullName: fullName, avatarUrl: avatarUrl)
      let updatedProfile = try await profileService.updateUserMetadata(params)
      self.profile = updatedProfile
      profileState = .success(updatedProfile)
      return true
    } catch {
      errorMessage = "Failed to update profile: \(error.localizedDescription)"
      showError = true
      return false
    }
  }
}
