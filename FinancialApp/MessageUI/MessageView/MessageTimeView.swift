//
//  MessageTimeView.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 21/08/25.
//

import SwiftUI

struct MessageTimeView: View {
  
  let text: String
  let userType: UserMessageType
  var chatTheme: ChatTheme
  
  var body: some View {
    Text(text)
      .font(.caption)
      .foregroundColor(chatTheme.colors.messageTimeText(userType))
  }
}

struct MessageTimeWithCapsuleView: View {
  
  let text: String
  let isCurrentUser: Bool
  var chatTheme: ChatTheme
  
  var body: some View {
    Text(text)
      .font(.caption)
      .foregroundColor(.white)
      .opacity(0.8)
      .padding(.top, 4)
      .padding(.bottom, 4)
      .padding(.horizontal, 8)
      .background {
        Capsule()
          .foregroundColor(.black.opacity(0.4))
      }
  }
}

