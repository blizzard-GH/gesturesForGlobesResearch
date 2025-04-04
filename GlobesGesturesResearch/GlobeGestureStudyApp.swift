//
//  GlobeGestureStudyApp.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 14/8/2024.
//

import os
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // register custom components and systems
        RotationComponent.registerComponent()
        RotationSystem.registerSystem()
        
        SphereLabelComponent.registerComponent()
        SphereLabelSystem.registerSystem()
        
        // start camera tracking
        CameraTracker.start()
        
        _ = SoundManager.shared
        
        return true
    }
}

@main
struct GlobeGestureStudyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    /// View model injected into the environment.
    @State private var viewModel = ViewModel.shared
    
    /// Study model injected into the environment.
    @State private var studyModel = StudyModel()
    
    var body: some Scene {
        WindowGroup(id: ViewModel.windowID) {
            ContentView(currentPage: $studyModel.currentPage)
                .environment(viewModel)
                .environment(studyModel)
        }
        .windowResizability(.contentSize) // window resizability is derived from window content

        ImmersiveSpace(id: "ImmersiveGlobeSpace") {
            ImmersiveView()
                .environment(viewModel)
                .environment(studyModel)
        }
    }
}

