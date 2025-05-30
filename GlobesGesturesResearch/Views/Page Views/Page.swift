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
    case confirmationPagePosition1
    case positionExperimentForm1
    case positionExperiment2
    case confirmationPagePosition2
    case positionExperimentForm2
    case positionComparison
    case rotationTraining1
    case rotationExperiment1
    case confirmationPageRotation1
    case rotationExperimentForm1
    case rotationTraining2
    case rotationExperiment2
    case confirmationPageRotation2
    case rotationExperimentForm2
    case rotationComparison
    case scaleTraining
    case scaleExperiment1
    case confirmationPageScale1
    case scaleExperimentForm1
    case scaleExperiment2
    case confirmationPageScale2
    case scaleExperimentForm2
    case scaleComparison
    case outroForm
    case thankYou
    
    
    /// A task number or nil if the page does not have a set of tasks.
    var taskDetails: (taskNumber: String,
                      partNumber: String,
                      mainFeature: String,
                      mainGerund: String,
                      mainVerb: String,
                      description: String,
                      instructions: String,
                      taskGesture: GestureType)? {
        let instructions = "When you are ready, press the button below."
        switch self {
        case .positionExperiment1:
            return ("1",
                    "1",
                    "position",
                    "positioning",
                    "move",
                    "Positioning the globe",
                    instructions,
                    .position)
        case .positionExperiment2:
            return ("2",
                    "1",
                    "position",
                    "positioning",
                    "move",
                    "Positioning the globe",
                    instructions,
                    .position)

        case .rotationExperiment1:
            return ("3",
                    "2",
                    "orientation",
                    "rotating",
                    "rotate",
                    "Rotating the globe",
                    instructions,
                    .rotation)
        case .rotationExperiment2:
            return ("4",
                    "2",
                    "orientation",
                    "rotating",
                    "rotate",
                    "Rotating the globe",
                    instructions,
                    .rotation)

        case .scaleExperiment1:
            return ("5",
                    "3",
                    "size",
                    "scaling",
                    "scale",
                    "Scaling the globe",
                    instructions,
                    .scale)
        case .scaleExperiment2:
            return ("6",
                    "3",
                    "size",
                    "scaling",
                    "scale",
                    "Scaling the globe",
                    instructions,
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
            return ("positioning globes",
                    "position",
                    "Look at the globes, then pinch and hold your fingers while moving to match the transparent globe position.")
            
        case .rotationTraining1, .rotationTraining2:
            return ("rotating globes",
                    "rotate",
                    "Look at the globes, then make a rotate with one or two hands.")
            
        case .scaleTraining:
            return ("scaling globes",
                    "scale",
                    "Look at the globes, then adjust the size of the globe using both hands.")
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
            "1. Welcome Display"
        case .introForm:
            "2. Introduction"
        case .positionTraining:
            "3. Position Training"
        case .positionExperiment1:
            "4. Experiment 1 Position: First Technique"
        case .confirmationPagePosition1:
            "5. Confirmation Page: Position 1"
        case .positionExperimentForm1:
            "6. Experiment 1 Form for First Technique"
        case .positionExperiment2:
            "7. Experiment 1 Position: Second Technique"
        case .confirmationPagePosition2:
            "8. Confirmation Page: Position 2"
        case .positionExperimentForm2:
            "9. Experiment 1 Form for Second Technique"
        case .positionComparison:
            "10. Position Comparison"
        case .rotationTraining1:
            "11. Rotation Training: First Technique"
        case .rotationExperiment1:
            "12. Experiment 2 Rotation: First Technique"
        case .confirmationPageRotation1:
            "13. Confirmation Page: Rotation 1"
        case .rotationExperimentForm1:
            "14. Experiment 2 Form for First Technique"
        case .rotationTraining2:
            "15. Rotation training: Second Technique"
        case .rotationExperiment2:
            "16. Experiment 2 Rotation: Second Technique"
        case .confirmationPageRotation2:
            "17. Confirmation Page: Rotation 2"
        case .rotationExperimentForm2:
            "18. Experiment 2 Form for Second Technique"
        case .rotationComparison:
            "19. Rotation Comparison"
        case .scaleTraining:
            "20. Scale Training"
        case .scaleExperiment1:
            "21. Experiment 3 Scale: First Technique"
        case .confirmationPageScale1:
            "22. Confirmation Page: Scale 1"
        case .scaleExperimentForm1:
            "23. Experiment 3 Form for First Technique"
        case .scaleExperiment2:
            "24. Experiment 3 Scale: Second Technique"
        case .confirmationPageScale2:
            "25. Confirmation Page: Scale 2"
        case .scaleExperimentForm2:
            "26. Experiment 3 Form for Second Technique"
        case .scaleComparison:
            "27. Scale Comparison"
        case .outroForm:
            "28. Gesture Combination Form"
        case .thankYou:
            "29. Thank You"
        }
    }
    
    @MainActor var googleForm: GoogleForm? {
        switch self {
        case .introForm:
            return try? GoogleForm(
                "https://docs.google.com/forms/d/e/1FAIpQLSe1Xilobm_gtU6L0-bouJByLITb0RnW7MNJ6-QJM0vamX1ogg/viewform?usp=sf_link",
                confirmationMessage: "Your response has been recorded. (1)" // important: the confirmation message must be unique
            )
        case .positionExperimentForm1:
            if ViewModel.shared.rotateGlobeWhileDragging {
                return try? GoogleForm(
                    "https://docs.google.com/forms/d/e/1FAIpQLSdrtcQX0gCfNwKhpOvVRPGxkDG1r1Ex1R7G7F1ivb_xAvCoDg/viewform?usp=sf_link",
                    confirmationMessage: "Your response has been recorded. (2a1)" // important: the confirmation message must be unique
                )
            } else {
                return try? GoogleForm(
                    "https://docs.google.com/forms/d/e/1FAIpQLScYShkgJrhHjOstf6LzBCJhX4UzMsrQ4GXxeMQ06gW2xsfz9w/viewform?usp=dialog",
                    confirmationMessage: "Your response has been recorded. (2b1)" // important: the confirmation message must be unique
                )
            }
        case .positionExperimentForm2:
            if ViewModel.shared.rotateGlobeWhileDragging {
                return try? GoogleForm(
                    "https://docs.google.com/forms/d/e/1FAIpQLSdGmXH3OKfuM4U28Dw86uHAPGfaSD-WFyO2-VaKrrvUxkCbzw/viewform?usp=dialog",
                    confirmationMessage: "Your response has been recorded. (2a2)" // important: the confirmation message must be unique
                )
            } else {
                return try? GoogleForm(
                    "https://docs.google.com/forms/d/e/1FAIpQLScI-EwFvPdEO1uL9jnPb76fdrObMXLyKoIKbWdH8hOYNqZvmg/viewform?usp=dialog",
                    confirmationMessage: "Your response has been recorded. (2b2)" // important: the confirmation message must be unique
                )
            }
        case .positionComparison:
            return try? GoogleForm(
                "https://docs.google.com/forms/d/e/1FAIpQLScREXFLdnfY0SFlFYwoRp1huy-Awb8uJQsyk6w-JgwlTGAdrA/viewform?usp=dialog",
                confirmationMessage: "Your response has been recorded. (3)" // important: the confirmation message must be unique
            )
        case .rotationExperimentForm1:
            if ViewModel.shared.oneHandedRotationGesture {
                return try? GoogleForm(
                    "https://docs.google.com/forms/d/e/1FAIpQLSexmhINS5CRPoVs0GscKjYpIuUo4nmCXdws04flPbzOadpYVg/viewform?usp=sf_link",
                    confirmationMessage: "Your response has been recorded. (4a1)" // important: the confirmation message must be unique
                )
            } else {
                return try? GoogleForm(
                    "https://docs.google.com/forms/d/e/1FAIpQLSdLM2qyhpqWVFUCXBLtDgZhmra2RzoM-2acC3ZA2yOFw5GLJw/viewform?usp=dialog",
                    confirmationMessage: "Your response has been recorded. (4b1)" // important: the confirmation message must be unique
                )
            }
        case .rotationExperimentForm2:
            if ViewModel.shared.oneHandedRotationGesture {
                return try? GoogleForm(
                    "https://docs.google.com/forms/d/e/1FAIpQLSfpl82GZQQNmGJTBaPmWumfA_BvRrg5kcb06b-1twD9ldk4GA/viewform?usp=dialog",
                    confirmationMessage: "Your response has been recorded. (4a2)" // important: the confirmation message must be unique
                )
            } else {
                return try? GoogleForm(
                    "https://docs.google.com/forms/d/e/1FAIpQLSfc1hFSlVNZ52nrJW3Ec4glHFm_YxJIOd-eGvZZdYD5p_Ctzg/viewform?usp=dialog",
                    confirmationMessage: "Your response has been recorded. (4b2)" // important: the confirmation message must be unique
                )
            }
            
        case .rotationComparison:
            return try? GoogleForm(
                "https://docs.google.com/forms/d/e/1FAIpQLSeHuya6gsUG5g8oeXBhIWLUeO8rJcdCsG0uCzHnKKMYXG-5cw/viewform?usp=dialog",
                confirmationMessage: "Your response has been recorded. (5)" // important: the confirmation message must be unique
            )
        case .scaleExperimentForm1:
            if ViewModel.shared.moveGlobeWhileScaling {
                return try? GoogleForm(
                    "https://docs.google.com/forms/d/e/1FAIpQLSckrzXqM1lTyXppZxBu7stzjhL4uerWhbmA2ecGU9yi5fj5wg/viewform?usp=sf_link",
                    confirmationMessage: "Your response has been recorded. (6a1)" // important: the confirmation message must be unique
                )
            } else {
                return try? GoogleForm(
                    "https://docs.google.com/forms/d/e/1FAIpQLSckrUMK8jPUjr3Nkbvmy2BDh3x9wFPpX1edR7_eNHdQ-VHvuA/viewform?usp=dialog",
                    confirmationMessage: "Your response has been recorded. (6b1)" // important: the confirmation message must be unique
                )
            }
        case .scaleExperimentForm2:
            if ViewModel.shared.moveGlobeWhileScaling {
                return try? GoogleForm(
                    "https://docs.google.com/forms/d/e/1FAIpQLSdIMrbD3itw5G85htgzNmYlREvkwPfQ8BKgiRDvSj6NurfSLw/viewform?usp=dialog",
                    confirmationMessage: "Your response has been recorded. (6a2)" // important: the confirmation message must be unique
                )
            } else {
                return try? GoogleForm(
                    "https://docs.google.com/forms/d/e/1FAIpQLSfiD5_nLAgWCx9YbJAxzNhZHxgkG_Gyd3wKY57Ydk9JeZeYDg/viewform?usp=dialog",
                    confirmationMessage: "Your response has been recorded. (6b2)" // important: the confirmation message must be unique
                )
            }
        case .scaleComparison:
            return try? GoogleForm(
                "https://docs.google.com/forms/d/e/1FAIpQLSf9tKcgN72UUELSFL8fe1cYfRQSpmrED_nN6Vr6Q_AWl0vSiA/viewform?usp=dialog",
                confirmationMessage: "Your response has been recorded. (7)" // important: the confirmation message must be unique
            )
        case .outroForm:
            return try? GoogleForm(
                "https://docs.google.com/forms/d/e/1FAIpQLSdaifETp4NuIiuQmhi8_5u5ecOtls5Rne-9XZ2mkU8Y_KgMjQ/viewform?usp=sf_link",
                confirmationMessage: "Your response has been recorded. (8)" // important: the confirmation message must be unique
            )
        default:
            return nil
        }
    }
    
    /// Returns a `Page` for a confirmation message.
    /// - Parameter confirmationMessage: The confirmation message displayed at the end of a Google Forms.
    /// - Returns: A page or nil if no page with a matching confirmation message exists.
    @MainActor static func pageForGoogleForm(confirmationMessage: String) -> Page? {
        Page.allCases.first(where: { $0.googleForm?.confirmationMessage == confirmationMessage })
    }
    
    /// After a Google Forms is submitted, the Google Forms web page is displayed for these many seconds, before the next page is shown.
    static let googleFormsDelayAfterSubmission = 3
}
