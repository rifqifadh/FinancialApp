//
//  ChatServices.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import Dependencies
import Supabase
import Foundation

struct ChatServices: Sendable {
  let fetchConversations: @Sendable () async throws -> [ConversationResponse]
  let fetchMessages: @Sendable (_ conversationId: Int) async throws -> BaseResponse<[MessageResponse]>
  let sendMessage: @Sendable (MessageParams) async throws -> BaseResponse<MessageResponse>
//  let fetchMessages: @Sendable (_ channelId: String) async throws -> [MessageResponse]
  //  let generateChannel: (_ userId: String) async throws -> ChatChannelResponse
//    let subscribeToMessages: @Sendable (_ channelId: String) -> AsyncStream<MessageResponse>
//    let subscribeToMessagesWithStatus: @Sendable (_ channelId: String) -> AsyncStream<(MessageResponse?, RealtimeChannelStatus?)>
  //  let deleteMessage: (_ messageId: String) async throws -> Void
}

extension ChatServices: DependencyKey {
  static let liveValue = ChatServices(
    fetchConversations: {
      do {
        let userId = try await SupabaseManager.shared.client.auth.user().id.uuidString
        return try await SupabaseManager.shared.client
          .from("conversations")
          .select()
          .eq("user_id", value: userId)
          .execute()
          .value
        
      } catch {
        throw error
      }
    }, fetchMessages: { conversationId in
      do {
        let res: BaseResponse<[MessageResponse]> = try await SupabaseManager.shared.client.rpc("get_messages_paginated", params: ["args": ["conversation_id": conversationId]])
          .execute()
          .value
        return res
      } catch {
        throw error
      }
    }, sendMessage: { message in
      try await SupabaseManager.shared.client
        .rpc("insert_message", params: ["params": message])
        .execute()
        .value
    }
//    , fetchMessages: { channelId in
//      try await SupabaseManager.shared.client
//        .from("messages")
//        .select()
//        .eq("channel_id", value: channelId)
//        .order("created_at", ascending: true)
//        .execute()
//        .value
//    }, subscribeToMessages: { channelId in
//      return AsyncStream { continuation in
//        
//        let channel = SupabaseManager.shared.client.channel(channelId)
//        let insertions = channel.postgresChange(InsertAction.self, schema: "public", table: "messages", filter: .eq("channel_id", value: channelId))
//        
//        Task {
//          try await channel.subscribeWithError()
//          
//          for await insert in insertions {
//            continuation.yield(
//              MessageResponse(
//                id: insert.record["id"]?.stringValue ?? "",
//                createdAt: .init(),
//                content: insert.record["content"]?.stringValue ?? ""
////                userId: insert.record["user_id"]?.stringValue ?? "",
////                createdAt: insert.record["created_at"]?.stringValue.flatMap { ISO8601DateFormatter().date(from: $0) },
////                content: insert.record["content"]?.stringValue ?? "",
////                imageUrl: insert.record["image_url"]?.stringValue,
////                role: insert.record["role"]?.stringValue ?? "",
////                channelId: insert.record["channel_id"]?.stringValue ?? "",
////                name: insert.record["name"]?.stringValue ?? ""
//              )
//            )
//          }
//        }
//        
//        continuation.onTermination = { _ in
//          Task {
//            await channel.unsubscribe()
//          }
//        }
//      }
//    }, subscribeToMessagesWithStatus: { channelId in
//      return AsyncStream { continuation in
//        let channel = SupabaseManager.shared.client.channel(channelId)
//        let insertions = channel.postgresChange(InsertAction.self, schema: "public", table: "messages", filter: .eq("channel_id", value: channelId))
//        
//        Task {
//          // Send initial status
//          continuation.yield((nil, .subscribing))
//          
//          try await channel.subscribeWithError()
//          
//          // Send subscribed status
//          continuation.yield((nil, .subscribed))
//          
//          for await insert in insertions {
//            let message = MessageResponse(
//              id: insert.record["id"]?.stringValue ?? "",
//              userId: insert.record["user_id"]?.stringValue ?? "",
//              createdAt: insert.record["created_at"]?.stringValue.flatMap { ISO8601DateFormatter().date(from: $0) },
//              content: insert.record["content"]?.stringValue ?? "",
//              imageUrl: insert.record["image_url"]?.stringValue,
//              role: insert.record["role"]?.stringValue ?? "",
//              channelId: insert.record["channel_id"]?.stringValue ?? "",
//              name: insert.record["name"]?.stringValue ?? ""
//            )
//            continuation.yield((message, .subscribed))
//          }
//        }
//        
//        continuation.onTermination = { _ in
//          Task {
//            continuation.yield((nil, .unsubscribing))
//            await channel.unsubscribe()
//            continuation.yield((nil, .unsubscribed))
//          }
//        }
//      }
//    }
  )
}

extension DependencyValues {
  var chatServices: ChatServices {
    get { self[ChatServices.self] }
    set { self[ChatServices.self] = newValue }
  }
}
