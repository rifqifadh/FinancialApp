//
//  ChatView.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 21/08/25.
//

import SwiftUI

public enum ChatType: CaseIterable, Sendable {
  case conversation // the latest message is at the bottom, new messages appear from the bottom
  case comments // the latest message is at the top, new messages appear from the top
}


public enum ReplyMode: CaseIterable, Sendable {
    case quote // when replying to message A, new message will appear as the newest message, quoting message A in its body
    case answer // when replying to message A, new message with appear direclty below message A as a separate cell without duplicating message A in its body
}

struct ChatView<MessageContent: View, InputViewContent: View, MenuAction: MessageMenuAction>: View {
  
  /// To build a custom message view use the following parameters passed by this closure:
  /// - message containing user, attachments, etc.
  /// - position of message in its continuous group of messages from the same user
  /// - position of message in the section of messages from that day
  /// - position of message in its continuous group of comments (only works for .answer ReplyMode, nil for .quote mode)
  /// - closure to show message context menu
  /// - closure to pass user interaction, .reply for example
  /// - pass attachment to this closure to use ChatView's fullscreen media viewer
  public typealias MessageBuilderClosure = ((
    _ message: Message,
    _ positionInGroup: PositionInUserGroup,
    _ positionInMessagesSection: PositionInMessagesSection,
//    _ positionInCommentsGroup: CommentsPosition?,
    _ showContextMenuClosure: @escaping () -> Void,
    _ messageActionClosure: @escaping (Message, DefaultMessageMenuAction) -> Void,
    _ showAttachmentClosure: @escaping (Attachment) -> Void
  ) -> MessageContent)
  
  /// To build a custom input view use the following parameters passed by this closure:
      /// - binding to the text in input view
      /// - InputViewAttachments to store the attachments from external pickers
      /// - current input view state: .message for main input view mode and .signature for input view in media picker mode
      /// - closure to pass user interaction, .recordAudioTap for example
      /// - dismiss keyboard closure
      public typealias InputViewBuilderClosure = (
          _ text: Binding<String>
//          _ attachments: InputViewAttachments,
//          _ inputViewState: InputViewState,
//          _ inputViewStyle: InputViewStyle,
//          _ inputViewActionClosure: @escaping (InputViewAction) -> Void,
//          _ dismissKeyboardClosure: ()->()
      ) -> InputViewContent
  
  /// To define custom message menu actions declare an enum conforming to MessageMenuAction. The library will show your custom menu options on long tap on message. Once the action is selected the following callback will be called:
      /// - action selected by the user from the menu. NOTE: when declaring this variable, specify its type (your custom descendant of MessageMenuAction) explicitly
      /// - a closure taking a case of default implementation of MessageMenuAction which provides simple actions handlers; you call this closure passing the selected message and choosing one of the default actions if you need them; or you can write a custom implementation for all your actions, in that case just ignore this closure
      /// - message for which the menu is displayed
      /// When implementing your own MessageMenuActionClosure, write a switch statement passing through all the cases of your MessageMenuAction, inside each case write your own action handler, or call the default one. NOTE: not all default actions work out of the box - e.g. for .edit you'll still need to provide a closure to save the edited text on your BE. Please see CommentsExampleView in ChatExample project for MessageMenuActionClosure usage example.
      public typealias MessageMenuActionClosure = (
          _ selectedMenuAction: MenuAction,
          _ defaultActionClosure: @escaping (Message, DefaultMessageMenuAction) -> Void,
          _ message: Message
      ) -> Void
  
  @Environment(\.chatTheme) private var theme
  
  @Bindable var viewModel: ChatViewModel = .init()
  @Bindable var inputViewModel: InputViewModel = .init()
  
  // MARK: - Parameters
  
  let sections: [MessagesSection]
  let type: ChatType
  let ids: [String]
  let didSendMessage: (DraftMessage) -> Void
  
  // MARK: - View builders
      
  /// provide custom message view builder
  var messageBuilder: MessageBuilderClosure? = nil
  
  /// provide custom input view builder
  var inputViewBuilder: InputViewBuilderClosure? = nil
  
  /// message menu customization: create enum complying to MessageMenuAction and pass a closure processing your enum cases
  var messageMenuAction: MessageMenuActionClosure?
  
  // MARK: - Customization
  
