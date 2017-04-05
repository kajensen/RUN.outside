//
//  SpeechManager.swift
//  RUN
//
//  Created by Kurt Jensen on 3/29/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import AVFoundation

class SpeechManager: NSObject {
    
    let session = AVAudioSession.sharedInstance()
    var synthesizer: AVSpeechSynthesizer?
    
    override init() {
        super.init()
    }
    
    /*
    func playWhiteNoise() {
        prepareAudioSession()
        if let url = Bundle.main.url(forResource: "silence", withExtension: "m4a") {
            let audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = 1
            audioPlayer?.play()
        }
    }*/
    
    func speak(_ announcement: String, in language: String = "en-US") {
        DispatchQueue.main.async {
            self.prepareAudioSession()
            if let synthesizer = self.synthesizer, synthesizer.isSpeaking {
                return
            }
            let utterance = AVSpeechUtterance(string: announcement.lowercased())
            utterance.voice = AVSpeechSynthesisVoice(language: language)
            let newSynthesizer = AVSpeechSynthesizer()
            newSynthesizer.delegate = self
            newSynthesizer.speak(utterance)
            self.synthesizer = newSynthesizer
            //self.playWhiteNoise()
        }
    }
    
    private func prepareAudioSession() {
        try? session.setCategory(AVAudioSessionCategoryPlayback, with: .duckOthers)
        try? session.setActive(true)
    }

}

extension SpeechManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("speaking...\n\"\(utterance.speechString)\"")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("...done")
        if synthesizer == self.synthesizer {
            self.synthesizer = nil
            try? session.setActive(false, with: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation)
        }
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("paused")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("canceled")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("continued")
    }
}
