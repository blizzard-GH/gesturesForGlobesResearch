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
//        VStack {
//            Text("Positioning Behaviour:")
//            Picker("Globe Rotation", selection: Bindable(model).rotateGlobeWhileDragging) {
//                Text("Adaptive Orientation").tag(true)
//                Text("Static Orientation").tag(false)
//            }
//            .pickerStyle(.segmented)
//            .fixedSize()
////            HStack {
////                Text(model.rotateGlobeWhileDragging ? "Adaptive" : "Static")
////                    .font(.subheadline)
////                    .lineLimit(1)
////                    .frame(maxWidth: 100, alignment: .leading)
////
////                Toggle("", isOn: Bindable(model).rotateGlobeWhileDragging)
////                    .toggleStyle(SwitchToggleStyle(tint: .blue))
////            }
//        }
////        .frame(maxWidth: 300, alignment: .leading)
//        .padding()
//        .glassBackgroundEffect()
        VStack(spacing: 20) {
                    Text("Positioning Behaviour")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 10)

                    // Custom toggle-style Picker
                    HStack(spacing: 20) {
                        Button(action: {
                            model.rotateGlobeWhileDragging = true
                        }) {
                            Text("Adaptive Orientation")
                                .font(.headline)
                                .frame(width: 300)
                                .padding()
                                .background(model.rotateGlobeWhileDragging ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(model.rotateGlobeWhileDragging ? .white : .black)
                                .cornerRadius(25)
                        }
                        .frame(width: 300)
                        .cornerRadius(25)

                        Button(action: {
                            model.rotateGlobeWhileDragging = false
                        }) {
                            Text("Static Orientation")
                                .font(.headline)
                                .frame(width: 300)
                                .padding()
                                .background(!model.rotateGlobeWhileDragging ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(!model.rotateGlobeWhileDragging ? .white : .black)
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
//    PositionOptionsAttachmentView()
//}