  var showDateHeaders: Bool = true
  var isScrollEnabled: Bool = true
  var avatarSize: CGFloat = 32
  var showMessageMenuOnLongPress: Bool = true
  var messageStyler: (String) -> AttributedString = AttributedString.init
  var shouldShowLinkPreview: (URL) -> Bool = { _ in true }
  var showMessageTimeView = true
  var messageLinkPreviewLimit = 8
  var messageFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))
  var paginationHandler: PaginationHandler?
  var listSwipeActions: ListSwipeActions = ListSwipeActions()
  
  @State private var isScrolledToBottom: Bool = true
  @State private var shouldScrollToTop: () -> () = {}
  
  /// Used to prevent the MainView from responding to keyboard changes while the Menu is active
  @State private var isShowingMenu = false
  
  @State private var tableContentHeight: CGFloat = 0
  @State private var inputViewSize = CGSize.zero
  @State private var cellFrames = [String: CGRect]()
  
  public init(messages: [Message], messageBuilder: @escaping MessageBuilderClosure) {
    self.sections = ChatView.mapMessages(messages, chatType: .conversation, replyMode: .answer)
//    self.messageBuilder = messageBuilder
    self.ids = messages.map { $0.id }
    self.type = .conversation
    self.didSendMessage = { _ in }
  }
  
  var body: some View {
    mainView
  }
  
  var mainView: some View {
    list
  }
  
  @ViewBuilder
  var list: some View {
   UIList(
    viewModel: viewModel,
    inputViewModel: inputViewModel,
    isScrolledToBottom: $isScrolledToBottom,
    shouldScrollToTop: $shouldScrollToTop,
    tableContentHeight: $tableContentHeight,
    messageBuilder: messageBuilder,
    inputView: inputView,
    type: type,
    showDateHeaders: showDateHeaders,
    isScrollEnabled: isScrollEnabled,
    avatarSize: avatarSize,
    showMessageMenuOnLongPress: showMessageMenuOnLongPress,
    paginationHandler: paginationHandler,
    messageStyler: messageStyler,
    shouldShowLinkPreview: shouldShowLinkPreview,
    showMessageTimeView: showMessageTimeView,
    messageLinkPreviewLimit: messageLinkPreviewLimit,
    messageFont: messageFont,
    sections: sections,
    ids: ids,
    listSwipeActions: listSwipeActions
   )
   .applyIf(!isScrollEnabled) {
     $0.frame(height: tableContentHeight)
   }
  }
  
  var inputView: some View {
//          Group {
//              if let inputViewBuilder = inputViewBuilder {
//                  inputViewBuilder($inputViewModel.text, inputViewModel.attachments, inputViewModel.state, .message, inputViewModel.inputViewAction()) {
//                      globalFocusState.focus = nil
//                  }
//              } else {
//                  InputView(
//                      viewModel: inputViewModel,
//                      inputFieldId: viewModel.inputFieldId,
//                      style: .message,
//                      availableInputs: availableInputs,
//                      messageStyler: messageStyler,
//                      recorderSettings: recorderSettings,
//                      localization: localization
//                  )
//              }
//          }
    Text("Placeholder")
          .sizeGetter($inputViewSize)
//          .environmentObject(globalFocusState)
//          .onAppear(perform: inputViewModel.onStart)
//          .onDisappear(perform: inputViewModel.onStop)
      }
}

extension ChatView where MessageContent == EmptyView, InputViewContent == EmptyView, MenuAction == DefaultMessageMenuAction {

    init(messages: [Message],
//         chatType: ChatType = .conversation,
//         replyMode: ReplyMode = .quote,
//         didSendMessage: @escaping (DraftMessage) -> Void,
//         reactionDelegate: ReactionDelegate? = nil,
//         messageMenuAction: MessageMenuActionClosure?
    ) {
//        self.type = chatType
//        self.didSendMessage = didSendMessage
//        self.reactionDelegate = reactionDelegate
      self.sections = ChatView.mapMessages(messages, chatType: .conversation, replyMode: .quote)
      self.ids = messages.map { $0.id }
      self.type = .conversation
      self.didSendMessage = { _ in }
//        self.messageMenuAction = messageMenuAction
    }
}


#Preview {
  let romeo = User(id: "romeo", name: "Romeo Montague", avatarURL: nil, isCurrentUser: true)
  let juliet = User(id: "juliet", name: "Juliet Capulet", avatarURL: nil, isCurrentUser: false)
  
  let monday = try! Date.iso8601Date.parse("2025-05-12")
  let tuesday = try! Date.iso8601Date.parse("2025-05-13")
  
  ChatView(
    messages: [
      Message(
        id: "26tb", user: romeo, status: .read, createdAt: monday,
        text: "And I’ll still stay, to have thee still forgetdd"),
      Message(
        id: "zee6", user: romeo, status: .read, createdAt: monday,
        text: "Forgetting any other home but this"),
      Message(
        id: "oWUN", user: juliet, status: .read, createdAt: monday,
        text: "’Tis almost morning. I would have thee gone"),
      Message(
        id: "P261", user: juliet, status: .read, createdAt: monday,
        text: "And yet no farther than a wanton’s bird"),
      Message(
        id: "46hu", user: juliet, status: .sending, createdAt: monday,
        text: "That lets it hop a little from his hand"),
      Message(
        id: "Gjbm", user: juliet, status: .read, createdAt: monday,
        text: "Like a poor prisoner in his twisted gyves"),
      Message(
        id: "IhRQ", user: juliet, status: .read, createdAt: monday,
        text: "And with a silken thread plucks it back again"),
      Message(
        id: "kwWd", user: juliet, status: .read, createdAt: monday,
        text: "So loving-jealous of his liberty"),
      
      Message(
        id: "9481", user: romeo, status: .read, createdAt: tuesday,
        text: "I would I were thy bird"),
      
      Message(
        id: "dzmY", user: juliet, status: .sent, createdAt: tuesday, text: "Sweet, so would I"),
      Message(
        id: "r5HH", user: juliet, status: .sent, createdAt: tuesday,
        text: "Yet I should kill thee with much cherishing"),
      Message(
        id: "quy1", user: juliet, status: .sent, createdAt: tuesday,
        text: "Good night, good night. Parting is such sweet sorrow"),
      Message(
        id: "Mwh6", user: juliet, status: .sent, createdAt: tuesday,
        text: "That I shall say 'Good night' till it be morrow"),
    ]
  )
}
