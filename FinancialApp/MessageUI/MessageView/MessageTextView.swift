//
//  MessageText.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 21/08/25.
//

import SwiftUI

struct MessageTextView: View {
  @Environment(\.chatTheme) private var theme
  
  /// If the message contains links, this property is used to correctly size the link previews, so they have the same width as the message text.
  @State private var textSize: CGSize = .zero
  
  /// Large enough to show the domain and icon, if needed, for most pages.
  private static let minLinkPreviewWidth: CGFloat = 140
  
  let text: String
  let messageStyler: (String) -> AttributedString
  let userType: UserMessageType
  let shouldShowLinkPreview: (URL) -> Bool
  let messageLinkPreviewLimit: Int
  
  var styledText: AttributedString {
    var result = text.styled(using: messageStyler)
    result.foregroundColor = theme.colors.messageText(userType)
    
    for (link, range) in result.runs[\.link] {
      if link != nil {
        result[range].underlineStyle = .single
      }
    }
    
    return result
  }
  
  var urlsToPreview: [URL] {
    Array(styledText.urls.filter(shouldShowLinkPreview).prefix(messageLinkPreviewLimit))
  }
  
  var body: some View {
    if !styledText.characters.isEmpty {
      Text(styledText)
        .sizeGetter($textSize)
      
      if !urlsToPreview.isEmpty {
        VStack {
          ForEach(Array(urlsToPreview.enumerated()), id: \.offset) { _, url in
//            LinkPillView(url: url)
            Text("")
          }
        }
        .frame(width: max(textSize.width, Self.minLinkPreviewWidth))
      }
    }
  }
}

//#Preview {
//  MessageTextView(
//    text: "Look at [this website](https://example.org)",
//    messageStyler: AttributedString.init, userType: .other,
//    shouldShowLinkPreview: { _ in true }, messageLinkPreviewLimit: 8)
//  MessageTextView(
//    text: "Look at [this website](https://example.org)",
//    messageStyler: String.markdownStyler, userType: .other,
//    shouldShowLinkPreview: { _ in true }, messageLinkPreviewLimit: 8)
//  MessageTextView(
//    text: "[@Dan](mention://user/123456789) look at [this website](https://example.org)!",
//    messageStyler: String.markdownStyler, userType: .other,
//    shouldShowLinkPreview: { $0.scheme != "mention" }, messageLinkPreviewLimit: 8)
//}
