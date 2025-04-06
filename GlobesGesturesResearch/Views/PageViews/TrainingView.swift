//
//  TrainingView.swift
//  GlobesGesturesResearch
//
//  Created by Faisal Agung Abdillah on 11/2/2025.
//

import SwiftUI
import AVKit

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
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                model.updateAttachmentView(for: currentPage)
                if !model.configuration.isVisible {
                    model.loadSingleGlobe(globe: model.globe, openImmersiveSpaceAction: openImmersiveSpaceAction)
                }
                loadingInformation = false
            }
        }
        .onDisappear{
            if model.configuration.isVisible {
                model.hideGlobes(dismissImmersiveSpaceAction: dismissImmersiveSpaceAction)
            }
        }
        .frame(minWidth: 800)
        .padding()
    }
    
    func videoFilenameSwitcher(model: ViewModel) {
        switch currentPage {
        case .positionTraining:
            videoFileName = "positioning"
        case .rotationTraining1, .rotationTraining2:
            if model.oneHandedRotationGesture {
                videoFileName = "rotating1"
            } else {
                videoFileName = "rotating2"
            }
        case .scaleTraining:
            videoFileName = "scaling"
        default:
            videoFileName = nil
        }
        
    }
}


#Preview {
    TrainingView(currentPage: .constant(.positionTraining))
        .glassBackgroundEffect()
        .environment(ViewModel())
        .environment(StudyModel())
}
