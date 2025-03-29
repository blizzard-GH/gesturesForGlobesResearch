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
    
    var body: some View {
//        VStack {
//            Text("Toggle the Scaling Behaviour below:")
//            Picker("Globe Position", selection: Bindable(model).moveGlobeWhileScaling) {
//                Text("Maintain Distance to Globe").tag(true)
//                Text("Maintain Globe Position").tag(false)
//            }
//            .pickerStyle(.segmented)
//            .fixedSize()
////            Toggle(isOn: Bindable(model).moveGlobeWhileScaling) {
////                Text(model.moveGlobeWhileScaling ? "Maintain Distance to Globe" : "Maintain Globe Position")
////                    .font(.subheadline)
////            }
////            .toggleStyle(SwitchToggleStyle(tint: .blue))
////            .padding()
//        }
//        .padding()
//        .glassBackgroundEffect()
        VStack(spacing: 20) {
                    Text("Scaling Gesture")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 10)

                    HStack(spacing: 20) {
                        
                        Button(action: {
                            model.moveGlobeWhileScaling = false
                        }) {
                            Text("Maintain globe position")
                                .font(.headline)
                                .frame(width: 300)
                                .padding()
                                .background(!model.moveGlobeWhileScaling ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(!model.moveGlobeWhileScaling ? .white : .black)
                                .cornerRadius(25)
                        }
                        .frame(width: 300)
                        .cornerRadius(25)
                        
                        Button(action: {
                            model.moveGlobeWhileScaling = true
                        }) {
                            Text("Maintain distance to globe")
                                .font(.headline)
                                .frame(width: 300)
                                .padding()
                                .background(model.moveGlobeWhileScaling ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(model.moveGlobeWhileScaling ? .white : .black)
                                .cornerRadius(25)
                        }
                        .frame(width: 300)
                        .cornerRadius(25)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .glassBackgroundEffect()
    }
}
//
//#Preview {
//    ScaleOptionsAttachmentView()
//}
