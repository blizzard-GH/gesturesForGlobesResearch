//
//  SoundManager.swift
//  GlobesGesturesResearch
//
//  Created by Faisal Agung Abdillah on 16/3/2025.
//

import UIKit
import AVFoundation

import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager() 

    private var audioPlayer: AVAudioPlayer?

    private init() {
        preloadSound()
        
        NotificationCenter.default.addObserver(forName: Notification.Name("playCorrectSound"), object: nil, queue: .main) { [weak self] _ in
            self?.playCorrectSound()
        }
    }
    
    func preloadSound() {
        guard let soundURL = Bundle.main.url(forResource: "correct", withExtension: "mp3") else {
            print("Sound file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
             print("Error preloading sound: \(error.localizedDescription)")
         }
    }

    func playCorrectSound() {
        audioPlayer?.play()
    }
}
