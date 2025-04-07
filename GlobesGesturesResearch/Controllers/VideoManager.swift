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
        if let player = players[videoName] {
            return player
        }

        guard let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
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
