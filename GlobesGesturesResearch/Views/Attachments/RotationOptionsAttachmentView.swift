//
//  RotationOptionsAttachment.swift
//  GlobesGesturesResearch
//
//  Created by Faisal Agung Abdillah on 17/3/2025.
//

import SwiftUI

@MainActor
struct RotationOptionsAttachmentView: View {
    @Environment(ViewModel.self) var model
    
    var body: some View {
        VStack {
            Text("Rotation Behaviour")
                .font(.title)
                .padding(.top)
            
            Picker("Globe Rotation", selection: Bindable(model).oneHandedRotationGesture) {
                Text("One-handed Rotation").tag(true)
                Text("Two-handed Rotation").tag(false)
            }
            .pickerStyle(.segmented)
            .padding()
        }
        .padding()
    }
}
