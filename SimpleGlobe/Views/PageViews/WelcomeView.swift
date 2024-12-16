//
//  WelcomeView.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 28/11/2024.
//

import SwiftUI

/// The first view shown.
//struct WelcomeView: View {
//    @Binding var currentPage: Page
//    
//    var body: some View {
//        VStack {
//            Text("Hi There! Welcome to Gestures for Globes User Study")
//                .font(.largeTitle)
//            Text("Hi")
//                .font(.body)
//            Button("Let's begin") {
//                currentPage = currentPage.next()
//            }
//        }
//    }
//}

struct WelcomeView: View {
    @Binding var currentPage: Page
    
    var body: some View {
        VStack {
            Text("Welcome to the Gestures for Globes User Study")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("""
This study explores the most effective and intuitive gestures to interact with virtual globes. Your participation will help us better understand intuitive gestures for positioning, scaling, and rotating in 3D environments.
            
Please follow the instructions on the next screens carefully. Thank you for contributing to this research!
""")
            .font(.body)
            .multilineTextAlignment(.center)
            .padding()
            
            Button(action: {
                currentPage = currentPage.next()}){
                    Text("Let's begin")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
        }
    }
}
    
#Preview {
    WelcomeView(currentPage: .constant(.welcome))
}
