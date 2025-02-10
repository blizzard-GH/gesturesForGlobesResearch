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
    
    @Binding var currentPage: Page
    let url: URL
    var googleFormsConfirmationMessage: String? = nil
    
    @Binding var webViewStatus: WebViewStatus
    
    var body: some View {
        ZStack {
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
        .id(url)
        .onAppear{
            webViewStatus = .loading
            updateAttachmentView()
            showOrHideGlobe(true)
        }
        .onDisappear{
            showOrHideGlobe(false)
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
                    model.hideGlobe()
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
