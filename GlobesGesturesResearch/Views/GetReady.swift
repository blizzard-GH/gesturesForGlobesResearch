//
//  GetReady.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 18/12/2024.
//

import SwiftUI

struct GetReady: View {
    @Environment(StudyModel.self) var studyModel
    
    /// Callback that is run after `countdown` seconds.
    var onCountdownComplete: () -> Void
    var countdown = 1.0
    
    var body: some View {
        VStack {
            if let details = studyModel.currentPage.taskDetails {
                Text("Loading Task \(details.taskNumber)…")
                    .font(.largeTitle)
                    .padding()
            }
        }
        .cornerRadius(20)
        .padding(40)
        .task {
            try? await Task.sleep(for: .seconds(countdown))
            onCountdownComplete()
        }
    }
}

#Preview {
    GetReady(){
        print("Countdown finishes.")
    }
    .padding()
    .glassBackgroundEffect()
    .environment(ViewModel())
    .environment(StudyModel())
}
