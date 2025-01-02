//
//  CardView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/1/25.
//
import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    @Environment(\.colorScheme) var colorScheme
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(TaqwaTheme.layout.padding)
            .background(
                RoundedRectangle(cornerRadius: TaqwaTheme.layout.cornerRadius)
                    .fill(TaqwaTheme.colors.surface)
                    .shadow(
                        color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                        radius: 10,
                        x: 0,
                        y: colorScheme == .dark ? 2 : 1
                    )
            )
    }
}
