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
        VStack(spacing: 20) {
                    Text("Rotation Gesture")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 10)

                    HStack(spacing: 20) {
                        Button(action: {
                            model.oneHandedRotationGesture = true
                        }) {
                            Text("One-handed rotation gesture")
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
                            Text("Two-handed rotation gesture")
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
    }
}
//
//#Preview {
//    PositionOptionsAttachmentView()
//}
