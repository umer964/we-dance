//
//  EnglishValseCounterMusic.swift
//  dancereality
//
//  Created by Saad Bin Khalid on 07.02.24.
//

import Foundation
import Foundation
import UIKit
import AVFAudio
import AVFoundation

public class CounterMusic {
    static let sharedHelper = CounterMusic()
    var audioPlayer: AVAudioPlayer?
    var audioPlayerNew: AVPlayer?

    /**
            This Method plays Music In Behind
     */
    public func initPlayerWithAudio(file: String, rate: Double){
        stop()
        guard let path = Bundle.main.path(forResource: file, ofType: "mp3") else {
               return
        }
        var loop = 0
        if(file.contains("SF")){
            loop = 0
        }
        
        let musicURI = URL(fileURLWithPath: path)
        do {
            if(UIDevice.current.systemVersion > "16.0"){
                audioPlayer = try AVAudioPlayer(contentsOf:musicURI as URL)
                audioPlayer!.enableRate = true
                audioPlayer!.rate = Float(rate)
                audioPlayer!.prepareToPlay()
                audioPlayer!.volume = 2.0
            } else {
                audioPlayer = try AVAudioPlayer(contentsOf:musicURI as URL)
                audioPlayer!.enableRate = true
                audioPlayer!.rate = Float(rate)
                audioPlayer!.prepareToPlay()
                audioPlayer!.volume = 2.0
            }
           
        } catch {
            print(AppModel.MUSIC_FILE_COULD_NOT_BE_PLAYED)
        }
    }
    
    func playCounterMusic(rate: Double, vol: Float = 1.0, counter: String) {
        stop()
        guard let path = Bundle.main.path(forResource: counter, ofType: "mp3") else {
               return
        }

        let musicURI = URL(fileURLWithPath: path)
        do {
            if(UIDevice.current.systemVersion > "16.0"){
                audioPlayer = try AVAudioPlayer(contentsOf:musicURI as URL)
                audioPlayer!.enableRate = true
                audioPlayer!.rate = Float(rate)
                audioPlayer!.prepareToPlay()
                audioPlayer!.volume = 2.0
                audioPlayer!.play()
            } else {
                audioPlayer = try AVAudioPlayer(contentsOf:musicURI as URL)
                audioPlayer!.numberOfLoops = 1
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
    
    func getRate() -> Double {
        if let player = audioPlayer {
            return Double(player.rate)
        }
        if let playerNew = audioPlayerNew {
            return Double(playerNew.rate)
        }
        return 1
    }
    
    func play() {
        if let player = audioPlayer{
            player.prepareToPlay()
            player.play()
            print("play")
        }
        if let playerNew = audioPlayerNew {
            playerNew.play()
            print("play")
        }
    }
    
    func stop() {
        if let player = audioPlayer{
            player.pause()
            player.currentTime = 0
        }
        if let playerNew = audioPlayerNew {
            playerNew.pause()
        }
    }
}
