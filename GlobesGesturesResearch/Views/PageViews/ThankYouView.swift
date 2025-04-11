//
//  ThankYouView.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 28/11/2024.
//

import SwiftUI

/// The last view shown.
struct ThankYouView: View {
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        VStack(spacing : 40) {
            Label("You have reached the end.", systemImage: "checkmark.circle.fill")
            
            Text("Thank you for participating in this study!")
                .font(.largeTitle)
                .padding()
        }
        .padding(40)
    }

}

#Preview{
    ThankYouView()
        .padding()
        .glassBackgroundEffect()
}
