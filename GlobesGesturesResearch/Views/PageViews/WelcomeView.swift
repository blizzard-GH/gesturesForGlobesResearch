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
    @Environment(ViewModel.self) var model
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                VStack{
                    Text("Welcome to the User Study")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("""
This study explores the most effective and intuitive gestures to interact with virtual globes. Your participation will help us better understand intuitive gestures for positioning, scaling, and rotating in 3D environments.
            
Please follow the instructions on the next screens. Thank you for contributing to this research!
""")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                    
                    Button(action: {
                        currentPage = currentPage.next()
                    }){
                        Text("Let's begin")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemGray2)).shadow(radius: 5))
                .padding(.horizontal, 40)
                Spacer()
            }
            
            VStack {
                Spacer()
                VStack(alignment: .trailing){
                    Spacer()
                    HStack{
                        Spacer()
                    }
                    if TaskStorageManager.storageFileRead {
                        HStack {
                            Text("Storage file is properly loaded and ready")
                                .foregroundColor(.cyan)
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    } else {
                        HStack {
                            Text("Storage file is not properly loaded")
                                .foregroundColor(.yellow)
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
                HStack{
                    Spacer()
                    if !model.positionConditions.isEmpty && !model.rotationConditions.isEmpty && !model.scaleConditions.isEmpty {
                        HStack {
                            Text("Study conditions are properly loaded and ready")
                                .foregroundColor(.cyan)
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    } else {
                        HStack {
                            Text("Study conditions are not properly loaded")
                                .foregroundColor(.yellow)
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            .padding(40)
        }
    }
}
    
//#Preview {
//    WelcomeView(currentPage: .constant(.welcome))
//}
