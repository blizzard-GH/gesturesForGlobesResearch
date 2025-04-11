//
//  WelcomeView.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 28/11/2024.
//

import SwiftUI

/// The first view shown.
struct WelcomeView: View {
    @Environment(ViewModel.self) var model
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    Spacer()
                    if TaskStorageManager.storageFileRead {
                        Label("Storage file is loaded and ready.", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                    } else {
                        Label("Storage file is not loaded.", systemImage: "exclamationmark.circle.fill")
                            .foregroundColor(.yellow)
                    }
                    
                    if !model.positionConditions.isEmpty && !model.rotationConditions.isEmpty && !model.scaleConditions.isEmpty {
                        Label("Study conditions are loaded and ready.", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Label("Study conditions are not loaded.", systemImage: "exclamationmark.circle.fill")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .padding(50)
            
            VStack(spacing: 50) {
                Text("Welcome to the User Study")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                
                Text("To move the window, look at the bar below the window, then pinch and move.")
                    .multilineTextAlignment(.center)
                
#if DEBUG
                VStack {
                    Label("DEBUG MODE", systemImage: "ant")
                    Text(("Do not run the study in debug mode."))
                }
                .foregroundStyle(.red)
                .controlSize(.extraLarge)
#endif
                NextPageButton(title: "Start") {
                    TaskStorageManager.shared.initialiseUserID()
                }
            }
            .padding(100)
        }
        
        .onAppear{
            SoundManager.shared.playSound(named: "enterAndExit")
        }
    }
}

#Preview {
    WelcomeView()
        .glassBackgroundEffect()
        .environment(ViewModel())
        .environment(StudyModel())
}
