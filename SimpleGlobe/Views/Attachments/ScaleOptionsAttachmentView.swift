//
//  ScaleOptionsAttachmentView.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 23/1/2025.
//

import SwiftUI

struct ScaleOptionsAttachmentView: View {
    @Environment(ViewModel.self) var model
    
    var body: some View {
        VStack {
            Text("Globe Position While Scaling")
            Picker("Globe Position", selection: Bindable(model).moveGlobeWhileScaling) {
                Text("Equal Distance").tag(true)
                Text("Static Globe Center").tag(false)
            }
            .pickerStyle(.segmented)
            .fixedSize()
        }
        .padding()
        .glassBackgroundEffect()
    }
}

#Preview {
    ScaleOptionsAttachmentView()
}
