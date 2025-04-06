//
//  VideoManager.swift
//  GlobesGesturesResearch
//
//  Created by Faisal Agung Abdillah on 6/4/2025.
//

import Foundation
import AVFoundation


class VideoManager {
    static let shared = VideoManager()

    private var players: [String: AVPlayer] = [:]

    private init() {}

    func player(for videoName: String) -> AVPlayer? {
        // If it's already loaded, return it
        if let player = players[videoName] {
            return player
        }

        // Otherwise, try to load and cache it
        guard let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            print("Video file \(videoName).mp4 not found")
            return nil
        }

        let player = AVPlayer(url: videoURL)
        players[videoName] = player
        return player
    }

    func playVideo(named videoName: String) {
        guard let player = player(for: videoName) else { return }
        player.seek(to: .zero)
        player.play()
    }
}
