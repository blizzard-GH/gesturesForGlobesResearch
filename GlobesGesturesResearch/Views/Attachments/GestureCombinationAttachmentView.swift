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
        VStack {
            PositionOptionsAttachmentView()
            ScaleOptionsAttachmentView()
            RotationOptionsAttachmentView()
        }
    }
}
