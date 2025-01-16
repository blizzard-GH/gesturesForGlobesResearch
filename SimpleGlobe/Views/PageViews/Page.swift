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
    case task1a // Positioning; time task //Should be named 'measure'
    case task1b // Positioning; accuracy task
    case task1Form
    case task2a // Rotation; time task
    case task2b // Rotation; accuracy task
    case task2Form
    case task3a // scale; time task
    case task3b // scale; accuracy task
    case task3Form
    case outroForm
    case thankYou
    
    /// A task number or nil if the page does not start a set of tasks.
    var taskDetails: (taskNumber: String,
                      description: String,
                      instructions: String,
                      taskMode: TaskMode,
                      taskGesture: GestureType)? {
        switch self {
        case .task1a:
            return ("1a",
                    "Positioning the globe",
                    "We are measuring the time required to properly position the globe.",
                    .time,
                    .positioning)
        case .task1b:
            return ("1b",
                    "Positioning the globe",
                    "We are measuring the attempts required to properly position the globe",
                    .accuracy,
                    .positioning)
        case .task2a:
            return ("2a",
                    "Rotating the globe",
                    "We are measuring the time required to properly rotate the globe.",
                    .time,
                    .rotation)
        case .task2b:
            return ("2b",
                    "Rotating the globe",
                    "We are measuring the attempts required to properly rotate the globe.",
                    .accuracy,
                    .rotation)
        case .task3a:
            return ("3a",
                    "Scaling the globe",
                    "We are measuring the time required to properly scale the globe.",
                    .time,
                    .scale)
        case .task3b:
            return ("3b",
                    "Scaling the globe",
                    "We are measuring the attempts required to properly scale the globe",
                    .accuracy,
                    .scale)
        default:
            return nil
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
