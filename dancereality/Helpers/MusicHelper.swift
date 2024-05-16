//
//  MusicHelper.swift
//  dancerecord
//
//  Created by Saad Khalid on 01.04.22.
//

import AVFoundation
import UIKit

class MusicHelper {
    static let sharedHelper = MusicHelper()
    var audioPlayer: AVAudioPlayer?
    var audioPlayerNew: AVPlayer?

    /**
            This Method plays Music In Behind
     */
    func playBackgroundMusic(dance: String, slowDance: String?, rate: Double, vol: Float = 1.0) {
        let path = AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.DOWNLOAD_DIRECTORY)
        var musicURI = NSURL(fileURLWithPath: path.appendingPathComponent(dance).relativePath)
//        if(rate <= 0.7){
//            if(slowDance != nil){
//                musicURI = NSURL(fileURLWithPath: path.appendingPathComponent(slowDance!).relativePath)
//            }
//        }
        do {
            if(UIDevice.current.systemVersion > "16.0"){
                audioPlayer = try AVAudioPlayer(contentsOf:musicURI as URL)
                audioPlayer!.numberOfLoops = -1
                audioPlayer!.enableRate = true
                audioPlayer!.rate = Float(rate)
                audioPlayer!.prepareToPlay()
                audioPlayer!.volume = vol
                audioPlayer!.play()
            } else {
                audioPlayer = try AVAudioPlayer(contentsOf:musicURI as URL)
                audioPlayer!.numberOfLoops = -1
                audioPlayer!.enableRate = true
                audioPlayer!.rate = Float(rate)
                audioPlayer!.prepareToPlay()
                audioPlayer!.volume = vol
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
