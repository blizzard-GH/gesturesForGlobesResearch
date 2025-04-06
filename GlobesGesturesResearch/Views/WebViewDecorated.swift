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
            model.updateAttachmentView(for: currentPage)
            
            // show the globe
            // async is used to prevent isVisible state and loadSinglleGlobe racing problem
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if currentPage != .introForm && !model.configuration.isVisible {
                    model.loadSingleGlobe(globe: model.globe, openImmersiveSpaceAction: openImmersiveSpaceAction)
                }
            }
        }
        .onDisappear{
            if currentPage != .introForm && model.configuration.isVisible {
                model.hideGlobes(dismissImmersiveSpaceAction:dismissImmersiveSpaceAction)
            }
        }
    }
}

#if DEBUG
#Preview(windowStyle: .automatic) {
    @Previewable @State var webViewStatus = WebViewStatus.loading
    WebViewDecorated(currentPage: .constant(.welcome), url: URL(string: "https://monash.edu")!, webViewStatus: $webViewStatus)
        .glassBackgroundEffect()
        .environment(ViewModel.preview)
}
#endif
