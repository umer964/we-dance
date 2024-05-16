//
//  CounterMusicHelper.swift
//  dancereality
//
//  Created by Saad Bin Khalid on 22.01.24.
//

import Foundation
import UIKit
import AVFAudio
import AVFoundation

public class CounterMusicHelper {
    static let sharedHelper = CounterMusicHelper()
    var audioPlayer: AVAudioPlayer?
    var audioPlayerNew: AVPlayer?

    /**
            This Method plays Music In Behind
     */
    func playCounterMusic(rate: Double, vol: Float = 1.0) {
        guard let path = Bundle.main.path(forResource: "EV3", ofType: "mp3") else {
               return
        }

        let musicURI = URL(fileURLWithPath: path)
        do {
            if(UIDevice.current.systemVersion > "16.0"){
                audioPlayer = try AVAudioPlayer(contentsOf:musicURI as URL)
                audioPlayer!.numberOfLoops = -1
                audioPlayer!.enableRate = true
                audioPlayer!.rate = Float(rate)
                audioPlayer!.prepareToPlay()
                audioPlayer!.volume = 2.0
                audioPlayer!.play()
            } else {
                audioPlayer = try AVAudioPlayer(contentsOf:musicURI as URL)
                audioPlayer!.numberOfLoops = -1
                audioPlayer!.enableRate = true
                audioPlayer!.rate = Float(rate)
                audioPlayer!.prepareToPlay()
                audioPlayer!.volume = 2.0
                audioPlayer!.play()
            }
           
        } catch {
            print(AppModel.MUSIC_FILE_COULD_NOT_BE_PLAYED)
        }
    }
    
    func setRate(rate: Float){
        if let player = audioPlayer {
            player.rate = rate
        }
        if let playerNew = audioPlayerNew {
            playerNew.rate = rate
        }
    }
    
    func stop() {
        if let player = audioPlayer{
            player.pause()
        }
        if let playerNew = audioPlayerNew {
            playerNew.pause()
        }
    }
}
