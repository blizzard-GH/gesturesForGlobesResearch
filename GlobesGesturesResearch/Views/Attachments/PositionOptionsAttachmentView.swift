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
//        VStack {
//            Text("Positioning Behaviour:")
//            Picker("Globe Rotation", selection: Bindable(model).rotateGlobeWhileDragging) {
//                Text("Adaptive Orientation").tag(true)
//                Text("Static Orientation").tag(false)
//            }
//            .pickerStyle(.wheel)
//            .fixedSize()
//        .padding()
//        .glassBackgroundEffect()
            
        VStack(spacing: 20) {
            Text("Positioning Behaviour:")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.top, 20)
            
            Picker("Globe Rotation", selection: Bindable(model).rotateGlobeWhileDragging) {
                Text("Static Orientation").tag(false)
                    .font(.headline)
                Text("Adaptive Orientation").tag(true)
                    .font(.headline)
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 100)
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
            .shadow(radius: 10)
//            .foregroundColor(.white)
//            .overlay(
//                RoundedRectangle(cornerRadius: 15)
//                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
//            )
//            .padding(.horizontal)
//            .padding(.bottom, 20)
            
        }
        .frame(width: 400, height: 150)
        //            .background(BlurView(style: .systemMaterialLight))
        .cornerRadius(30)
        .padding()
        .glassBackgroundEffect()
//        VStack(spacing: 20) {
//                    Text("Positioning Gesture")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                        .padding(.bottom, 10)
//
//                    // Custom toggle-style Picker
//                    HStack(spacing: 20) {
//                        Button(action: {
//                            model.rotateGlobeWhileDragging = false
//                        }) {
//                            Text("Static orientation")
//                                .font(.headline)
//                                .frame(width: 300)
//                                .padding()
//                                .background(!model.rotateGlobeWhileDragging ? Color.blue : Color.gray.opacity(0.2))
//                                .foregroundColor(!model.rotateGlobeWhileDragging ? .white : .black)
//                                .cornerRadius(25)
//                        }
//                        .frame(width: 300)
//                        .cornerRadius(25)
//                        
//                        Button(action: {
//                            model.rotateGlobeWhileDragging = true
//                        }) {
//                            Text("Adaptive orientation")
//                                .font(.headline)
//                                .frame(width: 300)
//                                .padding()
//                                .background(model.rotateGlobeWhileDragging ? Color.blue : Color.gray.opacity(0.2))
//                                .foregroundColor(model.rotateGlobeWhileDragging ? .white : .black)
//                                .cornerRadius(25)
//                        }
//                        .frame(width: 300)
//                        .cornerRadius(25)
//
//                    }
//                    .padding(.horizontal)
//                }
//                .padding()
//                .glassBackgroundEffect()
        
    }
}

//#Preview {
//    PositionOptionsAttachmentView()
//}
