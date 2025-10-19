//
//  TextInputView.swift
//  ExpenseTracker
//
//  Created by Rifqi on 02/09/25.
//

import SwiftUI

struct TextInputView: View {
  @Environment(\.chatTheme) private var theme
  
  @EnvironmentObject private var globalFocusState: GlobalFocusState
  
  @Binding var text: String
  @State var inputFieldId: UUID
  
  var body: some View {
    TextField("", text: $text, axis: .vertical)
      .customFocus($globalFocusState.focus, equals: .uuid(inputFieldId))
//      .placeholder(when: text.isEmpty) {
//        Text("Message")
//          .foregroundStyle(theme.colors.inputPlaceholderText)
//      }
      .foregroundStyle(theme.colors.inputText)
      .padding(.vertical, 10)
      .simultaneousGesture(
        TapGesture().onEnded {
          globalFocusState.focus = .uuid(inputFieldId)
        }
      )
  }
}

#Preview {
  Text("lkjasdlkfja")
}
