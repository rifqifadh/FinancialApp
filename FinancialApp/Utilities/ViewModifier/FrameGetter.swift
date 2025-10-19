//
//  FrameGetter.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//

import Foundation
import SwiftUI

struct FrameGetter: ViewModifier {

    @Binding var frame: CGRect

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> AnyView in
                    DispatchQueue.main.async {
                        let rect = proxy.frame(in: .global)
                        // This avoids an infinite layout loop
                        if rect.integral != self.frame.integral {
                            self.frame = rect
                        }
                    }
                    return AnyView(EmptyView())
                }
            )
    }
}

struct SizeGetter: ViewModifier {
    @Binding var size: CGSize

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> Color in
                    if proxy.size != self.size {
                        DispatchQueue.main.async {
                            self.size = proxy.size
                        }
                    }
                    return Color.clear
                }
            )
    }
}

struct MaxHeightGetter: ViewModifier {
    @Binding var height: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> Color in
                    if proxy.size.height > self.height {
                        DispatchQueue.main.async {
                            self.height = proxy.size.height
                        }
                    }
                    return Color.clear
                }
            )
    }
}

extension View {

    func frameGetter(_ frame: Binding<CGRect>) -> some View {
        modifier(FrameGetter(frame: frame))
    }

    func sizeGetter(_ size: Binding<CGSize>) -> some View {
        modifier(SizeGetter(size: size))
    }
    
    func maxHeightGetter(_ height: Binding<CGFloat>) -> some View {
        modifier(MaxHeightGetter(height: height))
    }
}

actor MessageMenuPreferenceKey: PreferenceKey {
    typealias Value = [String: CGRect]

  static let defaultValue: Value = [:]

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { (_, new) in new }
    }
}

struct MessageMenuPreferenceViewSetter: View {
    let id: String

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .preference(key: MessageMenuPreferenceKey.self,
                            value: [id: geometry.frame(in: .global)])
        }
    }
}
