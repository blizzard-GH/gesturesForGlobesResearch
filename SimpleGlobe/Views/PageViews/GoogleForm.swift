//
//  GoogleForm.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 28/11/2024.
//

import Foundation

/// URL and confirmation message of a Google Forms web page.
struct GoogleForm {
    
    /// Web page URL
    let url: URL
    
    /// The confirmation message is used to identify the Google Forms page.
    /// The confirmation message can be customised when setting up the Google Forms with Settings > Presentation > Confirmation message.
    let confirmationMessage: String
    
    init(_ url: String, confirmationMessage: String) throws {
        guard let url = URL(string: url) else {
            throw error("Invalid URL: \(url)")
        }
        self.url = url
        self.confirmationMessage = confirmationMessage
    }
}
