//
//  RotationOptionsAttachment.swift
//  GlobesGesturesResearch
//
//  Created by Faisal Agung Abdillah on 17/3/2025.
//

import SwiftUI

struct RotationOptionsAttachmentView: View {
    @Environment(ViewModel.self) var model
    
    var body: some View {
        VStack {
            Text("Rotation Behaviour")
            Picker("Rotation Modality", selection: Bindable(model).oneHandedRotationGesture) {
                Text("One-handed Gesture").tag(true)
                Text("Two-handed Gesture").tag(false)
            }
            .pickerStyle(.segmented)
            .fixedSize()
        }
        .padding()
        .glassBackgroundEffect()
    }
}
//
//#Preview {
//    PositionOptionsAttachmentView()
//}
