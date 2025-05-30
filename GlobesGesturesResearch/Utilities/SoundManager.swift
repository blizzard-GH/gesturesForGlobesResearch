//
//  SoundManager.swift
//  GlobesGesturesResearch
//
//  Created by Faisal Agung Abdillah on 16/3/2025.
//

import AVFoundation
import Foundation
import os
import UIKit

@MainActor
class SoundManager {
    
    static let shared = SoundManager()

    private var audioPlayers: [String: AVAudioPlayer] = [:]

    private init() {
        preloadSound(named: "correct")
        preloadSound(named: "enterAndExit")
        
        NotificationCenter.default.addObserver(forName: Notification.Name("playCorrectSound"), object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in
                self?.playSound(named: "correct")
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("playEnterAndExitSound"), object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in
                self?.playSound(named: "enterAndExit")
            }
        }
    }
    
    func preloadSound(named soundName: String) {
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            Logger().error("Sound file \(soundName).mp3 not found")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: soundURL)
            player.prepareToPlay()
            audioPlayers[soundName] = player
        } catch {
            Logger().error("Error preloading sound \(soundName): \(error.localizedDescription)")
        }
    }

    func playSound(named soundName: String) {
        audioPlayers[soundName]?.play()
    }
}
