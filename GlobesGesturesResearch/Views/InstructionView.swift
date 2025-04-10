//
//  Instructions.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 17/12/2024.
//

import SwiftUI

struct InstructionView: View {
    @Binding var currentPage: Page
    
    var body: some View {
        VStack {
            if let details = currentPage.taskDetails {
                Text(" Match the globe \(details.mainFeature).")
                    .font(.title2)
                    .padding(.top, 20)
                
                Text("\(details.mainVerb.capitalized) the main globe to match the \(details.mainFeature) of the monochrome globe.")
                    .padding()
            }
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    InstructionView(currentPage: .constant(.rotationExperiment2))
        .padding()
        .glassBackgroundEffect()
        .environment(ViewModel.preview)
}
