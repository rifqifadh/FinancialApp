//
//  AvatarImageView.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 21/08/25.
//

import SwiftUI
import Foundation

struct AvatarImageView: View {
  
  let url: URL?
  let avatarSize: CGFloat
  
  var body: some View {
    CachedAsyncImage(url: url, urlCache: .shared) { image in
      image
        .resizable()
        .scaledToFill()
    } placeholder: {
      Rectangle().fill(Color.gray)
    }
    .viewSize(avatarSize)
    .clipShape(Circle())
  }
}

struct AvatarImageView_Previews: PreviewProvider {
  static var previews: some View {
    AvatarImageView(
      url: URL(string: "https://placeimg.com/640/480/sepia"),
      avatarSize: 32
    )
  }
}
