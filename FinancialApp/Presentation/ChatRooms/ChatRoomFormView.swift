//
//  ChatRoomFormView.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import SwiftUI

struct ChatRoomFormView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var roomName = ""
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
          }
          .padding(.vertical, 4)
        } header: {
          Text("Chat Room Details")
        } footer: {
          Text("Choose a descriptive name for your chat room")
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.tertiaryText)
        }
        
        // MARK: - Suggestions Section
        Section {
          VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            ForEach(suggestedRoomNames, id: \.self) { suggestion in
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
          Button("Create") {
            createRoom()
          }
          .disabled(!isValid)
        }
      }
      .alert("Success", isPresented: $showSuccessAlert) {
        Button("OK") {
          dismiss()
        }
      } message: {
        Text("Chat room '\(roomName)' has been created successfully!")
      }
    }
  }
  
  // MARK: - Validation
  private var isValid: Bool {
    !roomName.trimmingCharacters(in: .whitespaces).isEmpty &&
    roomName.count >= 3
  }
  
  @State private var showSuccessAlert = false
  
  // MARK: - Actions
  private func createRoom() {
    guard isValid else {
      showError = true
      errorMessage = "Room name must be at least 3 characters"
      return
    }
    
    // Mock creation - no actual API call
    showSuccessAlert = true
  }
  
  // MARK: - Suggested Room Names
  private let suggestedRoomNames = [
    "Financial Goals 2025",
    "Debt Payoff Strategy",
    "Side Hustle Ideas",
    "Expense Tracking Tips",
    "Investment Portfolio Review",
    "Savings Challenge"
  ]
}

#Preview {
  ChatRoomFormView()
}
