//
//  AudioPlayer.swift
//  TennisStarter
//
//  Created by GEORGE HARRISON on 27/03/2025.
//  Copyright © 2025 University of Chester. All rights reserved.
//

import Foundation
import AVFAudio

class AudioPlayer {
    private var player: AVAudioPlayer?

    // code for audio playing adapted from: https://medium.com/@samwise23/playing-audio-with-avplayer-in-swift-b3ce82fbeb6d
    func play(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}
