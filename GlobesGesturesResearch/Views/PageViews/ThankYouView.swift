//
//  ThankYouView.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 28/11/2024.
//

import SwiftUI

/// The last view shown.
struct ThankYouView: View {
    var body: some View {
        VStack(spacing: 40) {
            Text("You have reached the end.")
                .font(.callout)
            Text("Thank you for participating in this study.")
                .font(.largeTitle)
        }
    }
}

