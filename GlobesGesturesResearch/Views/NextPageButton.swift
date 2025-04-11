//
//  NextPageButton.swift
//  GlobesGesturesResearch
//
//  Created by Bernhard Jenny on 4/4/2025.
//

import SwiftUI

struct NextPageButton: View {
    @Environment(StudyModel.self) var studyModel
    let title: String
    let action: (() -> Void)?
    
    init(title: String, action: (() -> Void)? = nil) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(title, action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                studyModel.currentPage = studyModel.currentPage.next()
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
        NextPageButton(title: "Next Page")
            .padding()
    }
    .padding()
    .frame(width: 600)
    .glassBackgroundEffect()
}
