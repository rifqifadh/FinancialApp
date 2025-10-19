//
//  String+Style.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 21/08/25.
//

import SwiftUI

@MainActor extension String {
  private static var markdownOptions = AttributedString.MarkdownParsingOptions(
    allowsExtendedAttributes: false,
    interpretedSyntax: .inlineOnlyPreservingWhitespace,
    failurePolicy: .returnPartiallyParsedIfPossible,
    languageCode: nil
  )
  
  public static func markdownStyler(text: String) -> AttributedString {
    if let attributed = try? AttributedString(markdown: text, options: String.markdownOptions) {
      attributed
    } else {
      AttributedString(stringLiteral: text)
    }
  }
  
  public func styled(using styler: (String) -> AttributedString) -> AttributedString {
    styler(self)
  }
}
