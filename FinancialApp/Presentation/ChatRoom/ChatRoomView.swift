//
//  ChatRoomView.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import SwiftUI

struct ChatRoomView: View {
  let id: String
  
  @State private var viewModel: ChatRoomViewModel
  
  init(id: String) {
    self.id = id
    self.viewModel = ChatRoomViewModel(id: id)
  }
  
  var body: some View {
    VStack {
      ViewStateView(state: viewModel.chatMessagesState) { data in
        ChatView(messages: data) { draft in
          Task {
            await viewModel.sendMessage(draft)
          }
        }
      } emptyView: {
        ChatView(messages: []) { draft in
          
        }
      }
    }
    .task {
      await viewModel.loadChatMessages()
      await viewModel.subscribeToMessages()
    }
    .navigationTitle("Chat Room")
  }
}

#Preview {
  ChatRoomView(id: "1")
    .environment(\.chatTheme, ChatTheme())
}
