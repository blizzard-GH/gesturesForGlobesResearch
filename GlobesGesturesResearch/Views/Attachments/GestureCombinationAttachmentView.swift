//
//  GestureCombinationsAttachments.swift
//  GlobesGesturesResearch
//
//  Created by Faisal Agung Abdillah on 28/3/2025.
//

import SwiftUI

@MainActor
struct GestureCombinationAttachmentView: View {
    @Environment(ViewModel.self) var model
    
    var body: some View {
        VStack(spacing: 0) {
            PositionOptionsAttachmentView()
                .padding()
            
            ScaleOptionsAttachmentView()
                .padding()
            
            RotationOptionsAttachmentView()
                .padding(.top)
            Text("Pinch and hold for a moment to activate rotation with one hand.")
                .opacity(model.oneHandedRotationGesture ? 1 : 0)
                .padding(.bottom, 30)
                .padding(.horizontal)
        }
    }
}
