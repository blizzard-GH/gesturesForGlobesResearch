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
            
            RotationOptionsAttachmentView()
                .padding(.top)
            Text(rotationInfo)
                .padding(.bottom, 30)
                .padding(.horizontal)
            
            ScaleOptionsAttachmentView()
                .padding()
        }
    }
    
    private var rotationInfo: String {
        if model.oneHandedRotationGesture {
            "Pinch and hold for a moment to activate rotation with one hand."
        } else {
            "Simultaneously pinch and rotate with both hands."
        }
    }
}
