//
//  InputView.swift
//  ExpenseTracker
//
//  Created by Rifqi on 02/09/25.
//

import SwiftUI

struct InputView: View {
  @Environment(\.chatTheme) var theme
  @Environment(KeyboardState.self) var keyboardState
  
  @Bindable var viewModel: InputViewModel
  @State var inputFieldId: UUID = UUID()
  
  private var state: InputViewState {
    viewModel.state
  }
  
  private var onAction: (InputViewAction) -> Void {
    viewModel.inputViewAction()
  }
  
  var body: some View {
    VStack {
      HStack(alignment: .bottom, spacing: 10) {
        HStack(alignment: .bottom, spacing: 10) {
//          leftView
          middleView
//          rightView
        }
        .background {
          RoundedRectangle(cornerRadius: 18)
            .fill(theme.colors.inputBG)
        }
        rightOutsideButton
      }
    }
    .onDragExt(towards: .bottom, ofAmount: 100...) {
      keyboardState.resignFirstResponder()
    }
    .background(theme.colors.mainBG)
  }
  
  @ViewBuilder
  var leftView: some View {
    Text("Left")
  }
  
  @ViewBuilder
  var middleView: some View {
    Group {
      TextInputView(
        text: $viewModel.text,
        inputFieldId: inputFieldId
      )
      .autocorrectionDisabled()
    }
    .padding(.horizontal)
    .frame(minHeight: 48)
  }
  
  @ViewBuilder
  var rightView: some View {
    Text("Right")
  }
  
  @ViewBuilder
  var rightOutsideButton: some View {
      sendButton
  }
  
  var sendButton: some View {
    Button {
      onAction(.send)
    } label: {
      Image(systemName: "paperplane.fill")
        .foregroundStyle(theme.colors.inputBG)
        .viewSize(48)
        .circleBackground(theme.colors.sendButtonBackground)
    }
  }
}

enum InputViewState: Sendable {
  case empty
  case hasTextOrMedia
  case editing
  
  var canSend: Bool {
    switch self {
    case .hasTextOrMedia: return true
    default: return false
    }
  }
}

public enum InputViewAction: Sendable {
    case add
    case camera
    case send

    case saveEdit
    case cancelEdit
}

#Preview {
  InputView(viewModel: .init())
    .environment(\.chatTheme, ChatTheme())
    .environmentObject(GlobalFocusState())
}
