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
    
    @State var loadingInformation: Bool = false
    @State private var player: AVPlayer? = nil
    @State private var videoFileName: String?
    
    @Binding var currentPage: Page
    
    var body: some View {
        VStack {
            if loadingInformation {
                ProgressView("Loading...")
                    .font(.headline)
                    .padding()
            } else {
                let details = currentPage.trainingDetails
                Text(" Training for \(details.trainingType).")
                    .font(.title)
                    .padding()
                
                Text("Learn how to \(details.gestureMethod) the globe.")
                    .font(.headline)
                    .padding()
                
                if let player = player {
                    VideoPlayer(player: player)
                        .frame(width: 640, height: 360)
                        .cornerRadius(16)
                        .padding()
                        .onAppear {
                            player.seek(to: .zero)
                            player.play()
                        }
                } else {
                    Text("Video unavailable")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                NextPageButton(page: $currentPage, title: "Finish Training")
                    .padding()
                
                Spacer().frame(height: 50)
            }
        }
        .onAppear{
            loadingInformation = true
            videoFilenameSwitcher(model: model)
            if let videoName = videoFileName {
                self.player = VideoManager.shared.player(for: videoName)
            } else {
                self.player = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                model.updateAttachmentView(for: currentPage)
                if !model.configuration.isVisible {
                    model.loadSingleGlobe(globe: model.globe, openImmersiveSpaceAction: openImmersiveSpaceAction)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    initialiseTrainingGlobes()
                    loadingInformation = false
                }
            }
        }
        .onDisappear{
            model.hideGlobes(dismissImmersiveSpaceAction: dismissImmersiveSpaceAction)
        }
        .frame(minWidth: 800)
        .padding()
    }
    
    func videoFilenameSwitcher(model: ViewModel) {
        switch currentPage {
        case .positionTraining:
            videoFileName = "SGpositioning"
        case .rotationTraining1, .rotationTraining2:
            if model.oneHandedRotationGesture {
                videoFileName = "SGrotating1"
            } else {
                videoFileName = "SGrotating2"
            }
        case .scaleTraining:
            videoFileName = "SGscaling"
        default:
            videoFileName = nil
        }
        
    }
    
    func initialiseTrainingGlobes() {
        guard let firstGlobeEntity = model.firstGlobeEntity
        else {
            print("First globe does not exist")
            return}
        firstGlobeEntity.respawnGlobe(.center)
        guard let secondGlobeEntity = model.secondGlobeEntity else {
            print("Second globe does not exist")
            return }
        firstGlobeEntity.respawnGlobe(.left)
        secondGlobeEntity.respawnGlobe(.right)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if currentPage == .rotationTraining1 || currentPage == .rotationTraining2 {
                initialGlobesRotation(first: firstGlobeEntity, second: secondGlobeEntity)
            }
            if currentPage == .scaleTraining {
                initialGlobesScaling(first: firstGlobeEntity, second: secondGlobeEntity)
            }
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
    TrainingView(currentPage: .constant(.positionTraining))
        .glassBackgroundEffect()
        .environment(ViewModel())
        .environment(StudyModel())
}
