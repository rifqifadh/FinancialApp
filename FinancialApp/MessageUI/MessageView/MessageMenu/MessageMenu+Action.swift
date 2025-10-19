//
//  MessageMenu+Action.swift
//  Chat
//

import SwiftUI

protocol MessageMenuAction: Equatable, CaseIterable {
  func title() -> String
  func icon() -> Image
  
  static func menuItems(for message: Message) -> [Self]
}

extension MessageMenuAction {
  public static func menuItems(for message: Message) -> [Self] {
    Self.allCases.map { $0 }
  }
}

enum DefaultMessageMenuAction: MessageMenuAction, Sendable {
  
  case copy
  case reply
  case edit(saveClosure: @Sendable (String) -> Void)
  
  func title() -> String {
    switch self {
    case .copy:
      "Copy"
    case .reply:
      "Reply"
    case .edit:
      "Edit"
    }
  }
  
  func icon() -> Image {
    switch self {
    case .copy:
      Image(systemName: "doc.on.doc")
    case .reply:
      Image(systemName: "arrowshape.turn.up.left")
    case .edit:
      Image(systemName: "bubble.and.pencil")
    }
  }
  
  nonisolated  static func == (lhs: DefaultMessageMenuAction, rhs: DefaultMessageMenuAction) -> Bool {
    switch (lhs, rhs) {
    case (.copy, .copy),
      (.reply, .reply),
      (.edit(_), .edit(_)):
      return true
    default:
      return false
    }
  }
  
  static let allCases: [DefaultMessageMenuAction] = [
    .copy, .reply, .edit(saveClosure: {_ in})
  ]
  
  static  func menuItems(for message: Message) -> [DefaultMessageMenuAction] {
    if message.user.isCurrentUser {
      return allCases
    } else {
      return [.copy, .reply]
    }
  }
}
