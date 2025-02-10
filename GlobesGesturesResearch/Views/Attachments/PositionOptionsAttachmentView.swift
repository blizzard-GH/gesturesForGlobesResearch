//
//  PositionOptionsAttachmentView.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 23/1/2025.
//

import SwiftUI

struct PositionOptionsAttachmentView: View {
    @Environment(ViewModel.self) var model
    
    var body: some View {
        VStack {
            Text("Positioning Behaviour")
            Picker("Globe Rotation", selection: Bindable(model).rotateGlobeWhileDragging) {
                Text("Adaptive Orientation").tag(true)
                Text("Static Orientation").tag(false)
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
