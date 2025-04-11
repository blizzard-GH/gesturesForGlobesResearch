//
//  TrainingView.swift
//  GlobesGesturesResearch
//
//  Created by Faisal Agung Abdillah on 11/2/2025.
//

import SwiftUI
import AVKit
import RealityFoundation

struct TrainingView: View {
    @Environment(ViewModel.self) var model
    @Environment(StudyModel.self) var studyModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpaceAction
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpaceAction
    
    @State private var loadingInformation: Bool = false
    @State private var player: AVPlayer? = nil
        
    var body: some View {
        VStack {
            if loadingInformation {
                ProgressView("Loading...")
                    .font(.headline)
                    .padding()
            } else {
                let details = studyModel.currentPage.trainingDetails
                Text(" Training for \(details.trainingType).")
                    .font(.title)
                    .padding()
                
                Text("Learn how to \(details.gestureMethod) the globe.")
                    .font(.headline)
                    .padding()
                
                if let player {
                    VideoPlayer(player: player)
                        .frame(width: 640, height: 360)
                        .cornerRadius(16)
                        .padding()
                } else {
                    ProgressView("Loading video...")
                        .frame(height: 360)
                }
                
                NextPageButton(title: "Finish Training")
                    .padding()
                
                Spacer().frame(height: 50)
            }
        }
        .task {
            loadingInformation = true
            
            if let videoURL = Bundle.main.url(forResource: videoFilename, withExtension: "mp4") {
                player = AVPlayer(url: videoURL)
            }
            player?.play()
            
            await model.load(firstGlobe: model.globe, secondGlobe: model.secondGlobe, openImmersiveSpaceAction: openImmersiveSpaceAction)
            initialiseTrainingGlobes()
            loadingInformation = false
        }
        .onDisappear{
            model.hideGlobes(dismissImmersiveSpaceAction: dismissImmersiveSpaceAction)
            player?.pause()
        }
        .frame(minWidth: 800)
        .padding()
    }
   
    private var videoFilename: String {
        switch studyModel.currentPage {
        case .positionTraining:
            "SGpositioning"
        case .rotationTraining1, .rotationTraining2:
            if model.oneHandedRotationGesture {
                "SGrotating1"
            } else {
                "SGrotating2"
            }
        case .scaleTraining:
            "SGscaling"
        default:
            "SGpositioning"
        }
    }
    
    private func initialiseTrainingGlobes() {
        guard let firstGlobeEntity = model.firstGlobeEntity,
              let secondGlobeEntity = model.secondGlobeEntity else {
            fatalError("Second globe does not exist")
        }
        
        firstGlobeEntity.respawnGlobe(.left)
        secondGlobeEntity.respawnGlobe(.right)
        
        if studyModel.currentPage == .rotationTraining1 || studyModel.currentPage == .rotationTraining2 {
            initialGlobesRotation(first: firstGlobeEntity, second: secondGlobeEntity)
        }
        if studyModel.currentPage == .scaleTraining {
            initialGlobesScaling(first: firstGlobeEntity, second: secondGlobeEntity)
        }
    }
    
    func initialGlobesRotation(first firstGlobeEntity: GlobeEntity,second secondGlobeEntity: GlobeEntity) {
        firstGlobeEntity.respawnGlobe(.leftClose)
        secondGlobeEntity.respawnGlobe(.rightClose)
        firstGlobeEntity.animateTransform(scale: secondGlobeEntity.scale.x, orientation: simd_quatf(angle: 6 * Float.pi, axis: SIMD3<Float>(1, 1, 0)), duration: 0.2)
        
    }
    
    func initialGlobesScaling(first firstGlobeEntity: GlobeEntity,second secondGlobeEntity: GlobeEntity) {
        firstGlobeEntity.animateTransform(scale: 0.5, duration: 0.2)
        secondGlobeEntity.animateTransform(scale: 1.5, duration: 0.2)
    }
}


#Preview {
    TrainingView()
        .glassBackgroundEffect()
        .environment(ViewModel())
        .environment(StudyModel())
}
