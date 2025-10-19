//
//  ChatViewModel.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 21/08/25.
//

import Observation
import SwiftUI

@Observable
@MainActor final class ChatViewModel {
  /// The messages frame that is currently being rendered in the Message Menu
  /// - Note: Used to further refine a messages frame (instead of using the cell boundary), mainly used for positioning reactions
  var messageFrame: CGRect = .zero
  var messageMenuRow: MessageRow?
  
  /// Provides a mechanism to issue haptic feedback to the user
  /// - Note: Used when launching the MessageMenu
  
  let inputFieldId = UUID()
  var globalFocusState: GlobalFocusState?
  private(set) var inputViewModel: InputViewModel?
  
  func sendMessage(_ message: DraftMessage) {
  }
  
  func messageMenuAction() -> (Message, DefaultMessageMenuAction) -> Void {
    { message, action in
        self.messageMenuActionInternal(message: message, action: action)
    }
  }
  
  func messageMenuActionInternal(message: Message, action: DefaultMessageMenuAction) {
    switch action {
    case .copy:
      UIPasteboard.general.string = message.text
    case .reply:
//      inputViewModel?.attachments.replyMessage = message.toReplyMessage()
      globalFocusState?.focus = .uuid(inputFieldId)
    case .edit(let saveClosure):
//      inputViewModel?.text = message.text
//      inputViewModel?.edit(saveClosure)
      globalFocusState?.focus = .uuid(inputFieldId)
    }
  }
}
