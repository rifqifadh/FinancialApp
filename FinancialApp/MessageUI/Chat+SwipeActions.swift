//
//  Chat+SwipeActions.swift
//  ExpenseTracker
//
//  Created by Rifqi on 22/08/25.
//

import SwiftUI

protocol SwipeActionable {
    func render(type: ChatType) -> UIImage
    var action: (Message, @escaping (Message, DefaultMessageMenuAction) -> Void) -> Void { get }
    var activeFor: (Message) -> Bool { get }
    var background: Color? { get }
}

/// A simple container for both the leading and trailing swipe actions
struct ListSwipeActions {
    let leading: ListSwipeAction?
    let trailing: ListSwipeAction?
    
    init(leading: ListSwipeAction? = nil, trailing: ListSwipeAction? = nil) {
        self.leading = leading
        self.trailing = trailing
    }
}

/// A container for either leading or trailing swipe actions and wether they support fullSwipe actions
struct ListSwipeAction {
    let performsFirstActionWithFullSwipe: Bool
    let actions: [SwipeActionable]
}
