//
//  ProfileView.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 21/10/25.
//

import SwiftUI

struct ProfileView: View {
  @State private var viewModel = ProfileViewModel()
  @State private var showSignOutConfirmation = false

  var body: some View {
    NavigationView {
      ViewStateView(
        state: viewModel.profileState,
        content: { profile in
          ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
              // Profile Header Card
              profileHeaderCard(profile: profile)

              // Profile Information Card
              profileInfoCard(profile: profile)

              // Actions Section
              actionsSection

              Spacer(minLength: AppTheme.Spacing.xl)
            }
            .padding(AppTheme.Spacing.lg)
          }
          .background(AppTheme.Colors.background)
        },
        emptyView: {
          ContentUnavailableView(
            "No Profile",
            systemImage: "person.slash",
            description: Text("Unable to load your profile")
          )
        },
        errorView: { error in
          DefaultErrorView(error: error)
        },
        retry: {
          Task { await viewModel.loadProfile() }
        }
      )
      .navigationTitle("Profile")
      .task {
        await viewModel.loadProfile()
      }
      .refreshable {
        await viewModel.refresh()
      }
      .alert("Error", isPresented: $viewModel.showError) {
        Button("OK", role: .cancel) {}
      } message: {
        if let errorMessage = viewModel.errorMessage {
          Text(errorMessage)
        }
      }
      .confirmationDialog("Sign Out", isPresented: $showSignOutConfirmation) {
        Button("Sign Out", role: .destructive) {
          Task {
            await viewModel.signOut()
          }
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("Are you sure you want to sign out?")
      }
      .overlay {
        if viewModel.isSigningOut {
          LoadingView(label: "Signing out...")
        }
      }
    }
  }

  // MARK: - Profile Header Card
  @ViewBuilder
  private func profileHeaderCard(profile: ProfileModel) -> some View {
    VStack(spacing: AppTheme.Spacing.md) {
      // Avatar
      ZStack {
        Circle()
          .fill(
            LinearGradient(
              colors: [
                AppTheme.Colors.primary,
                AppTheme.Colors.secondary
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 100, height: 100)

        if let avatarUrl = profile.avatarUrl, !avatarUrl.isEmpty {
          // TODO: Load actual image from URL
          AsyncImage(url: URL(string: avatarUrl)) { image in
            image
              .resizable()
              .scaledToFill()
          } placeholder: {
            Text(profile.initials)
              .font(.system(size: 36, weight: .bold))
              .foregroundStyle(.white)
          }
          .frame(width: 100, height: 100)
          .clipShape(Circle())
        } else {
          Text(profile.initials)
            .font(.system(size: 36, weight: .bold))
            .foregroundStyle(.white)
        }
      }

      // Name and Email
      VStack(spacing: 4) {
        Text(profile.displayName)
          .font(AppTheme.Typography.title2)
          .foregroundStyle(AppTheme.Colors.primaryText)

        if let email = profile.email {
          Text(email)
            .font(AppTheme.Typography.body)
            .foregroundStyle(AppTheme.Colors.secondaryText)
        }
      }
    }
    .frame(maxWidth: .infinity)
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.cardBackground)
    .cornerRadius(AppTheme.CornerRadius.large)
    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
  }

  // MARK: - Profile Info Card
  @ViewBuilder
  private func profileInfoCard(profile: ProfileModel) -> some View {
    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
      Text("Account Information")
        .font(AppTheme.Typography.title3)
        .foregroundStyle(AppTheme.Colors.primaryText)

      VStack(spacing: 0) {
        profileInfoRow(
          icon: "person.fill",
          label: "Full Name",
          value: profile.fullName ?? "Not set"
        )

        Divider()
          .background(AppTheme.Colors.divider)
          .padding(.leading, 48)

        profileInfoRow(
          icon: "envelope.fill",
          label: "Email",
          value: profile.email ?? "Not set"
        )

        Divider()
          .background(AppTheme.Colors.divider)
          .padding(.leading, 48)

        profileInfoRow(
          icon: "calendar",
          label: "Member Since",
          value: profile.createdAt?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown"
        )
      }
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.cardBackground)
    .cornerRadius(AppTheme.CornerRadius.large)
    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
  }

  // MARK: - Profile Info Row
  @ViewBuilder
  private func profileInfoRow(icon: String, label: String, value: String) -> some View {
    HStack(spacing: AppTheme.Spacing.md) {
      Image(systemName: icon)
        .font(.system(size: 16))
        .foregroundStyle(AppTheme.Colors.accent)
        .frame(width: 32, height: 32)
        .background(AppTheme.Colors.accent.opacity(0.1))
        .clipShape(Circle())

      VStack(alignment: .leading, spacing: 2) {
        Text(label)
          .font(AppTheme.Typography.caption)
          .foregroundStyle(AppTheme.Colors.tertiaryText)

        Text(value)
          .font(AppTheme.Typography.body)
          .foregroundStyle(AppTheme.Colors.primaryText)
      }

      Spacer()
    }
    .padding(.vertical, AppTheme.Spacing.sm)
  }

  // MARK: - Actions Section
  @ViewBuilder
  private var actionsSection: some View {
    VStack(spacing: AppTheme.Spacing.md) {
      // Edit Profile Button
      Button(action: {
        // TODO: Navigate to edit profile
      }) {
        HStack {
          Image(systemName: "pencil")
          Text("Edit Profile")
        }
        .font(AppTheme.Typography.bodyBold)
        .foregroundStyle(AppTheme.Colors.primary)
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.primary.opacity(0.1))
        .cornerRadius(AppTheme.CornerRadius.medium)
      }

      // Sign Out Button
      Button(action: {
        showSignOutConfirmation = true
      }) {
        HStack {
          Image(systemName: "rectangle.portrait.and.arrow.right")
          Text("Sign Out")
        }
        .font(AppTheme.Typography.bodyBold)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.loss)
        .cornerRadius(AppTheme.CornerRadius.medium)
      }
      .disabled(viewModel.isSigningOut)
    }
  }
}

#Preview("Profile - Loaded") {
  ProfileView()
}

#Preview("Profile - Dark Mode") {
  ProfileView()
    .preferredColorScheme(.dark)
}
