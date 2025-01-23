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
            Text("Scaling Behaviour")
            Picker("Globe Position", selection: Bindable(model).moveGlobeWhileScaling) {
                Text("Maintain Distance to Globe").tag(true)
                Text("Maintain Globe Position").tag(false)
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
