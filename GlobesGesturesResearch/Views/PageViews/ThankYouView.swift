//
//  ThankYouView.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 28/11/2024.
//

import SwiftUI

/// The last view shown.
struct ThankYouView: View {
    
    var body: some View {
        ZStack{
            VStack{
                Spacer()
            }
            .frame(maxWidth: 750, maxHeight: 350)
            .padding(40)
            .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemGray4)).shadow(radius: 5))
            .padding(.horizontal, 40)
            
            VStack(spacing : 40) {
                HStack{
                    Text("You have reached the end.")
                        .font(.body)
                        .padding()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                Text("Thank you for participating in this study!")
                    .font(.largeTitle)
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("Your feedback is invaluable in improving future research!")
                    .font(.body)
                    .foregroundColor(.teal)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(40)
            .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemGray2)).shadow(radius: 5))
        }
    }
}

//#Preview{
//    ThankYouView()
//}
