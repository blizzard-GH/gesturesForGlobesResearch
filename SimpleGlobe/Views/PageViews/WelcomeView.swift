//
//  WelcomeView.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 28/11/2024.
//

import SwiftUI

/// The first view shown.
struct WelcomeView: View {
    @Binding var currentPage: Page
    
    var body: some View {
        VStack {
            Text("Welcome")
                .font(.largeTitle)
            Button("Start") {
                currentPage = currentPage.next()
            }
        }
    }
}

#Preview {
    WelcomeView(currentPage: .constant(.welcome))
}
