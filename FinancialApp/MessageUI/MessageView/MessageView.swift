//
//  MessageView.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 20/08/25.
//

import SwiftUI

struct MessageView: View {
  @Environment(\.chatTheme) var theme
  
  @Bindable var viewModel: ChatViewModel
  
  let message: Message
  let avatarSize: CGFloat
  let isDisplayingMessageMenu: Bool
  let messageLinkPreviewLimit: Int
  let messageStyler: (String) -> AttributedString
  let shouldShowLinkPreview: (URL) -> Bool
  let positionInUserGroup: PositionInUserGroup
  let positionInMessagesSection: PositionInMessagesSection
  let showMessageTimeView: Bool
  let shouldShowAvatar: Bool
  var font: UIFont
  
  init(
    viewModel: ChatViewModel,
    message: Message,
    avatarSize: CGFloat = 32,
    isDisplayingMessageMenu: Bool = false,
    messageLinkPreviewLimit: Int = 3,
    messageStyler: @escaping (String) -> AttributedString = { AttributedString($0) },
    shouldShowLinkPreview: @escaping (URL) -> Bool = { _ in true },
    positionInUserGroup: PositionInUserGroup = .single,
    positionInMessagesSection: PositionInMessagesSection = .single,
    showMessageTimeView: Bool = true,
    font: UIFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 12)),
    showAvatar: Bool = true
  ) {
    self.viewModel = viewModel
    self.message = message
    self.avatarSize = avatarSize
    self.isDisplayingMessageMenu = isDisplayingMessageMenu
    self.messageLinkPreviewLimit = messageLinkPreviewLimit
    self.messageStyler = messageStyler
    self.shouldShowLinkPreview = shouldShowLinkPreview
    self.positionInUserGroup = positionInUserGroup
    self.positionInMessagesSection = positionInMessagesSection
    self.showMessageTimeView = showMessageTimeView
    self.shouldShowAvatar = showAvatar
    self.font = font
  }
  
  @State var bubbleSize: CGSize = .zero
  @State var avatarViewSize: CGSize = .zero
  @State var timeSize: CGSize = .zero
  @State var statusSize: CGSize = .zero
  
  static let widthWithMedia: CGFloat = 204
  static let horizontalScreenEdgePadding: CGFloat = 12
  static let horizontalNoAvatarPadding: CGFloat = horizontalScreenEdgePadding / 2
  static let horizontalAvatarPadding: CGFloat = 8
  static let horizontalTextPadding: CGFloat = 12
  static let statusViewSize: CGFloat = 10
  static let horizontalStatusPadding: CGFloat = horizontalScreenEdgePadding / 2
  static let horizontalBubblePadding: CGFloat = 70
  
  enum DateArrangement {
    case hstack, vstack, overlay
  }
  
  var dateArrangement: DateArrangement {
    let timeWidth = timeSize.width + 10
    let textPaddings = MessageView.horizontalTextPadding * 2
    let widthWithoutMedia =
    UIScreen.main.bounds.width
    - (message.user.isCurrentUser
       ? MessageView.horizontalNoAvatarPadding : avatarViewSize.width)
    - statusSize.width
    - MessageView.horizontalBubblePadding
    - textPaddings
    
    let maxWidth =
    message.attachments.isEmpty
    ? widthWithoutMedia : MessageView.widthWithMedia - textPaddings
    let styledText = message.text.styled(using: messageStyler)
    
    let finalWidth = styledText.width(withConstrainedWidth: maxWidth, font: font)
    let lastLineWidth = styledText.lastLineWidth(labelWidth: maxWidth, font: font)
    let numberOfLines = styledText.numberOfLines(labelWidth: maxWidth, font: font)
    
    if !styledText.urls.isEmpty && messageLinkPreviewLimit > 0 {
      return .vstack
    }
    if numberOfLines == 1, finalWidth + CGFloat(timeWidth) < maxWidth {
      return .hstack
    }
    if lastLineWidth + CGFloat(timeWidth) < finalWidth {
      return .overlay
    }
    return .vstack
  }
  
  var showAvatar: Bool {
    shouldShowAvatar && (
      isDisplayingMessageMenu
      || positionInUserGroup == .single
      || (positionInUserGroup == .last)
    )
  }
  
  var topPadding: CGFloat {
//      if chatType == .comments { return 0 }
      return positionInUserGroup.isTop && !positionInMessagesSection.isTop ? 8 : 4
  }

  var bottomPadding: CGFloat {
    return 0
//      if chatType == .conversation { return 0 }
//      return positionInUserGroup.isTop ? 8 : 4
  }

  
  var body: some View {
    HStack {
      if !message.user.isCurrentUser {
        avatarView
      }
      
      
      
      VStack(alignment: message.user.isCurrentUser ? .trailing : .leading, spacing: 2) {
        //        if !isDisplayingMessageMenu, let replyMessage = message.replyMessage?.toMessage() {
        //
        //        }
        bubbleView(message)
      }
      if message.user.isCurrentUser, let status = message.status {
        MessageStatusView(status: status) {
          if case let .error(draft) = status {
            viewModel.sendMessage(draft)
          }
        }
        .sizeGetter($statusSize)
      }
    }
    .padding(.top, topPadding)
    .padding(.bottom, bottomPadding)
    .padding(.trailing, message.user.isCurrentUser ? MessageView.horizontalNoAvatarPadding : 0)
    .padding(
      message.user.isCurrentUser ? .leading : .trailing, MessageView.horizontalBubblePadding
    )
    .frame(
      maxWidth: UIScreen.main.bounds.width,
      alignment: message.user.isCurrentUser ? .trailing : .leading)
  }
  
  @ViewBuilder
  func bubbleView(_ message: Message) -> some View {
    VStack(
      alignment: message.user.isCurrentUser ? .leading : .trailing,
      spacing: -bubbleSize.height / 3
    ) {
      VStack(alignment: .leading, spacing: 0) {
        if !message.attachments.isEmpty {
          //                    attachmentsView(message)
        }
        
        if !message.text.isEmpty {
          textWithTimeView(message)
            .font(Font(font))
        }
      }
      .bubbleBackground(message, theme: theme)
      .zIndex(0)
    }
    .applyIf(isDisplayingMessageMenu) {
      $0.frameGetter($viewModel.messageFrame)
    }
  }
  
  
  
  @ViewBuilder
  var avatarView: some View {
    Group {
      if showAvatar {
        if let url = message.user.avatarURL {
          AvatarImageView(url: url, avatarSize: avatarSize)
            .contentShape(Circle())
            .onTapGesture {
              //              tapAvatarClosure?(message.user, message.id)
            }
        } else {
          AvatarNameView(name: message.user.name, avatarSize: avatarSize)
            .contentShape(Circle())
            .onTapGesture {
              //              tapAvatarClosure?(message.user, message.id)
            }
        }
        
      } else {
        Color.clear.viewSize(avatarSize)
      }
    }
    .padding(.leading, MessageView.horizontalScreenEdgePadding)
    .padding(.trailing, MessageView.horizontalAvatarPadding)
    .sizeGetter($avatarViewSize)
  }
  
  @ViewBuilder
  func textWithTimeView(_ message: Message) -> some View {
    let messageView = MessageTextView(
      text: message.text, messageStyler: messageStyler,
      userType: message.user.type, shouldShowLinkPreview: shouldShowLinkPreview,
      messageLinkPreviewLimit: messageLinkPreviewLimit
    )
      .fixedSize(horizontal: false, vertical: true)
      .padding(.horizontal, MessageView.horizontalTextPadding)
    
    let timeView = messageTimeView()
      .padding(.trailing, 12)
    
    Group {
      switch dateArrangement {
      case .hstack:
        HStack(alignment: .lastTextBaseline, spacing: 12) {
          messageView
          if !message.attachments.isEmpty {
            Spacer()
          }
          timeView
        }
        .padding(.vertical, 8)
      case .vstack:
        VStack(alignment: .trailing, spacing: 4) {
          messageView
          timeView
        }
        .padding(.vertical, 8)
      case .overlay:
        messageView
          .padding(.vertical, 8)
          .overlay(alignment: .bottomTrailing) {
            timeView
              .padding(.vertical, 8)
          }
      }
    }
  }
  
  func messageTimeView(needsCapsule: Bool = false) -> some View {
    Group {
      if showMessageTimeView {
//        if needsCapsule {
//          MessageTimeWithCapsuleView(
//            text: message.time, isCurrentUser: message.user.isCurrentUser,
//            chatTheme: theme)
//        } else {
          MessageTimeView(
            text: message.time, userType: message.user.type, chatTheme: theme)
//        }
      }
    }
    .sizeGetter($timeSize)
  }
}

