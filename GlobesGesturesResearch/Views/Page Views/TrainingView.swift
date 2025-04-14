//
//  TrainingView.swift
//  GlobesGesturesResearch
//
//  Created by Faisal Agung Abdillah on 11/2/2025.
//

import SwiftUI
import AVKit
import RealityFoundation

enum TrainingPhase {
    case watchingVideo
    case practicingGesture
    
    var instructions: String {
        switch self {
        case .watchingVideo:
            "Watch the video to understand the task and ask the instructor for help if needed."
        case .practicingGesture:
            "Practice the task as shown in the video. When ready, press \"Finish Training\""
        }
    }
}

struct TrainingView: View {
    @Environment(ViewModel.self) var model
    @Environment(StudyModel.self) var studyModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpaceAction
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpaceAction
    
    @State private var player: AVPlayer? = nil
    @State private var trainingPhase = TrainingPhase.watchingVideo
    
    var body: some View {
        VStack {
            let details = studyModel.currentPage.trainingDetails
            Text(" Training for \(details.trainingType)")
                .font(.title)
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
            
            Text(trainingPhase.instructions)
            
            if let details = studyModel.currentPage.next().taskDetails {
                Text("Match the globe \(details.mainFeature).")
                    .font(.title2)
                    .padding(.top, 20)
                
                Text("\(details.mainVerb.capitalized) the coloured globe to match the \(details.mainFeature) of the monochrome globe.")
                    .padding()
            }
            
            switch trainingPhase {
            case .watchingVideo:
                Button("Start Training") {
                    trainingPhase = .practicingGesture
                    Task {
                        await model.load(firstGlobe: model.globe, secondGlobe: model.secondGlobe)
                        initialiseTrainingGlobes()
                    }
                }
                .controlSize(.large)
                .padding()
            case .practicingGesture:
                NextPageButton(title: "Finish Training")
                    .padding()
            }
            
            Spacer().frame(height: 50)
        }
        .task {
            if let videoURL = Bundle.main.url(forResource: videoFilename, withExtension: "mp4") {
                player = AVPlayer(url: videoURL)
            }
            player?.play()
        }
        .onDisappear {
            player?.pause()
        }
        .frame(minWidth: 800)
        .padding()
    }
   
    private var videoFilename: String {
        switch studyModel.currentPage {
        case .positionTraining:
            "positioning"
        case .rotationTraining1, .rotationTraining2:
            if model.oneHandedRotationGesture {
                "rotating1"
            } else {
                "rotating2"
            }
        case .scaleTraining:
            "scaling"
        default:
            "positioning"
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
