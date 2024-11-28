//
//  WebViewDecorated.swift
//  Globes
//
//  Created by Bernhard Jenny on 8/4/2024.
//

import SwiftUI

/// A `WebView` for displaying a webpage .
struct WebViewDecorated: View {
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
    }
}

#if DEBUG
#Preview(windowStyle: .automatic) {
    WebViewDecorated(url: URL(string: "https://apple.com")!, webViewStatus: .constant(.loading))
        .environment(ViewModel.preview)
}
#endif
