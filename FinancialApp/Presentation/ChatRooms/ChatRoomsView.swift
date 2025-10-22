//
//  ChatRoomsView.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import SwiftUI
import Dependencies

struct ChatRoomsView: View {
  @Environment(RouterPath.self) private var routerPath
  @Dependency(\.chatServices) private var chatServices
  
  @State private var showingAddRoom = false
  @State private var searchText = ""

  // Mock data
  @State private var chatRooms: [ChatRoom] = []

  var filteredChatRooms: [ChatRoom] {
    if searchText.isEmpty {
      return chatRooms
    } else {
      return chatRooms.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
  }

  var body: some View {
    ScrollView {
      VStack(spacing: AppTheme.Spacing.md) {
        if filteredChatRooms.isEmpty {
          emptyStateView
        } else {
          ForEach(filteredChatRooms) { room in
            ChatRoomCard(room: room) {
              // Handle tap - navigate to chat detail
              routerPath.navigate(to: .chatRoom(id: room.id))
            }
          }
        }
      }
      .padding(.horizontal)
      .padding(.vertical)
    }
    .task {
      do {
        chatRooms = try await chatServices.fetchRooms()
      } catch {
        print("Error fetching chat rooms: \(error)")
      }
    }
    .background(AppTheme.Colors.background)
    .navigationTitle("Chat Rooms")
    .searchable(text: $searchText, prompt: "Search chat rooms")
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          showingAddRoom = true
        } label: {
          Image(systemName: "plus.circle.fill")
            .font(.system(size: 20))
            .foregroundStyle(AppTheme.Colors.accent)
        }
      }
    }
    .sheet(isPresented: $showingAddRoom) {
      ChatRoomFormView()
    }
  }

  // MARK: - Empty State View
  private var emptyStateView: some View {
    VStack(spacing: AppTheme.Spacing.lg) {
      Image(systemName: "bubble.left.and.bubble.right")
        .font(.system(size: 64))
        .foregroundStyle(AppTheme.Colors.tertiaryText)

      VStack(spacing: AppTheme.Spacing.sm) {
        Text("No Chat Rooms Found")
          .font(AppTheme.Typography.financialLarge)
          .foregroundStyle(AppTheme.Colors.primaryText)

        Text("Try adjusting your search or create a new chat room")
          .font(AppTheme.Typography.body)
          .foregroundStyle(AppTheme.Colors.secondaryText)
          .multilineTextAlignment(.center)
      }

      Button {
        showingAddRoom = true
      } label: {
        Label("New Chat Room", systemImage: "plus.circle.fill")
          .font(AppTheme.Typography.bodyBold)
          .foregroundStyle(.white)
          .padding(.horizontal, AppTheme.Spacing.lg)
          .padding(.vertical, AppTheme.Spacing.md)
          .background(AppTheme.Colors.accent)
          .cornerRadius(AppTheme.CornerRadius.medium)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.top, 100)
  }
}

// MARK: - Chat Room Card
struct ChatRoomCard: View {
  let room: ChatRoom
  let onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      HStack(spacing: AppTheme.Spacing.md) {
        // Icon
        ZStack {
          Circle()
            .fill(AppTheme.Colors.accent.opacity(0.1))
            .frame(width: 52, height: 52)

          Image(systemName: "bubble.left.and.bubble.right.fill")
            .font(.system(size: 22, weight: .semibold))
            .foregroundStyle(AppTheme.Colors.accent)
        }

        // Room Info
        VStack(alignment: .leading, spacing: 4) {
          Text(room.name)
            .font(AppTheme.Typography.bodyBold)
            .foregroundStyle(AppTheme.Colors.primaryText)
            .lineLimit(1)

          if let createdAt = room.createdAt {
            Text(formatDate(createdAt))
              .font(AppTheme.Typography.caption)
              .foregroundStyle(AppTheme.Colors.tertiaryText)
          }
        }

        Spacer()

        // Chevron
        Image(systemName: "chevron.right")
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(AppTheme.Colors.tertiaryText)
      }
      .padding(AppTheme.Spacing.md)
      .background(AppTheme.Colors.cardBackground)
      .cornerRadius(AppTheme.CornerRadius.medium)
      .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
    .buttonStyle(.plain)
  }

  private func formatDate(_ date: Date) -> String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter.localizedString(for: date, relativeTo: Date())
  }
}

#Preview {
  NavigationStack {
    ChatRoomsView()
  }
}
