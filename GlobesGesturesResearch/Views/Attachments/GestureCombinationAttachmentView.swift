//
//  GestureCombinationsAttachments.swift
//  GlobesGesturesResearch
//
//  Created by Faisal Agung Abdillah on 28/3/2025.
//

import SwiftUI

@MainActor
struct GestureCombinationAttachmentView: View {
    @Environment(ViewModel.self) var model
    
    var body: some View {

//        VStack(spacing: 20) {
//                    Text("Positioning Behaviour")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                        .padding(.bottom, 10)
//
//                    // Custom toggle-style Picker
//                    HStack(spacing: 20) {
//                        Button(action: {
//                            model.rotateGlobeWhileDragging = true
//                        }) {
//                            Text("Adaptive Orientation")
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
//                        Button(action: {
//                            model.rotateGlobeWhileDragging = false
//                        }) {
//                            Text("Static Orientation")
//                                .font(.headline)
//                                .frame(width: 300)
//                                .padding()
//                                .background(!model.rotateGlobeWhileDragging ? Color.blue : Color.gray.opacity(0.2))
//                                .foregroundColor(!model.rotateGlobeWhileDragging ? .white : .black)
//                                .cornerRadius(25)
//                        }
//                        .frame(width: 300)
//                        .cornerRadius(25)
//                    }
//                    .padding(.horizontal)
//                }
//                .padding()
//                .glassBackgroundEffect()
//        
//        VStack(spacing: 20) {
//                    Text("Rotation Behaviour")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                        .padding(.bottom, 10)
//
//                    HStack(spacing: 20) {
//                        Button(action: {
//                            model.oneHandedRotationGesture = true
//                        }) {
//                            Text("One-handed Gesture")
//                                .font(.headline)
//                                .frame(width: 300)
//                                .padding()
//                                .background(model.oneHandedRotationGesture ? Color.blue : Color.gray.opacity(0.2))
//                                .foregroundColor(model.oneHandedRotationGesture ? .white : .black)
//                                .cornerRadius(25)
//                        }
//                        .frame(width: 300)
//                        .cornerRadius(25)
//
//                        Button(action: {
//                            model.oneHandedRotationGesture = false
//                        }) {
//                            Text("Two-handed Gesture")
//                                .font(.headline)
//                                .frame(width: 300)
//                                .padding()
//                                .background(!model.oneHandedRotationGesture ? Color.blue : Color.gray.opacity(0.2))
//                                .foregroundColor(!model.oneHandedRotationGesture ? .white : .black)
//                                .cornerRadius(25)
//                        }
//                        .frame(width: 300)
//                        .cornerRadius(25)
//                    }
//                    .padding(.horizontal)
//                }
//                .padding()
//                .glassBackgroundEffect()
//        
//        VStack(spacing: 20) {
//                    Text("Scaling Behaviour")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                        .padding(.bottom, 10)
//
//                    HStack(spacing: 20) {
//                        Button(action: {
//                            model.moveGlobeWhileScaling = true
//                        }) {
//                            Text("Maintain Distance to Globe")
//                                .font(.headline)
//                                .frame(width: 300)
//                                .padding()
//                                .background(model.moveGlobeWhileScaling ? Color.blue : Color.gray.opacity(0.2))
//                                .foregroundColor(model.moveGlobeWhileScaling ? .white : .black)
//                                .cornerRadius(25)
//                        }
//                        .frame(width: 300)
//                        .cornerRadius(25)
//
//                        Button(action: {
//                            model.moveGlobeWhileScaling = false
//                        }) {
//                            Text("Maintain Globe Position")
//                                .font(.headline)
//                                .frame(width: 300)
//                                .padding()
//                                .background(!model.moveGlobeWhileScaling ? Color.blue : Color.gray.opacity(0.2))
//                                .foregroundColor(!model.moveGlobeWhileScaling ? .white : .black)
//                                .cornerRadius(25)
//                        }
//                        .frame(width: 300)
//                        .cornerRadius(25)
//                    }
//                    .padding(.horizontal)
//                }
//                .padding()
//                .glassBackgroundEffect()
            VStack(spacing: 20) {
                Text("Positioning Behaviour:")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.top, 20)
                
                Picker("Globe Rotation", selection: Bindable(model).rotateGlobeWhileDragging) {
                    Text("Adaptive Orientation").tag(true)
                        .font(.headline)
                    Text("Static Orientation").tag(false)
                        .font(.headline)
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 100)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
                .shadow(radius: 10)
            }
            .frame(width: 400, height: 150)
            .cornerRadius(30)
            .padding()
            .glassBackgroundEffect()

            VStack(spacing: 20) {
                Text("Rotation Gesture")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.top, 20)

                Picker("Modality", selection: Bindable(model).oneHandedRotationGesture) {
                    Text("One-handed Gesture").tag(true)
                        .font(.headline)
                    Text("Two-handed Gesture").tag(false)
                        .font(.headline)
                }
                .pickerStyle(WheelPickerStyle()) // Wheeled Picker style
                .frame(height: 100)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
                .shadow(radius: 10)
            }
            .frame(width: 400, height: 150)
            .cornerRadius(30)
            .padding()
            .glassBackgroundEffect()
            
            VStack(spacing: 20) {
                Text("Scaling Behaviour")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.top, 20)

                Picker("Globe Position", selection: Bindable(model).moveGlobeWhileScaling) {
                    Text("Maintain Distance to Globe").tag(true)
                        .font(.headline)
                    Text("Maintain Globe Position").tag(false)
                        .font(.headline)
                }
                .pickerStyle(WheelPickerStyle()) // Wheeled Picker style
                .frame(height: 100)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
                .shadow(radius: 10)
            }
            .frame(width: 400, height: 150)
            .cornerRadius(30)
            .padding()
            .glassBackgroundEffect()
        
    }
}
