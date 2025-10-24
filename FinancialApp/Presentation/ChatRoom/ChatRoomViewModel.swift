//  ChatRoomViewModel.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import Observation
import Dependencies
import Foundation
import Realtime

@MainActor
@Observable final class ChatRoomViewModel {
  @ObservationIgnored
  @Dependency(\.chatServices) private var chatServices
  
  @ObservationIgnored
  @Dependency(\.profileService) private var profileService
  
  var chatMessagesState: ViewState<[Message]> = .idle
  var id: String
  var channelStatus: RealtimeChannelStatus?
  
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
    let tempId = UUID().uuidString
    
    // Add the message with 'sending' status
    let tempMessage = draftToMessage(draft, tempId: tempId)
    chatMessagesState.append(tempMessage)
    
    do {
      let currentUser = try await profileService.getCurrentUser()
      let params = createMessageParams(from: draft, userId: currentUser?.id ?? "", name: currentUser?.fullName ?? "" )
      let result = try await chatServices.sendMessage(params)
      
      if let data = result.data {
        // Update the temporary message with the real message data and 'sent' status
        chatMessagesState.updateElement(withId: tempId) { message in
          message.id = data.id
          message.status = .sent
          message.createdAt = data.createdAt ?? Date()
          // Update any other properties if needed
        }
      } else {
        // If no data returned, just update status to sent
        chatMessagesState.updateElement(withId: tempId) { message in
          message.status = .sent
        }
      }
    } catch {
      print("Error sending message: \(error)")
      
      // Update message status to error
      chatMessagesState.updateElement(withId: tempId) { message in
        message.status = .error(draft)
      }
    }
  }
  
  private func createMessageParams(from draft: DraftMessage, userId: String, name: String) -> MessageParams {
    return MessageParams(
      conversationId: id,
      role: .user,
      content: draft.text,
      userId: userId
    )
  }
  
  private func draftToMessage(_ draft: DraftMessage, tempId: String) -> Message {
    Message(
      id: tempId,
      user: .init(id: "current_user_id", name: "Current User", avatarURL: nil, type: .current),
      status: .sending,
      text: draft.text
    )
  }
  
  func retryMessage(messageId: String) async {
    guard let messages = chatMessagesState.getData(),
          let message = messages.first(where: { $0.id == messageId }),
          case .error(let draft) = message.status else {
      return
    }
    
    // Update message status back to sending
    chatMessagesState.updateElement(withId: messageId) { message in
      message.status = .sending
    }
    
    // Retry sending the message
    do {
      let currentUser = try await profileService.getCurrentUser()
      let params = createMessageParams(from: draft, userId: currentUser?.id ?? "", name: currentUser?.fullName ?? "")
      let result = try await chatServices.sendMessage(params)
      
      if let data = result.data {
        // Update with successful data
        chatMessagesState.updateElement(withId: messageId) { message in
          message.id = data.id
          message.status = .sent
          message.createdAt = data.createdAt ?? Date()
        }
      } else {
        chatMessagesState.updateElement(withId: messageId) { message in
          message.status = .sent
        }
      }
    } catch {
      print("Error retrying message: \(error)")
      // Set back to error status
      chatMessagesState.updateElement(withId: messageId) { message in
        message.status = .error(draft)
      }
    }
  }
  
  func subscribeToMessages() async {
    for await (message, status) in chatServices.subscribeToInsertions(id) {
      channelStatus = status
      
      if let message {
        if message.role != "user" {
          var data = chatMessagesState.getData() ?? []
          data.append(message.toMessage())
          chatMessagesState = .success(data)
        }
      }
    }
  }

}

extension MessageResponse {
  func toMessage(status: Message.Status = .sent) -> Message {
    if (role == "n8n-agent") {
      return self.toAgentMessage()
    }
    return Message(
      id: self.id,
      user: .init(id: id, name: "", avatarURL: nil, type: self.role == "user" ? .current : .other),
      status: status,
      text: self.content,
    )
  }
}

extension MessageResponse {
  func toAgentMessage() -> Message {
    return Message(
      id: self.id,
      user: .init(id: self.agent?.id ?? "", name: self.agent?.name ?? "O", avatarURL: nil, type: .other),
      status: .read,
      createdAt: self.createdAt ?? Date(),
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
