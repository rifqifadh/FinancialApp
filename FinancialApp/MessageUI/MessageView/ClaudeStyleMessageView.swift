//
//  ClaudeStyleMessageView.swift
//  FinancialApp
//
//  Created by Rifqi on 08/12/25.
//

import SwiftUI

struct ClaudeStyleMessageView: View {
  @Environment(\.chatTheme) var theme

  let message: Message
  let avatarSize: CGFloat
  let showAvatar: Bool
  let showMessageTimeView: Bool
  let positionInUserGroup: PositionInUserGroup

  var shouldShowAvatar: Bool {
    showAvatar && (positionInUserGroup == .single || positionInUserGroup == .last)
  }

  var body: some View {
    HStack(alignment: .top, spacing: 0) {
      // Content - no avatar, no agent name, just clean text
      VStack(alignment: .leading, spacing: 6) {
        // Message text - no background, clean text
        Text(message.text)
          .font(.system(size: 15))
          .foregroundStyle(theme.colors.mainText)
          .textSelection(.enabled)
          .lineSpacing(4)

        // Timestamp
        if showMessageTimeView {
          Text(message.time)
            .font(.system(size: 11))
            .foregroundStyle(theme.colors.messageFriendTimeText.opacity(0.6))
            .padding(.top, 2)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Spacer(minLength: 0)
    }
    .padding(.horizontal, 16)
    .padding(.top, positionInUserGroup == .single || positionInUserGroup == .first ? 12 : 4)
    .padding(.bottom, positionInUserGroup == .single || positionInUserGroup == .last ? 12 : 4)
  }
}

#Preview {
  let monday = try! Date.iso8601Date.parse("2025-05-12")
  let agent = UserDataMessage(id: "agent", name: "Financial Assistant", avatarURL: nil, isCurrentUser: false)
  let user = UserDataMessage(id: "user", name: "You", avatarURL: nil, isCurrentUser: true)

  VStack(spacing: 0) {
    // User message with bubble
    MessageView(
      viewModel: .init(),
      message: Message(
        id: "0",
        user: user,
        status: .sent,
        createdAt: monday,
        text: "Can you help me create a budget?"
      ),
      avatarSize: 32,
      positionInUserGroup: .single,
      positionInMessagesSection: .single,
      showMessageTimeView: true,
      font: UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))
    )

    // AI response - clean, no avatar, no name
    ClaudeStyleMessageView(
      message: Message(
        id: "1",
        user: agent,
        status: .read,
        createdAt: monday,
        text: "Based on your spending patterns, I recommend setting aside 20% of your income for savings. This will help you build an emergency fund over the next 6 months."
      ),
      avatarSize: 32,
      showAvatar: false,
      showMessageTimeView: true,
      positionInUserGroup: .first
    )

    ClaudeStyleMessageView(
      message: Message(
        id: "2",
        user: agent,
        status: .read,
        createdAt: monday,
        text: "Here are three key steps to follow: 1) Track all expenses for 30 days, 2) Identify non-essential spending, 3) Set up automatic transfers to savings."
      ),
      avatarSize: 32,
      showAvatar: false,
      showMessageTimeView: true,
      positionInUserGroup: .middle
    )

    ClaudeStyleMessageView(
      message: Message(
        id: "3",
        user: agent,
        status: .read,
        createdAt: monday,
        text: "Would you like me to create a detailed savings plan for you?"
      ),
      avatarSize: 32,
      showAvatar: false,
      showMessageTimeView: true,
      positionInUserGroup: .last
    )
  }
  .environment(\.chatTheme, ChatTheme())
  .background(Color(UIColor.systemBackground))
}
