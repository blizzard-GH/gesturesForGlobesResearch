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
        Picker("Placement", selection: Bindable(model).rotateGlobeWhileDragging) {
            Text("Rotating Globe").tag(true)
            Text("Static Globe").tag(false)
        }
        .pickerStyle(.segmented)
        .fixedSize()
        .padding()
        .glassBackgroundEffect()
    }
}

#Preview {
    PositionOptionsAttachmentView()
}
