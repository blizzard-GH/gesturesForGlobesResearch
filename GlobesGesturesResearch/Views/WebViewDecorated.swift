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
    
    let showGlobe: Bool
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
            case .failed:
                VStack {
                    Text("The page could not be loaded.")
                }
                .padding()
                .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 20))
            }
        }
        //        .id(url)
        .task {
            webViewStatus = .loading
            if showGlobe {
                // The immersive space is normally already open, in which case openImmersiveSpace will not do anything.
                // The immersive space is closed if the user previously pressed the crown button, in which case it needs to be opened again.
                await model.openImmersiveSpace(openImmersiveSpaceAction)
                
                await model.load(globe: model.globe)
            }
        }
    }
}
