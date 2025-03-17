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
    case positionExperiment1
    case positionExperimentForm1
    case positionExperiment2
    case positionExperimentForm2
    case positionComparison
    case rotationTraining
    case rotationExperiment1
    case rotationExperimentForm1
    case rotationExperiment2
    case rotationExperimentForm2
    case rotationComparison
    case scaleTraining
    case scaleExperiment1
    case scaleExperimentForm1
    case scaleExperiment2
    case scaleExperimentForm2
    case scaleComparison
    case outroForm
    case thankYou
    
    /// A task number or nil if the page does not start a set of tasks.
    var taskDetails: (taskNumber: String,
                      mainFeature: String,
                      mainVerb: String,
                      description: String,
                      instructions: String,
                      taskGesture: GestureType)? {
        switch self {
        case .positionExperiment1:
            return ("1",
                    "position",
                    "move",
                    "Positioning the globe",
                    "In this technique, the globe spins as the globe moves so the side of the globe facing to you is always the same.",
                    .position)
        case .positionExperiment2:
            return ("2",
                    "position",
                    "move",
                    "Positioning the globe",
                    "In this technique, the globe stays in its position so the side of the globe facing to you is changing.",
                    .position)

        case .rotationExperiment1:
            return ("3",
                    "orientation",
                    "rotate",
                    "Rotating the globe",
                    "In this technique, the rotation is utilising both hands.",
                    .rotation)
        case .rotationExperiment2:
            return ("4",
                    "orientation",
                    "rotate",
                    "Rotating the globe",
                    "In this technique, the rotation is utilising right hand only.",
                    .rotation)

        case .scaleExperiment1:
            return ("5",
                    "size",
                    "scale",
                    "Scaling the globe",
                    "In this technique, the globe moves away as you scale it up, and the other way around.",
                    .scale)
        case .scaleExperiment2:
            return ("6",
                    "size",
                    "scale",
                    "Scaling the globe",
                    "In this technique, the globe maintains its position whether you scale it up or down.",
                    .scale)

        default:
            return nil
        }
    }
    
    var isStoringRecordNeeded: Bool {
        switch self {
        case .positionExperiment1, .positionExperiment2,
                .rotationExperiment1, .rotationExperiment2,
                .scaleExperiment1, .scaleExperiment2 :
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
        case .positionExperiment1:
            "Experiment 1 Position: Rotating globe"
        case .positionExperimentForm1:
            "Experiment 1 Form: Rotating"
        case .positionExperiment2:
            "Experiment 1 Position: Non-rotating globe"
        case .positionExperimentForm2:
            "Experiment 1 Form: Non-rotating"
        case .positionComparison:
            "Position Comparison"
        case .rotationTraining:
            "Rotation Training"
        case .rotationExperiment1:
            "Experiment 2 Rotation: One-handed"
        case .rotationExperimentForm1:
            "Experiment 2 Form: One-handed"
        case .rotationExperiment2:
            "Experiment 2 Rotation: Two-handed"
        case .rotationExperimentForm2:
            "Experiment 2 Form: Two-handed"
        case .rotationComparison:
            "Rotation Comparison"
        case .scaleTraining:
            "Scale Training"
        case .scaleExperiment1:
            "Experiment 3 Scale: Moving"
        case .scaleExperimentForm1:
            "Experiment 3 Form: Moving"
        case .scaleExperiment2:
            "Experiment 3 Scale: Non-Moving"
        case .scaleExperimentForm2:
            "Experiment 3 Form: Non-Moving"
        case .scaleComparison:
            "Scale Comparison"
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
                "https://docs.google.com/forms/d/e/1FAIpQLSe1Xilobm_gtU6L0-bouJByLITb0RnW7MNJ6-QJM0vamX1ogg/viewform?usp=sf_link",
                confirmationMessage: "Your response has been recorded. (1)" // important: the confirmation message must be unique
            )
        case .positionExperimentForm1:
            try? GoogleForm(
                "https://docs.google.com/forms/d/e/1FAIpQLSdrtcQX0gCfNwKhpOvVRPGxkDG1r1Ex1R7G7F1ivb_xAvCoDg/viewform?usp=sf_link",
                confirmationMessage: "Your response has been recorded. (2)" // important: the confirmation message must be unique
            )
        case .positionExperimentForm2:
            try? GoogleForm(
                "https://docs.google.com/forms/d/e/1FAIpQLScYShkgJrhHjOstf6LzBCJhX4UzMsrQ4GXxeMQ06gW2xsfz9w/viewform?usp=dialog",
                confirmationMessage: "Your response has been recorded. (3)" // important: the confirmation message must be unique
            )
        case .positionComparison:
            try? GoogleForm(
                "https://docs.google.com/forms/d/e/1FAIpQLScREXFLdnfY0SFlFYwoRp1huy-Awb8uJQsyk6w-JgwlTGAdrA/viewform?usp=dialog",
                confirmationMessage: "Your response has been recorded. (4)" // important: the confirmation message must be unique
            )
        case .rotationExperimentForm1:
            try? GoogleForm(
                "https://docs.google.com/forms/d/e/1FAIpQLSexmhINS5CRPoVs0GscKjYpIuUo4nmCXdws04flPbzOadpYVg/viewform?usp=sf_link",
                confirmationMessage: "Your response has been recorded. (5)" // important: the confirmation message must be unique
            )
        case .rotationExperimentForm2:
            try? GoogleForm(
                "https://docs.google.com/forms/d/e/1FAIpQLSdLM2qyhpqWVFUCXBLtDgZhmra2RzoM-2acC3ZA2yOFw5GLJw/viewform?usp=dialog",
                confirmationMessage: "Your response has been recorded. (6)" // important: the confirmation message must be unique
            )
        case .rotationComparison:
            try? GoogleForm(
                "https://docs.google.com/forms/d/e/1FAIpQLSeHuya6gsUG5g8oeXBhIWLUeO8rJcdCsG0uCzHnKKMYXG-5cw/viewform?usp=dialog",
                confirmationMessage: "Your response has been recorded. (7)" // important: the confirmation message must be unique
            )
        case .scaleExperimentForm1:
            try? GoogleForm(
                "https://docs.google.com/forms/d/e/1FAIpQLSckrzXqM1lTyXppZxBu7stzjhL4uerWhbmA2ecGU9yi5fj5wg/viewform?usp=sf_link",
                confirmationMessage: "Your response has been recorded. (8)" // important: the confirmation message must be unique
            )
        case .scaleExperimentForm2:
            try? GoogleForm(
                "https://docs.google.com/forms/d/e/1FAIpQLSckrUMK8jPUjr3Nkbvmy2BDh3x9wFPpX1edR7_eNHdQ-VHvuA/viewform?usp=dialog",
                confirmationMessage: "Your response has been recorded. (9)" // important: the confirmation message must be unique
            )
        case .scaleComparison:
            try? GoogleForm(
                "https://docs.google.com/forms/d/e/1FAIpQLSf9tKcgN72UUELSFL8fe1cYfRQSpmrED_nN6Vr6Q_AWl0vSiA/viewform?usp=dialog",
                confirmationMessage: "Your response has been recorded. (10)" // important: the confirmation message must be unique
            )
        case .outroForm:
            try? GoogleForm(
                "https://docs.google.com/forms/d/e/1FAIpQLSdaifETp4NuIiuQmhi8_5u5ecOtls5Rne-9XZ2mkU8Y_KgMjQ/viewform?usp=sf_link",
                confirmationMessage: "Your response has been recorded. (11)" // important: the confirmation message must be unique
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
