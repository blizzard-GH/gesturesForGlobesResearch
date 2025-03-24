//
//  Instructions.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 17/12/2024.
//

//import SwiftUI
//
//struct Instruction: View {
//    @Environment(ViewModel.self) private var model
//    @Environment(\.openImmersiveSpace) var openImmersiveSpaceAction
//    
//    var body: some View{
//        VStack{
//            Text("""
//            Please move the globe in the left to match the position of the globe in the right
//            """)
//            .italic()
//            .font(.body)
//            .padding()
//            .frame(width: 800)
//        }
//    }
//    
//}

import SwiftUI

struct Instruction: View {
    @Environment(ViewModel.self) private var model
    @Environment(\.openImmersiveSpace) var openImmersiveSpaceAction
    
    @Binding var currentPage: Page
    
    var body: some View {
        VStack {
            if let details = currentPage.taskDetails {
                // Title Section
                Text(" Match the globe \(details.mainFeature)!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 20)
                
                // Instruction Text Section
                Text("""
            Please \(details.mainVerb) the main globe to match the \(details.mainFeature) of the transparent globe.
            """)
                .font(.body)
                .bold()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            }
        }
        .background(Color(.systemBackground).opacity(0.95)) // Subtle background color
        .cornerRadius(20)
        .padding()
        .shadow(radius: 20)
    }
}

//#Preview(windowStyle: .automatic) {
//    Instruction()
//        .environment(ViewModel.preview)
//}
