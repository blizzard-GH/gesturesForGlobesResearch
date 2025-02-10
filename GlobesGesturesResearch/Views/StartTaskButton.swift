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
            .buttonStyle(PlainButtonStyle())
            
            ProgressView()
                .opacity(model.configuration.isLoading ? 1 : 0)
                .padding()
        }
    }
}
