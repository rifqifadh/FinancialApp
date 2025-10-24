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
  let fetchMessages: @Sendable (_ conversationId: String) async throws -> BaseResponse<[MessageResponse]>
  let sendMessage: @Sendable (MessageParams) async throws -> BaseResponse<MessageResponse>
  let subscribeToInsertions: @Sendable (_ conversationId: String) -> AsyncStream<(MessageResponse?, RealtimeChannelStatus?)>
  let fetchMessage: @Sendable (_ messageId: String) async throws -> MessageResponse
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
    }, subscribeToInsertions: { id in
      return AsyncStream { continuation in
        let channel = SupabaseManager.shared.client.realtimeV2.channel("messages:\(id)")
        let insertions = channel.postgresChange(InsertAction.self, schema: "public", table: "messages", filter: .eq("conversation_id", value: id))
        
        
        Task {
          try await channel.subscribeWithError()
          
          for await insert in insertions {
            print(insert.record)
//            if let messageId = insert.record["id"]?.stringValue, id.isEmpty {
//              continue
//            }
            guard let messageId = insert.record["id"]?.stringValue else {
              continue
            }
            guard let role = insert.record["role"]?.stringValue, role != "user" else {
              continue
            }
            
            let message: MessageResponse = try await SupabaseManager.shared.client.from("messages")
              .select(
                """
                id,
                conversation_id,
                role,
                content,
                metadata,
                created_at,
                user_id,
                agent_id,
                agent:agents(id, name)
                """
              )
              .eq("id", value: messageId)
              .single()
              .execute()
              .value
            continuation.yield((message, channel.status))
          }
        }
        
        continuation.onTermination = { _ in
          Task {
            continuation.yield((nil,  channel.status))
            await channel.unsubscribe()
            continuation.yield((nil,  channel.status))
          }
        }
      }
    }, fetchMessage: { id in
      let message: MessageResponse = try await SupabaseManager.shared.client.from("messages")
        .select(
          """
          id,
          conversation_id,
          role,
          content,
          metadata,
          created_at,
          user_id,
          agent_id,
          agent:agents(id, name, description, avatar)
          """
        )
        .single()
        .execute()
        .value
      return message
    }
//    ,subscribeToMessages: { channelId in
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
