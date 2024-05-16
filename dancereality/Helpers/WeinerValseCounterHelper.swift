//
//  EnglishValseCounterHelper.swift
//  dancereality
//
//  Created by Saad Bin Khalid on 07.02.24.
//

import Foundation

public class WeinerValseMusicHelper {
    private var musicBeat : [[Double]] = []
    private var beatWithCounterData: [Timer] = []
    private var klausData : [[Double]] = []
    private var playFlag : Bool = false
    private var rate: Double = 1.0
    private var musicHelperOne: CounterMusic? = nil
    private var musicHelperTwo: CounterMusic? = nil
    private var musicHelperThree: CounterMusic? = nil
    private var musicHelperTwoAnd: CounterMusic? = nil
    
    public init(musicBeat: [[Double]], klausData: [[Double]] , rate: Double) {
        self.musicBeat = musicBeat
        self.klausData = klausData
        var beatValues : [[Double]] = []
        self.rate = (rate / 100)
        for beat in self.musicBeat {
            beatValues.append([beat[0] / (rate / 100), beat[1]])
        }
        self.musicBeat = beatValues
        self.musicHelperOne = CounterMusic()
        self.musicHelperTwo = CounterMusic()
        self.musicHelperThree = CounterMusic()
        self.musicHelperTwoAnd = CounterMusic()
        musicHelperOne?.initPlayerWithAudio(file: "WV_1", rate: self.rate)
        musicHelperTwo?.initPlayerWithAudio(file: "WV_2", rate: self.rate)
        musicHelperThree?.initPlayerWithAudio(file: "WV_3", rate: self.rate)
        musicHelperTwoAnd?.initPlayerWithAudio(file: "EV_2and", rate: self.rate)
    }
    
    public func isPlaying(status: Bool, time: TimeInterval){
        self.playFlag = status
        self.beatWithCounterData = []
        self.setupTimerWithCurrentTime(time: time, speed: 1.0)
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
                music = "WV_1"
                time = timeDilation + 0.0
                timeForNext = timeForNext + (0.333 / speed)
            } else if(beatNumber == 1.0){
                music = "WV_1"
                time = timeDilation + (timeForNext / self.rate)
                timeForNext = timeForNext + (0.333 / speed)
            }
            
            if(beatNumber == 2.0 && j == 0){
                music = "WV_2"
                time = timeDilation + (0.0)
                timeForNext = timeForNext + (0.333 / speed)
            } else if (beatNumber == 2.0) {
                music = "WV_2"
                time = timeDilation + (timeForNext / self.rate)
                timeForNext = timeForNext + (0.333 / speed)
            }
            
            if (beatNumber == 2.5) {
                music = "EV_2and"
                time = timeDilation + (timeForNext / self.rate)
                timeForNext = timeForNext + (0.333 / speed)
            }
            
            if (beatNumber == 3.0){
                music = "WV_3"
                time = timeDilation + (timeForNext / self.rate)
                timeForNext = timeForNext + (0.333 / speed)
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
            let beatNum = timerData["beatNumber"]! as! Double
            let file: String = timerData["musicFile"]! as! String
            if(file == "WV_1"){
                guard let counterMusic = self.musicHelperOne else {
                    return
                }
                counterMusic.play()
            } else if (file == "WV_2") {
                guard let counterMusic = self.musicHelperTwo else {
                    return
                }
                counterMusic.play()
            } else if (file == "WV_2and") {
                guard let counterMusic = self.musicHelperTwoAnd else {
                    return
                }
                counterMusic.play()
            } else if (file == "WV_3"){
                guard let counterMusic = self.musicHelperThree else {
                    return
                }
                counterMusic.play()
            }
            print(file+" time "+String(beatNum))
        
        
        self.beatWithCounterData.remove(at: 0)
    }
    
    public func isPlaying(status: Bool, time: TimeInterval, speedAdjustmentByAvatar: Double){
        self.playFlag = status
        self.beatWithCounterData = []
        self.setupTimerWithCurrentTime(time: time, speed: 1.0)
        if let musicHelper = self.musicHelperOne {
            musicHelper.setRate(rate: Float(speedAdjustmentByAvatar))
        }
        if let musicHelper = self.musicHelperTwo {
            musicHelper.setRate(rate: Float(speedAdjustmentByAvatar))
        }
        if let musicHelper = self.musicHelperThree {
            musicHelper.setRate(rate: Float(speedAdjustmentByAvatar))
        }
        if let musicHelper = self.musicHelperTwoAnd {
            musicHelper.setRate(rate: Float(speedAdjustmentByAvatar))
        }
    }
    
    public func stopAll(){
        guard let counterMusic = self.musicHelperThree else {
            return
        }
        counterMusic.stop()
        guard let counterMusic = self.musicHelperTwoAnd else {
            return
        }
        counterMusic.stop()
        guard let counterMusic = self.musicHelperTwo else {
            return
        }
        counterMusic.stop()
        guard let counterMusic = self.musicHelperOne else {
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
