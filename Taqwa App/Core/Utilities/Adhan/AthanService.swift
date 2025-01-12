//
//  AthanService.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/12/25.
//
import AVFoundation
import UserNotifications

class AdhanAudioService: NSObject {
    static let shared = AdhanAudioService()
    private var audioPlayer: AVAudioPlayer?
    
    func playAdhan() {
        guard let url = Bundle.main.url(forResource: "azan2", withExtension: "mp3") else {
            print("⚠️ Could not find azan2.mp3")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("⚠️ Error playing adhan: \(error)")
        }
    }
}

extension AdhanAudioService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
