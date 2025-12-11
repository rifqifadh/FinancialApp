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
      await viewModel.loadAgents()
      await viewModel.subscribeToMessages()
    }
    .navigationTitle("Chat Room")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarVisibility(.hidden, for: .tabBar)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          viewModel.showAgentSelector = true
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "person.circle.fill")
              .font(.system(size: 16))
            if let agent = viewModel.selectedAgent {
              Text(agent.name)
                .font(AppTheme.Typography.caption)
            } else {
              Text("Select Agent")
                .font(AppTheme.Typography.caption)
            }
          }
          .foregroundStyle(AppTheme.Colors.accent)
        }
      }
    }
    .sheet(isPresented: $viewModel.showAgentSelector) {
      AgentSelectorView(viewModel: viewModel)
    }
  }
}

// MARK: - Agent Selector View
struct AgentSelectorView: View {
  @Environment(\.dismiss) private var dismiss
  @Bindable var viewModel: ChatRoomViewModel

  var body: some View {
    NavigationView {
      ViewStateView(
        state: viewModel.agentsState,
        content: { agents in
          List {
            Section {
              Button {
                Task {
                  await viewModel.selectAgent(nil)
                  dismiss()
                }
              } label: {
                HStack {
                  VStack(alignment: .leading, spacing: 4) {
                    Text("No Agent")
                      .font(AppTheme.Typography.bodyBold)
                      .foregroundStyle(AppTheme.Colors.primaryText)

                    Text("Use default assistant")
                      .font(AppTheme.Typography.caption)
                      .foregroundStyle(AppTheme.Colors.secondaryText)
                  }

                  Spacer()

                  if viewModel.selectedAgent == nil {
                    Image(systemName: "checkmark.circle.fill")
                      .foregroundStyle(AppTheme.Colors.accent)
                  }
                }
                .contentShape(Rectangle())
              }
              .buttonStyle(.plain)
            }

            Section {
              ForEach(agents, id: \.id) { agent in
                Button {
                  Task {
                    await viewModel.selectAgent(agent)
                    dismiss()
                  }
                } label: {
                  HStack {
                    VStack(alignment: .leading, spacing: 4) {
                      Text(agent.name)
                        .font(AppTheme.Typography.bodyBold)
                        .foregroundStyle(AppTheme.Colors.primaryText)

                      if let modelName = agent.modelName {
                        Text(modelName)
                          .font(AppTheme.Typography.caption)
                          .foregroundStyle(AppTheme.Colors.secondaryText)
                      }
                    }

                    Spacer()

                    if viewModel.selectedAgent?.id == agent.id {
                      Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.accent)
                    }
                  }
                  .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
              }
            } header: {
              Text("Available Agents")
            }
          }
        },
        retry: {
          Task {
            await viewModel.loadAgents()
          }
        }
      )
      .navigationTitle("Select AI Agent")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Close") {
            dismiss()
          }
        }
      }
    }
  }
}
