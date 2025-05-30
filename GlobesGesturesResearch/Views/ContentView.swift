//
//  ContentView.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 14/8/2024.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(ViewModel.self) var model
    @Environment(StudyModel.self) var studyModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpaceAction
    
    /// Track web page loading errors and completion of Google Forms
    @State private var webViewStatus = WebViewStatus.loading
    
    var body: some View {
        viewForCurrentPage
            .id(studyModel.currentPage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: webViewStatus) {
                // after a Google Forms is submitted, show the Google Forms web page for a one second,
                // then switch to the next page.
                if case .googleFormsSubmitted(let message) = webViewStatus {
                    if let page = Page.pageForGoogleForm(confirmationMessage: message) {
                        Task { @MainActor in
                            try await Task.sleep(for: .seconds(1))
                            studyModel.currentPage = page.next()
                        }
                    }
                }
            }
            .overlay(alignment: .bottomLeading) {
                HStack {
                    pageMenu
                    Text("\(studyModel.currentPage.index + 1)")
                }
                .padding(32)
                .foregroundStyle(.secondary)
            }
            .task {
                await model.openImmersiveSpace(openImmersiveSpaceAction)
                _ = SoundManager.shared
            }
            .onChange(of: studyModel.currentPage) {
                model.removeGlobes()
                model.updateAttachmentView(for: studyModel.currentPage)
                model.updatePositionConditions(currentPage: studyModel.currentPage)
                model.updateRotationConditions(currentPage: studyModel.currentPage)
                model.updateScaleConditions(currentPage: studyModel.currentPage)
            }
    }
    
    @ViewBuilder
    private var pageMenu: some View {
        Menu(content: {
            Text("Talk to the researcher before selecting.")
                .font(.callout)
            Section {
                pageButton(.welcome)
                pageButton(.introForm)
            }
            Menu("3–10 Position") {
                pageButton(.positionTraining)
                pageButton(.positionExperiment1)
                pageButton(.confirmationPagePosition1)
                pageButton(.positionExperimentForm1)
                pageButton(.positionExperiment2)
                pageButton(.confirmationPagePosition2)
                pageButton(.positionExperimentForm2)
                pageButton(.positionComparison)
            }
            Menu("11–19 Rotation") {
                pageButton(.rotationTraining1)
                pageButton(.rotationExperiment1)
                pageButton(.confirmationPageRotation1)
                pageButton(.rotationExperimentForm1)
                pageButton(.rotationTraining2)
                pageButton(.rotationExperiment2)
                pageButton(.confirmationPageRotation2)
                pageButton(.rotationExperimentForm2)
                pageButton(.rotationComparison)
            }
            Menu("20–27 Scale") {
                pageButton(.scaleTraining)
                pageButton(.scaleExperiment1)
                pageButton(.confirmationPageScale1)
                pageButton(.scaleExperimentForm1)
                pageButton(.scaleExperiment2)
                pageButton(.confirmationPageScale2)
                pageButton(.scaleExperimentForm2)
                pageButton(.scaleComparison)
            }
            Section {
                pageButton(.outroForm)
                pageButton(.thankYou)
            }
        }, label: {
            Label("Page", systemImage: "ellipsis")
                .labelStyle(.iconOnly)
        })
    }
    
    @ViewBuilder
    private func pageButton(_ page: Page) -> some View {
        Button("\(page.name)") {
            studyModel.currentPage = page
        }
    }
    
    /// A SwiftUI view for the current page.
    @ViewBuilder
    private var viewForCurrentPage: some View {
        switch studyModel.currentPage {
        case .welcome:
            WelcomeView()
        case .positionTraining, .rotationTraining1, .rotationTraining2, .scaleTraining:
            TrainingView()
        case .thankYou:
            ThankYouView()
        case .confirmationPagePosition1, .confirmationPagePosition2,
                .confirmationPageRotation1, .confirmationPageRotation2,
                .confirmationPageScale1, .confirmationPageScale2:
            ConfirmationPage()
        default:
            if studyModel.currentPage.taskDetails != nil {
                // show a task view
                TaskView()
            } else if let googleForm = studyModel.currentPage.googleForm {
                // show a Google Forms view
                WebViewDecorated(
                    showGlobe: showGlobe,
                    url: googleForm.url,
                    googleFormsConfirmationMessage: googleForm.confirmationMessage,
                    webViewStatus: $webViewStatus
                )
            } else {
                // show an error view
                ContentUnavailableView(
                    "An error occurred.",
                    systemImage: "globe",
                    description: Text("No view for \"\(studyModel.currentPage.rawValue)\".")
                )
            }
        }
    }
    
    private var showGlobe: Bool {
        switch studyModel.currentPage {
        case .scaleComparison, .rotationComparison, .positionComparison, .outroForm:
            true
        default:
            false
        }
    }
}
