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
        ChatView(messages: data, didSendMessage: { draft in
          Task { @MainActor in
            await viewModel.sendMessage(draft)
          }
        })
      }
    }
    .background(AppTheme.Colors.background)
    .task {
      await viewModel.loadChatMessages()
      await viewModel.subscribeToMessages()
    }
    .navigationTitle("Chat Room")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarVisibility(.hidden, for: .tabBar)
  }
}
