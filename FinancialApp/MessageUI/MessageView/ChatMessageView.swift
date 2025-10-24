//
//  ChatMessageView.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 21/08/25.
//

import SwiftUI

struct ChatMessageView: View {
  @Bindable var viewModel: ChatViewModel
  
  let row: MessageRow
  let chatType: ChatType
  let avatarSize: CGFloat
  //      let tapAvatarClosure: ChatView.TapAvatarClosure?
  let messageStyler: (String) -> AttributedString
  let shouldShowLinkPreview: (URL) -> Bool
  let isDisplayingMessageMenu: Bool
  let showMessageTimeView: Bool
  let messageLinkPreviewLimit: Int
  let messageFont: UIFont
  
  
  var body: some View {
    MessageView(
      viewModel: viewModel,
      message: row.message,
      avatarSize: avatarSize,
      isDisplayingMessageMenu: isDisplayingMessageMenu,
      messageLinkPreviewLimit: messageLinkPreviewLimit,
      messageStyler: messageStyler,
      shouldShowLinkPreview: shouldShowLinkPreview,
      positionInUserGroup: row.positionInUserGroup,
      positionInMessagesSection: row.positionInMessagesSection,
      showMessageTimeView: showMessageTimeView,
      font: messageFont
    )
  }
}

#Preview {
  let monday = try! Date.iso8601Date.parse("2025-05-12")
  let romeo = UserDataMessage(id: "romeo", name: "Romeo Montague", avatarURL: nil, isCurrentUser: true)
  let john = UserDataMessage(id: "john", name: "John", avatarURL: nil, isCurrentUser: false)
  let message = Message(
    id: "26tb", user: romeo, status: .read, createdAt: monday,
    text: "And I’ll still stay, to have thee still forget")
  
  let messagess = Message(
    id: "26tb2", user: john, status: .read, createdAt: monday,
    text: "And  i want this to be long eniuy")
  
  
  VStack {
    MessageView(
      viewModel: .init(),
      message: message,
      avatarSize: 22,
      isDisplayingMessageMenu: false,
      messageLinkPreviewLimit: 3,
      messageStyler: AttributedString.init,
      shouldShowLinkPreview: { _ in true },
      positionInUserGroup: .last,
      positionInMessagesSection: .last,
      showMessageTimeView: true,
      font: UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))
    )
    
    MessageView(
      viewModel: .init(),
      message: messagess,
      avatarSize: 22,
      isDisplayingMessageMenu: false,
      messageLinkPreviewLimit: 3,
      messageStyler: AttributedString.init,
      shouldShowLinkPreview: { _ in true },
      positionInUserGroup: .last,
      positionInMessagesSection: .last,
      showMessageTimeView: true,
      font: UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))
    )
  }
  
  
  
//  ChatMessageView(viewModel: .init(), row: MessageRow(message: message, positionInUserGroup: .first, positionInMessagesSection: .first), chatType: .conversation, avatarSize: 32, messageStyler: AttributedString.init, shouldShowLinkPreview: { _ in true }, isDisplayingMessageMenu: true, showMessageTimeView: true, messageLinkPreviewLimit: 3, messageFont: UIFont.systemFont(ofSize: 145))
}
