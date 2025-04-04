//
//  GlobeButton.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 11/12/2024.
//

import SwiftUI

struct StartExperimentButton: View {
    @Environment(ViewModel.self) private var model
    
    @Binding var isDoingTask: Bool
    
    var body: some View {
        VStack {
            Button(action: { isDoingTask = true }) {
                Label("Start Task", systemImage: "globe")
            }
            .tint(.accentColor)
            
            ProgressView()
                .opacity(model.configuration.isLoading ? 1 : 0)
                .padding()
        }
    }
}

#Preview {
    StartExperimentButton(isDoingTask: .constant(false))
        .padding()
        .glassBackgroundEffect()
        .environment(ViewModel())
        .environment(StudyModel())
}
