//
//  ChatRoomView.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import SwiftUI

let mockMessages = [Message(id: "2", user: .init(id: "1", name: "asd", avatarURL: nil, isCurrentUser: true), status: .sent, text: "LJLKJASF")]


struct ChatRoomView: View {
  let id: Int
  
  @State private var viewModel: ChatRoomViewModel
  @State private var messages: [Message] = mockMessages
  
  init(id: Int) {
    self.id = id
    self.viewModel = ChatRoomViewModel(id: id)
  }
  
  var body: some View {
    VStack {
      ViewStateView(state: viewModel.chatMessagesState) { data in
        ChatView(messages: data, didSendMessage: { draft in
          Task { @MainActor in
            await viewModel.sendMessage(draft)
          }
        })
      }
    }
    .task {
      await viewModel.loadChatMessages()
      await viewModel.subscribeToMessages()
    }
    .navigationTitle("Chat Room")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  ChatRoomView(id: 1)
    .environment(\.chatTheme, ChatTheme())
}
