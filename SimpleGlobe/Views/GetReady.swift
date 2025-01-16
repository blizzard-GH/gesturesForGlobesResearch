//
//  GetReady.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 18/12/2024.
//

import SwiftUI

struct GetReady: View {
    @Environment(ViewModel.self) private var model
    @Environment(\.openImmersiveSpace) var openImmersiveSpaceAction
    
    @State private var remainingTime: Int = 2
    @State private var timer: Timer? = nil
    
    var onCountdownComplete: () -> Void
    
    var body: some View {
        VStack {
            Text(" Get ready! ")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top, 20)
            
            Text("""
            After \(remainingTime) seconds, the timer will begin to count your elapsed time to complete the task.
            """)
                .font(.body)
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            Text(remainingTime > 0 ? "Starting in: \(remainingTime) seconds" : "Go!")
                .font(.largeTitle)
                .bold()
                .foregroundColor(remainingTime > 0 ? .red : .green)
                .padding()
            Text("""
            If you have done the task you will get a notification.
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
        .onAppear(perform: startCountdown)
    }
    
    func startCountdown() {
        timer?.invalidate()
//        remainingTime = 2
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                timer?.invalidate()
                onCountdownComplete()
            }
        }
    }
}

