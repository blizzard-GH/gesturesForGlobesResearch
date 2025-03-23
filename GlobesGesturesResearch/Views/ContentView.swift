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
    
    /// The currently displayed  page
    @Binding var currentPage: Page
    
    /// Track web page loading errors and completion of Google Forms
    @State private var webViewStatus = WebViewStatus.loading
        
    var body: some View {
        pageViewForCurrentPage
            .id(currentPage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: webViewStatus) {
                // after a Google Forms is submitted, show the Google Forms web page for a few seconds,
                // then switch to the next page.
                if case .googleFormsSubmitted(let message) = webViewStatus {
                    if let page = Page.pageForGoogleForm(confirmationMessage: message) {
                        Task { @MainActor in
                            let delay = UInt64(Page.googleFormsDelayAfterSubmission) * 1_000_000_000
                            try await Task.sleep(nanoseconds: delay)
                            self.currentPage = page.next()
                        }
                    }
                }
            }
            .overlay(alignment: .bottomLeading) {
                Menu(content: {
                    ForEach(Page.allCases.reversed(), id: \.rawValue) { page in
                        Button("\(page.name)") {
                            currentPage = page
                        }
                    }
                }, label: {
                    Label("Page", systemImage: "ellipsis")
                        .labelStyle(.iconOnly)
                })
                .padding(24)
                .foregroundStyle(.secondary)
            }
    }
    
    /// A SwiftUI view for the current page.
    @ViewBuilder
    private var pageViewForCurrentPage: some View {
        switch currentPage {
        case .welcome:
            WelcomeView(currentPage: $currentPage)
        case .positionTraining, .rotationTraining, .scaleTraining:
            TrainingView(currentPage: $currentPage)
        case .thankYou:
            ThankYouView()
        default:
            if currentPage.taskDetails != nil {
                // show a task view
                TaskView(currentPage: $currentPage)
            } else if let googleForm = currentPage.googleForm {
                // show a Google Forms view
                WebViewDecorated(
                    currentPage: $currentPage,
                    url: googleForm.url,
                    googleFormsConfirmationMessage: googleForm.confirmationMessage,
                    webViewStatus: $webViewStatus
                )
            } else {
                // show an error view
                ContentUnavailableView(
                    "An error occurred.",
                    systemImage: "globe",
                    description: Text("No view for \"\(currentPage.rawValue)\".")
                )
            }
        }
    }
}

//#Preview(windowStyle: .automatic) {
//    ContentView()
//        .environment(ViewModel.preview)
//}
