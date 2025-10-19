//
//  MessageRow.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 21/08/25.
//

public enum PositionInUserGroup { // group from the same user
    case first
    case middle
    case last
    case single // the only message in its group

    var isTop: Bool {
        self == .first || self == .single
    }
}

public enum PositionInMessagesSection { // messages within the same day
    case first
    case middle
    case last
    case single

    var isTop: Bool {
        self == .first || self == .single
    }
}

public enum PositionInSection {
    case first
    case middle
    case last
    case single // the only message in its section
}

public enum PositionInChat {
    case first
    case middle
    case last
    case single // the only message in the chat
}

struct MessageRow: Equatable {
    let message: Message
    let positionInUserGroup: PositionInUserGroup
    let positionInMessagesSection: PositionInMessagesSection
//    let commentsPosition: CommentsPosition?

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
        && lhs.positionInUserGroup == rhs.positionInUserGroup
        && lhs.positionInMessagesSection == rhs.positionInMessagesSection
//        && lhs.commentsPosition == rhs.commentsPosition
        && lhs.message.status == rhs.message.status
        && lhs.message.triggerRedraw == rhs.message.triggerRedraw
        && lhs.message.text == rhs.message.text
//        && lhs.message.reactions == rhs.message.reactions
    }
}

extension MessageRow: Identifiable {
    public typealias ID = String
    public var id: String {
        return message.id
    }
}
