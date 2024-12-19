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
    
    var body: some View {
        VStack {
            // Title Section
            Text(" Match the Globe 🌍 Positions!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top, 20)
            
            // Instruction Text Section
            Text("""
            Please move the globe on the left to match the position of the globe on the right.
            We will measure your average time taken to mateh it.
            """)
                .font(.body)
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            Text("""
            If you have done it you will get a notification.
            Please press the button below to progress to the questionnaire.
            """)
                .font(.subheadline)
                .bold()
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding()
            
        }
        .background(Color(.systemBackground).opacity(0.95)) // Subtle background color
        .cornerRadius(20)
        .padding()
        .shadow(radius: 20)
    }
}

#Preview(windowStyle: .automatic) {
    Instruction()
        .environment(ViewModel.preview)
}
