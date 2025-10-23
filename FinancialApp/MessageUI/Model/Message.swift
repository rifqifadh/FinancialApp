//
//  MessageModel.swift
//  ExpenseTracker
//
//  Created by Rifqi on 19/07/25.
//

import Foundation

struct Message: Identifiable, Equatable, Sendable, Hashable {
  
  public enum Status: Equatable, Hashable, Sendable {
    case sending
    case sent
    case read
    case error(DraftMessage)
    
    public func hash(into hasher: inout Hasher) {
      switch self {
      case .sending:
        return hasher.combine("sending")
      case .sent:
        return hasher.combine("sent")
      case .read:
        return hasher.combine("read")
      case .error:
        return hasher.combine("error")
      }
    }
    
    public static func == (lhs: Message.Status, rhs: Message.Status) -> Bool {
      switch (lhs, rhs) {
      case (.sending, .sending):
        return true
      case (.sent, .sent):
        return true
      case (.read, .read):
        return true
      case ( .error(_), .error(_)):
        return true
      default:
        return false
      }
    }
  }
  
  public var id: String
  public var user: User
  public var status: Status?
  public var createdAt: Date
  
  public var text: String
  public var attachments: [Attachment]
  //    public var reactions: [Reaction]
  //    public var giphyMediaId: String?
  //    public var recording: Recording?
  public var replyMessage: ReplyMessage?
  
  public var triggerRedraw: UUID?
  
  public init(id: String,
              user: User,
              status: Status? = nil,
              createdAt: Date = Date(),
              text: String = "",
              attachments: [Attachment] = [],
              //                giphyMediaId: String? = nil,
              //                reactions: [Reaction] = [],
              //                recording: Recording? = nil,
              replyMessage: ReplyMessage? = nil) {
    
    self.id = id
    self.user = user
    self.status = status
    self.createdAt = createdAt
    self.text = text
    self.attachments = attachments
    //        self.giphyMediaId = giphyMediaId
    //        self.reactions = reactions
    //        self.recording = recording
    self.replyMessage = replyMessage
  }
}

extension MessageResponse {
  func toMessage(currentUserId: String) -> Message {
    return Message(
      id: id,
      user: .init(id: id, name: "-", avatarURL: nil, type: self.role == "user" ? .current : .other),
      status: .read,
      createdAt: self.createdAt ?? Date(),
      text: self.content,
      attachments: []
      
    )
  }
}

extension Message {
  var time: String {
    DateFormatter.timeFormatter.string(from: createdAt)
  }
}

public struct ReplyMessage: Codable, Identifiable, Hashable, Sendable {
  public static func == (lhs: ReplyMessage, rhs: ReplyMessage) -> Bool {
    lhs.id == rhs.id &&
    lhs.user == rhs.user &&
    lhs.createdAt == rhs.createdAt &&
    lhs.text == rhs.text &&
    lhs.attachments == rhs.attachments
    //        lhs.recording == rhs.recording
  }
  
  public var id: String
  public var user: User
  public var createdAt: Date
  
  public var text: String
  public var attachments: [Attachment]
  //    public var recording: Recording?
  
  public init(id: String,
              user: User,
              createdAt: Date,
              text: String = "",
              attachments: [Attachment] = []
              //                recording: Recording? = nil
  ) {
    
    self.id = id
    self.user = user
    self.createdAt = createdAt
    self.text = text
    self.attachments = attachments
    //        self.recording = recording
  }
  
  func toMessage() -> Message {
    Message(id: id, user: user, createdAt: createdAt, text: text, attachments: attachments)
  }
}

extension Message {
  func toReplyMessage() -> ReplyMessage {
    ReplyMessage(id: id, user: user, createdAt: createdAt, text: text, attachments: attachments)
  }
}
