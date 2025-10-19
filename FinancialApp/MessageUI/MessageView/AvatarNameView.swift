//
//  AvatarNameView.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 21/08/25.
//


import SwiftUI

struct AvatarNameView: View {
  
  let name: String
  let avatarSize: CGFloat
  
  var body: some View {
    let letter =
    if let firstLetter = name.first {
      firstLetter.uppercased()
    } else {
      "-"
    }
    Text(letter)
      .frame(width: avatarSize, height: avatarSize)
      .background(Color.teal)
      .clipShape(Circle())
  }
}

struct AvatarNameView_Previews: PreviewProvider {
  static var previews: some View {
    AvatarNameView(
      name: "Fred",
      avatarSize: 32
    )
  }
}
