//
//  TrainingView.swift
//  GlobesGesturesResearch
//
//  Created by Faisal Agung Abdillah on 11/2/2025.
//

import SwiftUI

struct TrainingView: View {
    @Environment(ViewModel.self) var model
    @Environment(StudyModel.self) var studyModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpaceAction
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpaceAction

    @State var loadingInformation: Bool = false
    @State private var isButtonPressed: Bool = false

    
    @Binding var currentPage: Page

    private func updateAttachmentView() {
            switch currentPage {
            case .positionComparison:
                model.attachmentView = .position
            case .rotationComparison:
                model.attachmentView = .rotation
            case .scaleComparison:
                model.attachmentView = .scale
            default:
                model.attachmentView = .none
            }
        }
    
    
    var body: some View {
        VStack {
            if loadingInformation {
                ProgressView("Loading...")
                    .font(.headline)
                    .padding()
            } else {
                let details = currentPage.trainingDetails
                Text(" Training session for \(details.trainingType).")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                Text("""
                Make yourself familiar with \(details.gestureMethod). 
                """)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentPage = currentPage.next() //
                                        isButtonPressed.toggle()
                                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isButtonPressed = false
                        }
                    }
                }){
                    Text("Finish training")
                        .bold()
                        .font(.headline)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: .black, radius: 1)
                }
//                .padding(40)
                .background(Color.blue)
                .cornerRadius(20)
                .scaleEffect(isButtonPressed ? 1.1 : 1.0)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Spacer().frame(height: 50)
                
//            Debugging:
//                Text("immersiveSpaceIsShown : \(model.immersiveSpaceIsShown)")
//                Text("model.config.isVisible : \(model.configuration.isVisible)")
            }
        }
        .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemGray2)).shadow(radius: 5))
        .onAppear{
            loadingInformation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                updateAttachmentView()
                showOrHideGlobe(true)
                //            model.closeImmersiveGlobeSpace(dismissImmersiveSpaceAction)
                loadingInformation = false
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                model.firstGlobeEntity?.respawnGlobe("Left")
//                model.secondGlobeEntity?.respawnGlobe("Right")
//            }
        }
        .onDisappear{
            showOrHideGlobe(false)
//            model.closeImmersiveGlobeSpace(dismissImmersiveSpaceAction)
        }
        .frame(minWidth: 800)
        .padding()
    }
    
    
    @MainActor
    private func showOrHideGlobe(_ show: Bool) {
        Task { @MainActor in
            if show {
                guard !model.configuration.isVisible else { return }
                model.load(
                        firstGlobe: model.globe,
                        secondGlobe: model.secondGlobe,
                        openImmersiveSpaceAction: openImmersiveSpaceAction
                    )
            } else {
                guard model.configuration.isVisible else { return }
                model.hideGlobe(dismissImmersiveSpaceAction: dismissImmersiveSpaceAction)
            }
        }
    }
}


//#Preview {
//    TrainingView(currentPage: .constant(.positionTraining))
//        .environment(ViewModel())
//        .environment(StudyModel())
//}
