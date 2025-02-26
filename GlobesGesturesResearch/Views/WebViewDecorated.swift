//
//  WebViewDecorated.swift
//  Globes
//
//  Created by Bernhard Jenny on 8/4/2024.
//

import SwiftUI

/// A `WebView` for displaying a webpage .
struct WebViewDecorated: View {
    
    @Environment(ViewModel.self) var model
    @Environment(\.openImmersiveSpace) var openImmersiveSpaceAction
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpaceAction

    @State var loadingInformation: Bool = false
    
    @Binding var currentPage: Page
    let url: URL
    var googleFormsConfirmationMessage: String? = nil
    
    @Binding var webViewStatus: WebViewStatus
    
    var body: some View {
        ZStack {
            if loadingInformation {
                ProgressView("Loading...") // Show loading indicator
                    .font(.headline)
                    .padding()
            } else {
                WebView(
                    url: url,
                    googleFormsConfirmationMessage: googleFormsConfirmationMessage,
                    status: $webViewStatus
                )
                
                switch webViewStatus {
                case .loading:
                    ProgressView("Loading Page")
                        .padding()
                        .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 20))
                case .finishedLoading, .googleFormsSubmitted:
                    EmptyView()
                case .failed(let error):
                    VStack {
                        Text("The page could not be loaded.")
                        Text(error.localizedDescription)
                    }
                    .padding()
                    .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .id(url)
        .onAppear{
            loadingInformation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                webViewStatus = .loading
                updateAttachmentView()
                showOrHideGlobe(true)
                loadingInformation = false
            }
        }
        .onDisappear{
            showOrHideGlobe(false)
//            model.closeImmersiveGlobeSpace(dismissImmersiveSpaceAction)

        }
    }
    
    @MainActor
    private func showOrHideGlobe(_ show: Bool) {
        if currentPage != .introForm && currentPage != .outroForm {
            Task { @MainActor in
                
                try await Task.sleep(nanoseconds: 100_000_000)
                
                if show {
                    guard !model.configuration.isVisible else { return }
                    model.load(
                        firstGlobe: model.globe,
                        secondGlobe: model.secondGlobe,
                        openImmersiveSpaceAction: openImmersiveSpaceAction
                    )
                } else {
                    guard model.configuration.isVisible else { return }
                    model.hideGlobe(dismissImmersiveSpaceAction:dismissImmersiveSpaceAction)
                }
            }
        }
    }
    
    private func updateAttachmentView() {
            switch currentPage {
            case .positionExperimentForm:
                model.attachmentView = .position
            case .scaleExperimentForm:
                model.attachmentView = .scale
            default:
                model.attachmentView = .none
            }
        }
}

//#if DEBUG
//#Preview(windowStyle: .automatic) {
//    WebViewDecorated(url: URL(string: "https://apple.com")!, webViewStatus: .constant(.loading))
//        .environment(ViewModel.preview)
//}
//#endif
