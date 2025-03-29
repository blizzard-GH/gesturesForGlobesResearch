//
//  GestureCombinationsAttachments.swift
//  GlobesGesturesResearch
//
//  Created by Faisal Agung Abdillah on 28/3/2025.
//

import SwiftUI

struct GestureCombinationAttachmentView: View {
    @Environment(ViewModel.self) var model
    
    var body: some View {

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
        
        VStack(spacing: 20) {
                    Text("Rotation Behaviour")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 10)

                    HStack(spacing: 20) {
                        Button(action: {
                            model.oneHandedRotationGesture = true
                        }) {
                            Text("One-handed Gesture")
                                .font(.headline)
                                .frame(width: 300)
                                .padding()
                                .background(model.oneHandedRotationGesture ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(model.oneHandedRotationGesture ? .white : .black)
                                .cornerRadius(25)
                        }
                        .frame(width: 300)
                        .cornerRadius(25)

                        Button(action: {
                            model.oneHandedRotationGesture = false
                        }) {
                            Text("Two-handed Gesture")
                                .font(.headline)
                                .frame(width: 300)
                                .padding()
                                .background(!model.oneHandedRotationGesture ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(!model.oneHandedRotationGesture ? .white : .black)
                                .cornerRadius(25)
                        }
                        .frame(width: 300)
                        .cornerRadius(25)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .glassBackgroundEffect()
        
        VStack(spacing: 20) {
                    Text("Scaling Behaviour")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 10)

                    HStack(spacing: 20) {
                        Button(action: {
                            model.moveGlobeWhileScaling = true
                        }) {
                            Text("Maintain Distance to Globe")
                                .font(.headline)
                                .frame(width: 300)
                                .padding()
                                .background(model.moveGlobeWhileScaling ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(model.moveGlobeWhileScaling ? .white : .black)
                                .cornerRadius(25)
                        }
                        .frame(width: 300)
                        .cornerRadius(25)

                        Button(action: {
                            model.moveGlobeWhileScaling = false
                        }) {
                            Text("Maintain Globe Position")
                                .font(.headline)
                                .frame(width: 300)
                                .padding()
                                .background(!model.moveGlobeWhileScaling ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(!model.moveGlobeWhileScaling ? .white : .black)
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
