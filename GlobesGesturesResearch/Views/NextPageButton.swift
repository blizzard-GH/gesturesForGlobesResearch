//
//  NextPageButton.swift
//  GlobesGesturesResearch
//
//  Created by Bernhard Jenny on 4/4/2025.
//

import SwiftUI

struct NextPageButton: View {
    @Binding var page: Page
    let title: String
    let action: (() -> Void)?
    
    init(page: Binding<Page>, title: String, action: (() -> Void)? = nil) {
        self._page = page
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(title, action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                page = page.next()
            }
            action?()
        })
        .tint(.accentColor)
        .controlSize(.large)
    }
}

#Preview {
    @Previewable @State var page: Page = .welcome
    VStack {
        Text(page.name)
        NextPageButton(page: $page, title: "Next Page")
            .padding()
    }
    .padding()
    .frame(width: 600)
    .glassBackgroundEffect()
}
