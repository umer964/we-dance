//
//  SlowFoxCounterHelper.swift
//  dancereality
//
//  Created by Saad Bin Khalid on 07.02.24.
//

import Foundation

public class TangoCounterHelper {
    private var musicBeat : [[Double]] = []
    private var beatWithCounterData: [Timer] = []
    private var klausData : [[Double]] = []
    private var playFlag : Bool = false
    private var rate: Double = 1.0
    private var maxCounterForBeat = 4
    private var musicHelperQuick: CounterMusic? = nil
    private var musicHelperQuick2: CounterMusic? = nil
    private var musicHelperSlow: CounterMusic? = nil
    private var musicHelperQuickAnd: CounterMusic? = nil
    
    public init(musicBeat: [[Double]], klausData: [[Double]],rate: Double) {
        self.musicBeat = musicBeat
        self.klausData = klausData
        var beatValues : [[Double]] = []
        self.rate = (rate / 100)
        for beat in self.musicBeat {
            beatValues.append([beat[0] / (rate / 100), beat[1]])
        }
        self.musicBeat = beatValues
        musicHelperQuick = CounterMusic()
        musicHelperQuick2 = CounterMusic()
        musicHelperSlow = CounterMusic()
        musicHelperQuickAnd = CounterMusic()
        musicHelperQuick?.initPlayerWithAudio(file: "TG_2", rate: self.rate)
        musicHelperQuick2?.initPlayerWithAudio(file: "TG_2", rate: self.rate)
        musicHelperQuickAnd?.initPlayerWithAudio(file: "TG_2and", rate: self.rate)
        musicHelperSlow?.initPlayerWithAudio(file: "TG_1", rate: self.rate)
        
    }
    
    public func isPlaying(status: Bool, time: TimeInterval){
        self.playFlag = status
        self.beatWithCounterData = []
        self.setupTimerWithCurrentTime(time: time, speed: 1.0)
    }
    
    public func isPlaying(status: Bool, time: TimeInterval, speedAdjustmentByAvatar: Double){
        self.playFlag = status
        self.beatWithCounterData = []
        self.setupTimerWithCurrentTime(time: time, speed: 1.0)
        if let musicHelper = self.musicHelperSlow {
            musicHelper.setRate(rate: Float(speedAdjustmentByAvatar))
        }
        if let musicHelper = self.musicHelperQuick {
            musicHelper.setRate(rate: Float(speedAdjustmentByAvatar))
        }
        if let musicHelper = self.musicHelperQuick2 {
            musicHelper.setRate(rate: Float(speedAdjustmentByAvatar))
        }
        if let musicHelper = self.musicHelperQuickAnd {
            musicHelper.setRate(rate: Float(speedAdjustmentByAvatar))
        }
    }
    
    private func setupTimerWithCurrentTime(time: TimeInterval, speed: Double){
        var timeDilation = time
        var timeForNext = 0.0
        var j = 0
        for beat in self.klausData {
            let beatNumber = beat[0]
            var music = ""
            var time = timeDilation
            if(beatNumber == 1.0 && j == 0){
                music = "SF_1"
                time = timeDilation + 0.0
                timeForNext = timeForNext + ((0.933) / speed)
            } else if(beatNumber == 1.0){
                music = "SF_1"
                time = timeDilation + (timeForNext / self.rate)
                timeForNext = timeForNext + ((0.933) / speed)
            }
            
            if(beatNumber == 2.0 && j == 0){
                music = "SF_2"
                time = timeDilation + (0.0)
                // for eric its fine
                // for footsteps 3 frames more
                timeForNext = timeForNext + ((0.466) / speed)
            } else if (beatNumber == 2.0) {
                music = "SF_2"
                time = timeDilation + (timeForNext / self.rate)
                timeForNext = timeForNext + ((0.466) / speed)
            }
            
            if (beatNumber == 2.5) {
                music = "SF_2and"
                time = timeDilation + (timeForNext / self.rate)
                timeForNext = timeForNext + ((0.466) / speed)
            }
            
            if (beatNumber == 3.0){
                music = "SF_3"
                time = timeDilation + (timeForNext / self.rate)
                timeForNext = timeForNext + ((0.466) / speed)
            }
            
            let finalTimeForBeat = time
            let t = Timer.scheduledTimer(timeInterval: (finalTimeForBeat),
                                                target: self,
                                                selector: #selector(self.timerCall),
                                                userInfo: ["beatNumber": finalTimeForBeat,
                                                           "musicFile" : music
                                                       ] as [String : Any],
                                                repeats: false)
            self.beatWithCounterData.append(t)
            
            j = j + 1
        }
    }
    
    @objc func timerCall(sender: Timer){
            let timerData = sender.userInfo as! [String : Any]
            let file: String = timerData["musicFile"]! as! String
            let number: Double = timerData["beatNumber"]! as! Double
            if(file == "SF_1"){
                guard let slowMusic = self.musicHelperSlow else {
                    return
                }
                slowMusic.stop()
                slowMusic.play()
            } else if (file == "SF_2") {
                guard let quickMusic = self.musicHelperQuick else {
                    return
                }
                quickMusic.stop()
                quickMusic.play()
            } else if (file == "SF_2and") {
                guard let quickMusic = self.musicHelperQuickAnd else {
                    return
                }
                quickMusic.stop()
                quickMusic.play()
            } else if (file == "SF_3"){
                guard let quickMusic = self.musicHelperQuick2 else {
                    return
                }
                quickMusic.stop()
                quickMusic.play()
            }
            print(number)
        
        
        self.beatWithCounterData.remove(at: 0)
    }
    
    public func stopAll(){
        guard let counterMusic = self.musicHelperSlow else {
            return
        }
        counterMusic.stop()
        guard let counterMusic = self.musicHelperQuick else {
            return
        }
        counterMusic.stop()
        guard let counterMusic = self.musicHelperQuick2 else {
            return
        }
        counterMusic.stop()
        guard let counterMusic = self.musicHelperQuickAnd else {
            return
        }
        counterMusic.stop()
    }
    
    public func invalidateAllTimer(){
        self.playFlag = false
        for timer in self.beatWithCounterData{
            timer.invalidate()
        }
    }
}
