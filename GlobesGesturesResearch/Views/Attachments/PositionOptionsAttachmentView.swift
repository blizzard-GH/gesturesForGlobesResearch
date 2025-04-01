//
//  PositionOptionsAttachmentView.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 23/1/2025.
//

import SwiftUI

@MainActor
struct PositionOptionsAttachmentView: View {
    @Environment(ViewModel.self) var model
    
    private let rotateInfo = "The globe rotates as it moves, so you always see the same side of the Earth."
    private let staticInfo = "The globe's orientation stays fixed as it moves."
    
    var body: some View {
        VStack {
            Text("Positioning Behaviour")
                .font(.title)
                .padding(.top)
            
            Picker("Globe Rotation", selection: Bindable(model).rotateGlobeWhileDragging) {
                Text("Static Orientation").tag(false)
                Text("Adaptive Orientation").tag(true)
            }
            .pickerStyle(.segmented)
            .padding()
            
            Text(model.rotateGlobeWhileDragging ? rotateInfo : staticInfo)
                .padding()
        }
        .padding()
    }
}
