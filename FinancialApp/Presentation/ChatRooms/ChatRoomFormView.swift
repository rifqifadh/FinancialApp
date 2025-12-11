//
//  ChatRoomFormView.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import SwiftUI
import Dependencies

struct ChatRoomFormView: View {
  @Environment(\.dismiss) private var dismiss
  @Dependency(\.chatServices) private var chatServices
  @Dependency(\.profileService) private var profileService

  @State private var roomName = ""
  @State private var isCreating = false
  @State private var showError = false
  @State private var errorMessage = ""
  
  var body: some View {
    NavigationView {
      Form {
        // MARK: - Room Details Section
        Section {
          VStack(alignment: .leading, spacing: 8) {
            Text("Room Name")
              .font(AppTheme.Typography.caption)
              .foregroundStyle(AppTheme.Colors.secondaryText)

            TextField("e.g., Budget Planning Discussion", text: $roomName)
              .textFieldStyle(.plain)
              .font(AppTheme.Typography.body)
              .disabled(isCreating)
          }
          .padding(.vertical, 4)
        } header: {
          Text("Chat Room Details")
        } footer: {
          Text("Choose a descriptive name for your chat room. You can select an AI agent after creating the room.")
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.tertiaryText)
        }
        
        // MARK: - Suggestions Section
        Section {
          VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            ForEach(suggestions, id: \.self) { suggestion in
              Button {
                roomName = suggestion
              } label: {
                HStack {
                  Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.Colors.accent)

                  Text(suggestion)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.primaryText)

                  Spacer()

                  Image(systemName: "arrow.up.left")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                }
                .padding(.vertical, 4)
              }
              .buttonStyle(.plain)
              .disabled(isCreating)
            }
          }
        } header: {
          Text("Suggested Names")
        }
        
        // MARK: - Validation Errors
        if showError && !errorMessage.isEmpty {
          Section {
            HStack {
              Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
              Text(errorMessage)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.red)
            }
          }
        }
      }
      .navigationTitle("New Chat Room")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .confirmationAction) {
          Button {
            Task {
              await createRoom()
            }
          } label: {
            if isCreating {
              ProgressView()
            } else {
              Text("Create")
            }
          }
          .disabled(!isValid || isCreating)
        }
      }
      .alert("Error", isPresented: $showError) {
        Button("OK", role: .cancel) {
          showError = false
        }
      } message: {
        Text(errorMessage)
      }
    }
  }

  // MARK: - Validation
  private var isValid: Bool {
    !roomName.trimmingCharacters(in: .whitespaces).isEmpty &&
    roomName.count >= 3
  }

  // MARK: - Actions
  private func createRoom() async {
    guard isValid else {
      errorMessage = "Room name must be at least 3 characters"
      showError = true
      return
    }

    isCreating = true
    showError = false

    do {
      // Get current user
      guard let currentUser = try await profileService.getCurrentUser() else {
        throw NSError(
          domain: "ChatRoomFormView",
          code: 1,
          userInfo: [NSLocalizedDescriptionKey: "Unable to get current user"]
        )
      }

      // Create conversation params
      let params = ConversationParams(
        title: roomName.trimmingCharacters(in: .whitespaces),
        userId: currentUser.id,
        agentId: nil
      )

      // Create conversation
      _ = try await chatServices.createConversation(params)

      // Success - dismiss the view
      dismiss()

    } catch {
      errorMessage = error.localizedDescription
      showError = true
      isCreating = false
    }
  }

  // MARK: - Suggested Names
  private let suggestions: [String] = [
    "Financial Goals 2025",
    "Debt Payoff Strategy",
    "Investment Portfolio Review",
    "Budget Planning Assistant",
    "Tax Optimization Helper",
    "Retirement Planning Coach"
  ]
}

#Preview {
  ChatRoomFormView()
}
