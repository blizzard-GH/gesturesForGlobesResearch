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
    
    var body: some View {
        VStack {
            Text("Positioning Behaviour")
                .font(.title)
                .padding(.top)
            
            Picker("Globe Rotation", selection: Bindable(model).rotateGlobeWhileDragging) {
                Text("Static Orientation").tag(false)
                    .font(.headline)
                Text("Adaptive Orientation").tag(true)
                    .font(.headline)
            }
            .pickerStyle(.segmented)
            .fixedSize()
            .padding()
        }
        .padding()
        .glassBackgroundEffect()
    }
}