extension View {
  
  @ViewBuilder
  func bubbleBackground(_ message: Message, theme: ChatTheme, isReply: Bool = false) -> some View
  {
    let radius: CGFloat = !message.attachments.isEmpty ? 12 : 20
    let additionalMediaInset: CGFloat = message.attachments.count > 1 ? 2 : 0
    self
      .frame(
        width: message.attachments.isEmpty
        ? nil : MessageView.widthWithMedia + additionalMediaInset
      )
      .foregroundColor(theme.colors.messageText(message.user.type))
      .background {
        if isReply || !message.text.isEmpty {
          RoundedRectangle(cornerRadius: radius)
            .foregroundColor(theme.colors.messageBG(message.user.type))
            .opacity(isReply ? theme.style.replyOpacity : 1)
        }
      }
      .cornerRadius(radius)
  }
}


#Preview("Message Row", traits: .sizeThatFitsLayout) {
  let stan = User(id: "stan", name: "Stan", avatarURL: nil, isCurrentUser: false)
  let john = User(id: "john", name: "John", avatarURL: nil, isCurrentUser: true)
  var shortText = "Hi, buddy!"
  var longText = "This is very long message to show in preview and for examples so i can see it."
  var replyedMessage = Message(
    id: UUID().uuidString,
    user: stan,
    status: .read,
    text: longText,
    replyMessage: nil
  )
  var message = Message(
    id: UUID().uuidString,
    user: stan,
    status: .read,
    text: shortText,
    replyMessage: replyedMessage.toReplyMessage()
  )
  
  MessageView(
    viewModel: .init(),
    message: message,
    avatarSize: 32,
    isDisplayingMessageMenu: false,
    messageLinkPreviewLimit: 3,
    messageStyler: AttributedString.init,
    shouldShowLinkPreview: { _ in true },
    positionInUserGroup: .single,
    positionInMessagesSection: .single,
    showMessageTimeView: true,
    font: UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))
  )
}

