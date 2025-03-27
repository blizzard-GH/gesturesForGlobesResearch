//
//  GlobeButton.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 11/12/2024.
//

import SwiftUI

struct StartTaskButton: View {
    @Environment(ViewModel.self) private var model
    
    @Binding var isDoingTask: Bool
    
    var body: some View {
        VStack {
            Button(action: {
                isDoingTask = true
                })
            {
                if !isDoingTask{
                    Label("Start Task", systemImage: "globe")
                }
            }
            .bold()
            .buttonStyle(PlainButtonStyle())
            .padding()
            .frame(maxWidth: 200, maxHeight: 50)
            .background(isDoingTask ? Color.cyan.opacity(0.5) : Color.blue)
            .cornerRadius(10)
            .shadow(radius: 5)
            .scaleEffect(isDoingTask ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isDoingTask)
            
            ProgressView()
                .opacity(model.configuration.isLoading ? 1 : 0)
                .padding()
        }
    }
}
