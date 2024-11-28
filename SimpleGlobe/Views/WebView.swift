// Show a web page in a view

import SwiftUI
import WebKit

enum WebViewStatus: Equatable {
    case loading
    case finishedLoading
    case failed(error: EquatableError)
    case googleFormsSubmitted(message: String)
}

struct WebView: UIViewRepresentable {
    let url: URL
    let googleFormsConfirmationMessage: String?
    @Binding var status: WebViewStatus
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            Task { @MainActor in
                self.parent.status = .loading
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor in
                self.parent.status = .finishedLoading
                testGoogleFormsSubmission(webView)
            }
        }
        
        private func testGoogleFormsSubmission(_ webView: WKWebView) {
            guard let googleFormsConfirmationMessage = parent.googleFormsConfirmationMessage else { return }
            
            // Detect submission of a Google Forms: https://stackoverflow.com/a/62715346
            // The value of the final statement in the injected javascript is the return value
            let javaScript = """
                var elements = document.getElementsByClassName('vHW8K');
                if (elements.length > 0 && elements[0].textContent == '\(googleFormsConfirmationMessage)') {
                    true;
                } else {
                    false;
                }
                """
            webView.evaluateJavaScript(javaScript) { (result, error) in
                guard error == nil else {
                    self.parent.status = .failed(error: error!.toEquatableError())
                    return
                }
                if result as? Bool == true {
                    self.parent.status = .googleFormsSubmitted(message: googleFormsConfirmationMessage)
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in
                self.parent.status = .failed(error: error.toEquatableError())
            }
        }
    }
}

extension URL {
    func absoluteStringByTrimmingQuery() -> String? {
        if var urlcomponents = URLComponents(url: self, resolvingAgainstBaseURL: false) {
            urlcomponents.query = nil
            return urlcomponents.string
        }
        return nil
    }
}
