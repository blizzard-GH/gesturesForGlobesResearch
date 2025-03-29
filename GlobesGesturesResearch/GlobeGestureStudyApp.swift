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
        
        // start camera tracking
        CameraTracker.start()
        
        _ = SoundManager.shared
        
        return true
    }
}

@main
struct GlobeGestureStudyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openURL) private var openURL
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    /// View model injected in environment.
    @State private var model = ViewModel.shared
    
    @State private var webViewStatus: WebViewStatus = .loading
    
    @State private var studyModel = StudyModel()
    
    
//    @State private var currentPage: Page = .welcome
    
    var body: some Scene {
//        WindowGroup(id: "Gesture Options Window"){
//            switch studyModel.currentPage {
//            case .positionComparison:
//                PositionOptionsAttachmentView()
//            case .rotationComparison:
//                RotationOptionsAttachmentView()
//            case .scaleComparison:
//                ScaleOptionsAttachmentView()
//            case .outroForm:
//                GestureCombinationAttachmentView()
//            default:
//                EmptyView()
//                    .onAppear{
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                            dismissWindow(id: "Gesture Options Window")
//                        }
//                    }
//            }
//        }
//        .environment(model)
//        .environment(studyModel)
        WindowGroup(id: "Second Window"){
            ContentView(currentPage: $studyModel.currentPage)
                .environment(model)
                .environment(studyModel)
        }
        .windowResizability(
            .contentSize
        ) // window resizability is derived from window content
//        WindowGroup(id: "info", for: UUID.self) { $globeId in
//            if let infoURL = model.globe.infoURL {
//                WebViewDecorated(currentPage: $studyModel.currentPage, url: infoURL, webViewStatus: $webViewStatus)
//                    .ornament(attachmentAnchor: .scene(.bottom)) {
//                        Button("Open in Safari") { openURL(infoURL) }
//                            .padding()
//                            .glassBackgroundEffect()
//                    }
//                    .frame(minWidth: 500)
//            }
//        }
//        .windowResizability(
//            .contentSize
//        ) // window resizability is derived from window content
        //
        ImmersiveSpace(id: "ImmersiveGlobeSpace") {
            ImmersiveView()
                .environment(model)
                .environment(studyModel)
        }
    }
}

