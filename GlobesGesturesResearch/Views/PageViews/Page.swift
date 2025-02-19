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
    case positionTraining
    case positionExperiment
    case positionExperimentForm
    case rotationTraining
    case rotationExperiment
    case rotationExperimentForm
    case scaleTraining
    case scaleExperiment
    case scaleExperimentForm
    case outroForm
    case thankYou
    
    /// A task number or nil if the page does not start a set of tasks.
    var taskDetails: (taskNumber: String,
                      description: String,
                      instructions: String,
                      taskGesture: GestureType)? {
        switch self {
        case .positionExperiment:
            return ("1",
                    "Positioning the globe",
                    "We are measuring the time required to properly position the globe.",
                    .position)

        case .rotationExperiment:
            return ("2",
                    "Rotating the globe",
                    "We are measuring the time required to properly rotate the globe.",
                    .rotation)

        case .scaleExperiment:
            return ("3",
                    "Scaling the globe",
                    "We are measuring the time required to properly scale the globe.",
                    .scale)

        default:
            return nil
        }
    }
    
    var isStoringRecordNeeded: Bool {
        switch self {
        case .positionExperiment, .rotationExperiment, .scaleExperiment:
            return true
        default:
            return false
        }
    }
    
    var trainingDetails: (trainingType: String,
                          gestureMethod: String,
                          trainingDescription: String) {
        switch self {
        case .positionTraining:
            return ("position gesture",
                    "drag gesture",
                    "Look at the globes, pinch your finger, and hold it while dragging your pinching fingers anywhere")
            
        case .rotationTraining:
            return ("rotation gesture",
                    "rotate gesture",
                    "Look at the globe, make a rotation gesture")
            
        case .scaleTraining:
            return ("scale gesture",
                    "magnify gesture",
                    "Look at the globes, make a magnify gesture by using thumb and index finger")
        default:
            return ("None",
                    "None",
                    "None")
        }
    }
    
    /// Name for display in UI
    var name: String {
        switch self {
        case .welcome:
            "Welcome display"
        case .introForm:
            "Introduction"
        case .positionTraining:
            "Position Training"
        case .positionExperiment:
            "Experiment 1: Position"
        case .positionExperimentForm:
            "Experiment 1 Form"
        case .rotationTraining:
            "Rotation Training"
        case .rotationExperiment:
            "Experiment 2: Rotation"
        case .rotationExperimentForm:
            "Experiment 2: Form"
        case .scaleTraining:
            "Scale Training"
        case .scaleExperiment:
            "Experiment 3: Scale"
        case .scaleExperimentForm:
            "Experiment 3: Form"
        case .outroForm:
            "End Form"
        case .thankYou:
            "Thank You display"
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
        case .positionExperimentForm:
            try? GoogleForm(
                "https://forms.gle/gnqP7Pkzx7f6bPoS6",
                confirmationMessage: "Your response has been recorded. (2)" // important: the confirmation message must be unique
            )
        case .rotationExperimentForm:
            try? GoogleForm(
                "https://forms.gle/eJcuBqsG3VyULZkt7",
                confirmationMessage: "Your response has been recorded. (3)" // important: the confirmation message must be unique
            )
        case .scaleExperimentForm:
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
