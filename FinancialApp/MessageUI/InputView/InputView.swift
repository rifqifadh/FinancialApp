//
//  InputView.swift
//  ExpenseTracker
//
//  Created by Rifqi on 02/09/25.
//

import SwiftUI

struct InputView: View {
  @Bindable var viewModel: InputViewModel
  
  var body: some View {
    VStack {
      Text("Top View")
      HStack(alignment: .bottom, spacing: 10) {
        leftView
        middleView
        rightView
      }
    }
    
  }
  
  @ViewBuilder
  var leftView: some View {
    Text("Left")
  }
  
  @ViewBuilder
  var middleView: some View {
    Text("Middle")
  }
  
  @ViewBuilder
  var rightView: some View {
    Text("Right")
  }
}

#Preview {
//  InputView(viewModel: .init())
  Text("lkjaslkfj")
}
