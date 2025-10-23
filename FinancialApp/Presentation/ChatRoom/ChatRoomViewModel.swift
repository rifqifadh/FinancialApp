//
//  ChatRoomViewModel.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import Observation
import Dependencies
import Foundation

@MainActor
@Observable final class ChatRoomViewModel {
  @ObservationIgnored
  @Dependency(\.chatServices) private var chatServices
  
  @ObservationIgnored
  @Dependency(\.profileService) private var profileService
  
  var chatMessagesState: ViewState<[Message]> = .idle
  var id: String
  
  init(id: String) {
    self.id = id
  }
  
  func loadChatMessages() async {
    do {
      chatMessagesState = .loading
      let messages = try await chatServices.fetchMessages(id)
      let formattedM = messages.data?.map { $0.toMessage() } ?? []
      chatMessagesState = .success(formattedM)
    } catch {
      chatMessagesState = .error(error)
    }
  }
  
  func sendMessage(_ draft: DraftMessage) async {
    var data = chatMessagesState.getData() ?? []
    
//    do {
//      let currentUser = try await profileService.getCurrentUser()
//      let params = createMessageParams(from: draft, userId: currentUser?.id ?? "", name: currentUser?.fullName ?? "" )
//      let result = try await chatServices.sendMessage(params)
//      if let responseData = result.data {
//        data.append(responseData.toMessage())
//        chatMessagesState = .success(data)
//      }
//    } catch {
//      print("Error sending message: \(error)")
//    }
  }
  
  private func createMessageParams(from draft: DraftMessage, userId: String, name: String) -> MessageParams {
    MessageParams(userId: userId, channelId: id, name: name, content: draft.text)
  }
  
  func subscribeToMessages() async {
//    for await (message, status) in chatServices.subscribeToMessagesWithStatus(id) {
//      if let status = status {
//        print("Channel subscription status: \(status)")
//        //          if status == .subscribed {
//        //            isLoading = false
//        //          }
//      }
//      
//      if let message {
//        if message.role != "user" {
//          var data = chatMessagesState.getData() ?? []
//          data.append(message.toMessage())
//          chatMessagesState = .success(data)
//        }
//      }
//    }
  }
}

extension MessageResponse {
  func toMessage() -> Message {
    Message(
      id: self.id,
      user: .init(id: id, name: "-", avatarURL: nil, type: self.role == "user" ? .current : .other),
      text: self.content
    )
  }
}

extension BaseResponse where TData == [MessageResponse] {
  func toMessages() -> [Message] {
    self.data?.map {
      $0.toMessage()
    } ?? []
  }
}
