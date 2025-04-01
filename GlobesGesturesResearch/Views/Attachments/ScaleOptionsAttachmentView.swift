//
//  ScaleOptionsAttachmentView.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 23/1/2025.
//

import SwiftUI

@MainActor
struct ScaleOptionsAttachmentView: View {
    @Environment(ViewModel.self) var model
    
    private var binding: Binding<Bool> {
        Binding(
            get: {
                model.moveGlobeWhileScaling
            },
            set: { newValue in
                print("move globe", newValue)
                model.moveGlobeWhileScaling = newValue
            }
        )
    }
    
    var body: some View {
        VStack {
            Text("Scaling Behaviour")
                .font(.title)
                .padding(.top)
            
            Picker("Globe Position", selection: binding) {
                Text("Maintain Globe Position").tag(false)
                Text("Maintain Distance to Globe").tag(true)
            }
            .pickerStyle(.segmented)
            .padding()
        }
        .padding()
    }
}
