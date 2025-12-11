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
  let fetchConversation: @Sendable (_ conversationId: String) async throws -> ConversationResponse
  let createConversation: @Sendable (ConversationParams) async throws -> ConversationResponse
  let fetchMessages: @Sendable (_ conversationId: String) async throws -> BaseResponse<[MessageResponse]>
  let sendMessage: @Sendable (MessageParams) async throws -> BaseResponse<MessageResponse>
  let subscribeToInsertions: @Sendable (_ conversationId: String) -> AsyncStream<(MessageResponse?, RealtimeChannelStatus?)>
  let fetchMessage: @Sendable (_ messageId: String) async throws -> MessageResponse
  let fetchAgents: @Sendable () async throws -> [AgentResponse]
  let updateConversationAgent: @Sendable (_ conversationId: String, _ agentId: String?) async throws -> Void
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
    },
    fetchConversation: { conversationId in
      do {
        let conversation: ConversationResponse = try await SupabaseManager.shared.client
          .from("conversations")
          .select()
          .eq("id", value: conversationId)
          .single()
          .execute()
          .value
        return conversation
      } catch {
        throw error
      }
    },
    createConversation: { params in
      do {
        
        // Create the conversation
        let conversation: ConversationResponse = try await SupabaseManager.shared.client
          .from("conversations")
          .insert(params)
          .select()
          .single()
          .execute()
          .value
        let sessionParams = ConversationSessionParams(
          conversationId: conversation.id,
          userId: params.userId,
          agents: [:],
          lastActiveAgent: params.agentId
        )
        
        try await SupabaseManager.shared.client
          .rpc("create_conversation_session", params: ["params": sessionParams])
          .execute()
        return conversation
      } catch {
        print(error.localizedDescription)
        throw error
      }
    },
    fetchMessages: { conversationId in
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
    },
    fetchAgents: {
      do {
        let agents: [AgentResponse] = try await SupabaseManager.shared.client
          .from("agents")
          .select()
          .order("name")
          .execute()
          .value
        return agents
      } catch {
        throw error
      }
    },
    updateConversationAgent: { conversationId, agentId in
      do {
        struct UpdateAgentParams: Encodable {
          let agentId: String?
          
          enum CodingKeys: String, CodingKey {
            case agentId = "agent_id"
          }
        }
        
        let params = UpdateAgentParams(agentId: agentId)
        
        try await SupabaseManager.shared.client
          .from("conversations")
          .update(params)
          .eq("id", value: conversationId)
          .execute()
      } catch {
        throw error
      }
    }
  )
}

extension DependencyValues {
  var chatServices: ChatServices {
    get { self[ChatServices.self] }
    set { self[ChatServices.self] = newValue }
  }
}
