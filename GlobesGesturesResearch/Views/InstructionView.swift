//
//  Instructions.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 17/12/2024.
//

import SwiftUI

struct InstructionView: View {
    @Environment(StudyModel.self) var studyModel
    
    var body: some View {
        VStack {
            if let details = studyModel.currentPage.taskDetails {
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
    InstructionView()
        .padding()
        .glassBackgroundEffect()
        .environment(ViewModel.preview)
}
