//
//  PositionOptionsAttachmentView.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 23/1/2025.
//

import SwiftUI

struct PositionOptionsAttachmentView: View {
    @Environment(ViewModel.self) var model
    @Environment(StudyModel.self) var studyModel
    
    var body: some View {
        Form {
            Section {
                Picker("Placement", selection: Bindable(model).rotateGlobeWhileDragging) {
                    Text("Rotating Globe").tag(true)
                    Text("Static Globe").tag(false)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

#Preview {
    PositionOptionsAttachmentView()
}
