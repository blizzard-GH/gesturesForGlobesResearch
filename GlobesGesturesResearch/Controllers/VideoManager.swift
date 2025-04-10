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

    private init() {}

    func player(for videoName: String) -> AVPlayer? {
        guard let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            return nil
        }

        return AVPlayer(url: videoURL)
    }

    func playVideo(named videoName: String) {
        guard let player = player(for: videoName) else { return }
        player.seek(to: .zero)
        player.play()
    }
}
