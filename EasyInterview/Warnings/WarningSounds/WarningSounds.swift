//
//  WarningSounds.swift
//  EasyInterview
//
//  Created by Anna Lerner on 5/21/24.
//

import AVFoundation

class WarningSounds {
    static var audioPlayer: AVAudioPlayer?
    
    static func playSound(file: String) {
        let path = Bundle.main.path(forResource: file, ofType: nil)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path!))
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("something wen't wrong loading the sound to play")
        }
        
        func playSoundWarning(play: Bool) {
            playSound(file: "Soundwarning.m4a")
        }
        
        func playShakyWarning() {
            playSound(file: "Shakywarning")
        }
    }
}
