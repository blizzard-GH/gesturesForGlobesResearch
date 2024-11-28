//
//  Page.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 28/11/2024.
//

import Foundation

/// A sequence of pages that are displayed in the listed order.
enum Page: String, CaseIterable {
    case welcome
    case introForm
    case task1
    case task1Form
    case task2
    case task2Form
    case task3
    case task3Form
    case outroForm
    case thankYou
    
    /// A task number or nil if the page does not start a set of tasks.
    var taskNumber: Int? {
        switch self {
        case .task1:
            1
        case .task2:
            2
        case .task3:
            3
        default:
            nil
        }
    }
    
    /// A `GoogleForm` or nil if the page does not display a form.
    var googleForm: GoogleForm? {
        switch self {
        case .introForm:
            try? GoogleForm(
                "https://forms.gle/z718jhTKjftCDQ7v9",
                confirmationMessage: "Your response has been recorded. (1)" // important: the confirmation message must be unique
            )
        case .task1Form:
            try? GoogleForm(
                "https://forms.gle/gnqP7Pkzx7f6bPoS6",
                confirmationMessage: "Your response has been recorded. (2)" // important: the confirmation message must be unique
            )
        case .task2Form:
            try? GoogleForm(
                "https://forms.gle/eJcuBqsG3VyULZkt7",
                confirmationMessage: "Your response has been recorded. (3)" // important: the confirmation message must be unique
            )
        case .task3Form:
            try? GoogleForm(
                "https://forms.gle/eLq5Dcz5FzJ26rrv9",
                confirmationMessage: "Your response has been recorded. (4)" // important: the confirmation message must be unique
            )
        case .outroForm:
            try? GoogleForm(
                "https://forms.gle/faVXY4bCZ1x6hQVE7",
                confirmationMessage: "Your response has been recorded. (5)" // important: the confirmation message must be unique
            )
        default:
            nil
        }
    }
    
    /// Returns a `Page` for a confirmation message.
    /// - Parameter confirmationMessage: The confirmation message displayed at the end of a Google Forms.
    /// - Returns: A page or nil if no page with a matching confirmation message exists.
    static func pageForGoogleForm(confirmationMessage: String) -> Page? {
        Page.allCases.first(where: { $0.googleForm?.confirmationMessage == confirmationMessage })
    }
    
    /// After a Google Forms is submitted, the Google Forms web page is displayed for these many seconds, before the next page is shown.
    static let googleFormsDelayAfterSubmission = 3
}
