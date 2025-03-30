//
//  RotationOptionsAttachment.swift
//  GlobesGesturesResearch
//
//  Created by Faisal Agung Abdillah on 17/3/2025.
//

import SwiftUI

@MainActor
struct RotationOptionsAttachmentView: View {
    @Environment(ViewModel.self) var model
    
    var body: some View {
//        VStack {
//            Text("Toggle the Rotation Behaviour below:")
//            Picker("Rotation Modality", selection: Bindable(model).oneHandedRotationGesture) {
//                Text("One-handed Gesture").tag(true)
//                Text("Two-handed Gesture").tag(false)
//            }
//            .pickerStyle(.segmented)
//            .fixedSize()
////            Toggle(isOn: Bindable(model).oneHandedRotationGesture) {
////                Text(model.oneHandedRotationGesture ? "One-handed Gesture" : "Two-handed Gesture")
////                    .font(.subheadline)
////            }
////            .toggleStyle(SwitchToggleStyle(tint: .blue))
////            .padding()
//        }
//        .padding()
//        .glassBackgroundEffect()
//        VStack(spacing: 20) {
//                    Text("Rotation Gesture")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                        .padding(.bottom, 10)
//
//                    HStack(spacing: 20) {
//                        Button(action: {
//                            model.oneHandedRotationGesture = true
//                        }) {
//                            Text("One-handed rotation gesture")
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
//                            Text("Two-handed rotation gesture")
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
    }
}
//
//#Preview {
//    PositionOptionsAttachmentView()
//}
