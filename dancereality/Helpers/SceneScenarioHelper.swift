//
//  SceneScenarioHelper.swift
//  dancereality
//
//  Created by Saad Khalid on 05.07.22.
//

import Foundation
import Lottie
import SceneKit
import AVKit
import Accelerate


class SceneScenarioHelper {
    
    private var animationView : AnimationView?
    private var modelData : CustomScnNode
    private var animationSubMovesByFrames : [[Double]]
    private var animationSubMovesByFramesFixedByBar : [[Double]]
    private var avatarAnimationData: [[Double]]
    private var videoData: [[Double]]
    private let tangoBeatCount = 4.0
    private let englishValesBeatCount = 3.0
    private let slowFoxBeatCount = 3.0
    private let slowFoxBeatSecondCount = 4.0
    private let wienerValseBeatCount = 3.0
    private let wienerValseBeatSecondCount = 4.0
    private let quickStepBeatCount = 4.0
    private let quickStepBeatSecondCount = 2.0
    private var speedRate: Double = 100.00
    private var dance: DanceTypeModel?
    private var danceMove: DanceMoveModel?
    private var danceSubMove: SubDance?
    private var music: MusicModel?
    private var danceNameFound: String = ""
    public var animationKeyString: String = ""
    private let dataSource: StoreageHelper = StoreageHelper()
    private var fromMode: String = "Default"
    
    public func setMode(mode: String){
        self.fromMode = mode
    }
    
    init(danceName: Int, moveName: String, subHash: String) {
        modelData = CustomScnNode()
        animationSubMovesByFrames = []
        animationSubMovesByFramesFixedByBar = []
        avatarAnimationData = []
        videoData = []
        dance = dataSource.getDanceTypeById(id: danceName)
        danceSubMove = dataSource.getDanceSubByHash(id: danceName, hash: subHash)
        danceMove = dataSource.getDanceByHash(hash: moveName)
        if let dance = dance,
           let danceMove = danceMove {
            danceNameFound = dance.name
            animationSubMovesByFrames = danceMove.footStepAnimation.steps
            if(dance.musics.count > 0) {
                let musicModel: MusicModel = dance.musics.first!
                self.music = musicModel
                animationSubMovesByFramesFixedByBar = getAnimationSubMovesWithBeatByBar(beatValues: musicModel.beats!,
                                                                                        stepsInfo: animationSubMovesByFrames,
                                                                                        speedRate: speedRate)
                avatarAnimationData = getAvatarAnimationByBeatDefault(speedRate: speedRate)
                let videoPath = danceMove.video.filename
                videoData = getVideoWithBeat(beatValues: musicModel.beats!,
                                             stepsInfo: getVideoFrames(videoPathName: videoPath,
                                                                       danceName: danceMove.name),
                                             speedRate: speedRate)
                
            }
            
            loadAnimationFromFile(fileName: danceMove.footStepAnimation.name,
                                  avatarFileName: danceMove.characterModel.pathFileName)
        }
    }
    
    public func getFootStepsAnimationsFrames() -> [[Double]]{
        var durationPerStep: [[Double]] = []
       // if let danceMove = self.danceMove?.footStepAnimation{
        if let danceMove = self.danceMove{
            //animationSubMovesByFrames.forEach{instances in
               // durationPerStep.append([instances[0], instances[1]])
            //}
//            if(danceMove.name == "2 steps"){
//                durationPerStep.append([0.0, 56.0])
//                durationPerStep.append([56.0, 112.0])
//            }
//            if(danceMove.name == "Chasse"){
//                durationPerStep.append([0.0, 20.0])
//                durationPerStep.append([20.0, 30.0])
//                durationPerStep.append([30.0, 40.0])
//                durationPerStep.append([40.0, 60.0])
//            }
//            if(danceMove.name == "1-6 natural turn"){
//                durationPerStep.append([0.0, 20.0])
//                durationPerStep.append([20.0, 40.0])
//                durationPerStep.append([40.0, 60.0])
//                durationPerStep.append([60.0, 80.0])
//                durationPerStep.append([80.0, 100.0])
//                durationPerStep.append([100.0, 120.0])
//            }
//            if(danceMove.name == "1-3 Natural Turn BW"){
//                durationPerStep.append([0.0, 20.0])
//                durationPerStep.append([20.0, 40.0])
//                durationPerStep.append([40.0, 60.0])
//            }
           if(danceMove.name == "2 steps"){
                durationPerStep.append([0.0, 28.0])
                durationPerStep.append([28.0, 84.0])
                durationPerStep.append([84.0, 112.0])
            }
            if(danceMove.name == "Chasse"){
                durationPerStep.append([0.0, 10.0])
                durationPerStep.append([10.0, 30.0])
                durationPerStep.append([30.0, 40.0])
                durationPerStep.append([40.0, 50.0])
                durationPerStep.append([50.0, 60.0])
            }
            if(danceMove.name == "1-6 natural turn"){
                durationPerStep.append([0.0, 10.0])
                durationPerStep.append([10.0, 30.0])
                durationPerStep.append([30.0, 50.0])
                durationPerStep.append([50.0, 70.0])
                durationPerStep.append([70.0, 90.0])
                durationPerStep.append([90.0, 110.0])
                durationPerStep.append([110.0, 120.0])
            }
            if(danceMove.name == "1-3 Natural Turn BW"){
                durationPerStep.append([0.0, 10.0])
                durationPerStep.append([10.0, 30.0])
                durationPerStep.append([30.0, 50.0])
                durationPerStep.append([50.0, 60.0])
           }
        }
        print(durationPerStep)
        return durationPerStep
    }
    
    private func getVideoFrames(videoPathName: String, danceName: String) -> Double{
        var frames: Double = 0.0
        let path = AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.DOWNLOAD_DIRECTORY)
        let videoPath = path.appendingPathComponent((danceMove?.video.filename)!)
        let player = AVPlayer(url: videoPath)
        guard let duration = player.currentItem?.asset.duration.seconds else {
            return frames
        }
        guard let frameRate = player.currentItem?.asset.tracks.first?.nominalFrameRate else {
            return frames
        }
        
        frames = Double(duration) * Double(frameRate)
        return frames
    }
    
    public func getVideoData() -> [[Double]] {
        return videoData
    }
    
    public func resetMusic(id: Int){
        if let dance = self.dance{
            if(dance.musics.count > 0){
                let findMusic: MusicModel? = dance.musics.first { model in
                    model.id == id
                } ?? dance.musics.first
                if let selectedMusic = findMusic {
                    self.music = selectedMusic
                    animationSubMovesByFramesFixedByBar = getAnimationSubMovesWithBeatByBar(beatValues: selectedMusic.beats!,
                                                                                            stepsInfo: animationSubMovesByFrames,
                                                                                            speedRate: speedRate)
                    avatarAnimationData = getAvatarAnimationByBeatDefault(speedRate: speedRate)
                }
            }
        }
    }
    
    public func getMusic() -> MusicModel? {
        return music ?? nil
    }
    
    public func getAnimationStartTime(speedRate: Double) -> Double {
        guard let dance = self.dance else {
            return 0.0
        }
        
        if(dance.musics.count > 0) {
            var skipOffset = 2
            guard let musicModel: MusicModel = self.music else {
                return 0.0
            }
            var beatVals: [[Double]] = []
            if let beats = musicModel.beats{
                for beat in beats {
                    beatVals.append([beat[0] / (speedRate / 100), beat[1]])
                }
            }
            var beatTimeToReturn: Double = 0.0
            for i in 0...beatVals.count - 1 {
                if (skipOffset >= 1){
                    if(beatVals[i][1] == englishValesBeatCount && danceNameFound == AppModel.ENGLISH_VALSE){
                        skipOffset = skipOffset - 1
                        beatTimeToReturn = beatVals[i][0] + (beatVals[i][0] / 2)
                    } else if (beatVals[i][1] == tangoBeatCount && danceNameFound == AppModel.TANGE) {
                        skipOffset = skipOffset - 1
                        beatTimeToReturn = beatVals[i][0]
                    } else if (beatVals[i][1] == quickStepBeatCount && danceNameFound == AppModel.QUICKSTEP) {
                        skipOffset = skipOffset - 1
                        beatTimeToReturn = beatVals[i][0] + (beatVals[i][0] / 2)
                    } else if (beatVals[i][1] == wienerValseBeatCount && danceNameFound == AppModel.WIENER_VALSE) {
                        skipOffset = skipOffset - 1
                        beatTimeToReturn = beatVals[i][0] + (beatVals[i][0] / 2)
                    } else if (beatVals[i][1] == slowFoxBeatCount && danceNameFound == AppModel.SLOWFOX) {
                        skipOffset = skipOffset - 1
                        beatTimeToReturn = beatVals[i][0] + (beatVals[i][0] / 2)
                    }
                    continue
                } else {
                    return beatTimeToReturn
                }
            }
        }
        
        return 0.0
    }
    
    private func checkBarCount(beatVals: Double) -> Bool{
        return ((beatVals == englishValesBeatCount && danceNameFound == AppModel.ENGLISH_VALSE) ||
                (beatVals == quickStepBeatCount && danceNameFound == AppModel.ENGLISH_VALSE)
        )
    }
    public func getDanceTypeDetails() -> DanceTypeModel {
        return dance!
    }
    
    public func getDanceSubDetailts() -> DanceMoveModel {
        return danceMove!
    }
    
    public func getDanceSubChildDetailts() -> SubDance {
        return danceSubMove!
    }
    
    // Load Avataar Animation Data from Path
    private func loadAnimationFromFile (fileName: String, avatarFileName: String){
        do {
            let url = AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.DOWNLOAD_DIRECTORY+"/"+fileName)
            let urlForModel = AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.DOWNLOAD_DIRECTORY+"/"+avatarFileName).absoluteURL
            
            self.animationView = .init(filePath: url.relativePath)
            let idleScene = try SCNScene.init(url: urlForModel)
            let mainCharacter : CustomScnNode? = CustomScnNode()
            for node in idleScene.rootNode.childNodes {
                mainCharacter!.addChildNode(node)
                if(!node.animationKeys.isEmpty){
                    self.animationKeyString = node.animationKeys[0]
                }
                print(node.animationKeys)
            }
            modelData = mainCharacter!
        } catch let error as NSError{
            print(error)
        }
    }
    
    public func getFootAnimation () -> AnimationView {
        return animationView!
    }
    
    public func getAnimationSubMovesData () -> [[Double]]{
        return animationSubMovesByFramesFixedByBar
    }
    
    public func getModelData () -> CustomScnNode {
        modelData.prepareForAnimation()
        return modelData
    }
    
    public func getModelFile() -> CustomScnNode {
        do {
            guard let danceMove = danceMove else {
                return CustomScnNode()
            }
            let urlForModel = AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.DOWNLOAD_DIRECTORY+"/"+danceMove.characterModel.pathFileName).absoluteURL
            let idleScene = try SCNScene.init(url: urlForModel)
            let mainCharacter : CustomScnNode = CustomScnNode()
            for node in idleScene.rootNode.childNodes {
                mainCharacter.addChildNode(node)
                if(!node.animationKeys.isEmpty){
                    self.animationKeyString = node.animationKeys[0]
                }
                print(node.animationKeys)
            }
            modelData = mainCharacter
            modelData.prepareForAnimation()
        } catch let error as NSError{
            print(error)
        }
        return modelData
    }
    
    private func getTotalFramesOfFootSteps(stepInfo: [[Double]]) -> Double {
        for i in 0...stepInfo.count - 1 {
            if(i == stepInfo.count - 1){
                return stepInfo[i][1]
            }
        }
        return 0.0
    }
    
    // Avataar Beat Counter for Initialization
    private func getAvatarAnimationWithBeat (beatValues: [[Double]]) -> [Double] {
        var animationStartingPoints : [Double] = []
        var skipOffset = 2
        var barCount = 0
        
        guard let barInfo = danceMove?.barCount else {
            return animationStartingPoints
        }
        
        guard let danceMove = self.danceMove else {
            return animationStartingPoints
        }
        
        for i in 0...beatValues.count - 1 {
            if (skipOffset >= 1){
                if(beatValues[i][1] == englishValesBeatCount && danceNameFound == AppModel.ENGLISH_VALSE){
                    skipOffset = skipOffset - 1
                } else if (beatValues[i][1] == tangoBeatCount && danceNameFound == AppModel.TANGE) {
                    skipOffset = skipOffset - 1
                }
                else if ((beatValues[i][1] == quickStepBeatCount || beatValues[i][1] == quickStepBeatSecondCount) && danceNameFound == AppModel.QUICKSTEP) {
                    skipOffset = skipOffset - 1
                } else if ((beatValues[i][1] == wienerValseBeatCount || beatValues[i][1] == wienerValseBeatSecondCount) && danceNameFound == AppModel.WIENER_VALSE) {
                    skipOffset = skipOffset - 1
                } else if ((beatValues[i][1] == slowFoxBeatCount || beatValues[i][1] == slowFoxBeatSecondCount) && danceNameFound == AppModel.SLOWFOX) {
                    skipOffset = skipOffset - 1
                }
                continue
            } else {
                if(beatValues[i][1] == englishValesBeatCount && danceNameFound == AppModel.ENGLISH_VALSE){
                    barCount = barCount + 1
                    if(barCount == barInfo) {
                        animationStartingPoints.append(beatValues[i][0] - danceMove.characterModel.smoothing)
                        barCount = 0
                    }
                } else if (beatValues[i][1] == tangoBeatCount && danceNameFound == AppModel.TANGE) {
                    barCount = barCount + 1
                    if(barCount == barInfo) {
                        animationStartingPoints.append(beatValues[i][0] - danceMove.characterModel.smoothing)
                        barCount = 0
                    }
                } else if (beatValues[i][1] == quickStepBeatCount && danceNameFound == AppModel.QUICKSTEP) {
                    barCount = barCount + 1
                    if(barCount == barInfo) {
                        animationStartingPoints.append(beatValues[i][0] - danceMove.characterModel.smoothing)
                        barCount = 0
                    }
                } else if (beatValues[i][1] == wienerValseBeatCount && danceNameFound == AppModel.WIENER_VALSE) {
                    barCount = barCount + 1
                    if(barCount == barInfo) {
                        animationStartingPoints.append(beatValues[i][0] - danceMove.characterModel.smoothing)
                        barCount = 0
                    }
                } else if (beatValues[i][1] == slowFoxBeatCount && danceNameFound == AppModel.SLOWFOX) {
                    barCount = barCount + 1
                    if(barCount == barInfo) {
                        animationStartingPoints.append(beatValues[i][0] - danceMove.characterModel.smoothing)
                        barCount = 0
                    }
                }
            }
        }
        
        return animationStartingPoints
    }
    
    // Avataar Animation Data with respect to beat
    public func getAvatarAnimationByBeatDefault(speedRate: Double) -> [[Double]] {
        var adjustBeatValuesWithBar : [[Double]] = []
        var skipOffset = 2
        var barCounts = 0.0
        var startPos = 0.0
        var endPos = 0.0
        var beatValues: [[Double]] = []
        guard let barInfo = danceMove?.barCount else {
            return adjustBeatValuesWithBar
        }
        
        guard let danceMove = danceMove else {
            return adjustBeatValuesWithBar
        }
        
        guard let music = self.music else {
            return adjustBeatValuesWithBar
        }
        
        guard let beats = music.beats else {
            return adjustBeatValuesWithBar
        }
        
        for beat in beats {
            beatValues.append([beat[0] / (speedRate / 100), beat[1]])
        }
        
        var barCount = 0
        let beatInitial = 1.0
        var animationDuration = 0.0
        let totalFrames = danceMove.characterModel.frames
        let frameRate = danceMove.characterModel.frameRate
        let duration = Double(totalFrames) / Double(frameRate)
        self.speedRate = speedRate
        
        for i in 0...beatValues.count - 1 {
            if (skipOffset >= 1){
                if(beatValues[i][1] == beatInitial){
                    skipOffset = skipOffset - 1
                }
                continue
            } else {
                var differenceStartEnd = beatValues[i][0] - startPos
                if(danceNameFound == AppModel.ENGLISH_VALSE){
                    if(i+1 < beatValues.count){
                        if(differenceStartEnd >= duration && startPos != 0.0){
                            endPos = (beatValues[i+1][0] + beatValues[i][0]) / 2
                        }
                    }
                } else if (danceNameFound == AppModel.TANGE) {
                    if(differenceStartEnd >= duration && startPos != 0.0){
                        endPos = beatValues[i][0]
                    }
                } else if (danceNameFound == AppModel.QUICKSTEP) {
                    if(i+1 < beatValues.count){
                        differenceStartEnd = ((beatValues[i+1][0] + beatValues[i][0]) / 2) - startPos
                        if(differenceStartEnd >= duration && startPos != 0.0){
                            endPos = (beatValues[i+1][0] + beatValues[i][0]) / 2
                        }
                    }
                } else if (danceNameFound == AppModel.WIENER_VALSE) {
                    if(i+1 < beatValues.count){
                        differenceStartEnd = ((beatValues[i+1][0] + beatValues[i][0]) / 2) - startPos
                        if(differenceStartEnd >= duration && startPos != 0.0){
                            endPos = (beatValues[i+1][0] + beatValues[i][0]) / 2
                        }
                    }
                } else if (danceNameFound == AppModel.SLOWFOX) {
                    if(i+1 < beatValues.count){
                        differenceStartEnd = ((beatValues[i+1][0] + beatValues[i][0]) / 2) - startPos
                        if(differenceStartEnd >= duration && startPos != 0.0){
                            endPos = (beatValues[i+1][0] + beatValues[i][0]) / 2
                        }
                    }
                }
                if(beatValues[i][1] == 1.0 && startPos == 0.0 && animationDuration <= 0.0){
                    if(danceNameFound == AppModel.ENGLISH_VALSE){
                        startPos = (beatValues[i][0] + beatValues[i-1][0]) / 2
                    } else if(danceNameFound == AppModel.QUICKSTEP){
                        startPos = (beatValues[i][0] + beatValues[i-1][0]) / 2
                    } else if(danceNameFound == AppModel.SLOWFOX){
                        startPos = (beatValues[i][0] + beatValues[i-1][0]) / 2
                    } else if(danceNameFound == AppModel.WIENER_VALSE){
                        startPos = (beatValues[i][0] + beatValues[i-1][0]) / 2
                    } else {
                        startPos = beatValues[i-1][0]
                    }
                }
                if(startPos != 0.0 && endPos != 0.0){
                    barCounts = barCounts + 1
//                    let totalFrames = CGFloat(danceMove.characterModel.frames) + AppModel.AVATAR_INITIAL_FRAMES
//                    let frameRate = danceMove.characterModel.frameRate
//                    let durationFromTruth = (CGFloat(danceMove.characterModel.frames) + frameRate) / (speedRate / 100)
//                    let smothingFactorAdjusted:Double = Double(AppModel.AVATAR_INITIAL_FRAMES / AppModel.AVATAR_FRAME_RATE)
//                    let framesByFrameRate = totalFrames / frameRate / (speedRate / 100)
//                    let adjustedEstimateTime: Double = (framesByFrameRate) + smothingFactorAdjusted / (speedRate / 100)
//                    var duration = (framesByFrameRate / adjustedEstimateTime) * (speedRate / 100)
                    let frameRate = danceMove.characterModel.frameRate
                    let totalFrames = CGFloat(danceMove.characterModel.frames) + AppModel.AVATAR_INITIAL_FRAMES
                    var duration = (totalFrames / frameRate) / (speedRate / 100)
                    let smothingFactorAdjusted = AppModel.AVATAR_INITIAL_FRAMES / frameRate / (speedRate / 100)
                    var speedByDefault = 1.0
                    if(danceMove.characterModel.smoothing != 0.001){
                        duration = danceMove.characterModel.smoothing * (speedRate / 100)
                    }
                    
                    if(self.fromMode == "Default"){
                        if(danceMove.characterModel.speed != 0.0){
                            speedByDefault = danceMove.characterModel.speed
                            duration = duration / speedByDefault
                        }
                    } else {
                        if(danceMove.characterModel.speed != 0.0){
                            speedByDefault = speedRate / 100
                            duration = duration / speedByDefault
                        }
                    }
                    
                    // 3 duration and 7 speed
                    let startPosAdjusted = startPos - smothingFactorAdjusted
                    adjustBeatValuesWithBar.append([startPosAdjusted,
                                                    endPos,
                                                    totalFrames,
                                                    duration,
                                                    (endPos - startPos) + smothingFactorAdjusted,
                                                    barCounts,
                                                    smothingFactorAdjusted,
                                                    (speedByDefault) * (speedRate / 100)])
                    startPos = 0.0
                    endPos = 0.0
                }
            }
        }
        
        
        return adjustBeatValuesWithBar
    }
    
    public func getAvatarData() -> [[Double]]{
        return avatarAnimationData
    }
    
    // Get video speed with beat
    private func getVideoWithBeat(beatValues : [[Double]], stepsInfo: Double, speedRate: Double) -> [[Double]]{
        var adjustBeatValuesWithBar : [[Double]] = []
        var skipOffset = 2
        var barCounts = 0.0
        var startPos = 0.0
        var endPos = 0.0
        guard let danceMove = danceMove else {
            return adjustBeatValuesWithBar
        }
        let barInfo = danceMove.barCount
        var barCount = 0
        let beatInitial = 1.0
        var animationDuration = 0.0
        let totalFrames = stepsInfo
        let frameRate = danceMove.footStepAnimation.frames
        let duration = totalFrames / Double(frameRate)
        self.speedRate = speedRate
        
        for i in 0...beatValues.count - 1 {
            if (skipOffset >= 1){
                if(beatValues[i][1] == beatInitial){
                    skipOffset = skipOffset - 1
                }
                continue
            } else {
                var differenceStartEnd = beatValues[i][0] - startPos
                if(danceNameFound == AppModel.ENGLISH_VALSE){
                    if(i+1 < beatValues.count){
                        if(differenceStartEnd >= duration && startPos != 0.0){
                            endPos = (beatValues[i+1][0] + beatValues[i][0]) / 2
                        }
                    }
                } else if (danceNameFound == AppModel.TANGE) {
                    if(differenceStartEnd >= duration && startPos != 0.0){
                        endPos = beatValues[i][0]
                    }
                } else if (danceNameFound == AppModel.QUICKSTEP) {
                    if(i+1 < beatValues.count){
                        differenceStartEnd = ((beatValues[i+1][0] + beatValues[i][0]) / 2) - startPos
                        if(differenceStartEnd >= duration && startPos != 0.0){
                            endPos = (beatValues[i+1][0] + beatValues[i][0]) / 2
                        }
                    }
                } else if (danceNameFound == AppModel.WIENER_VALSE) {
                    if(i+1 < beatValues.count){
                        differenceStartEnd = ((beatValues[i+1][0] + beatValues[i][0]) / 2) - startPos
                        if(differenceStartEnd >= duration && startPos != 0.0){
                            endPos = (beatValues[i+1][0] + beatValues[i][0]) / 2
                        }
                    }
                } else if (danceNameFound == AppModel.SLOWFOX) {
                    if(i+1 < beatValues.count){
                        differenceStartEnd = ((beatValues[i+1][0] + beatValues[i][0]) / 2) - startPos
                        if(differenceStartEnd >= duration && startPos != 0.0){
                            endPos = (beatValues[i+1][0] + beatValues[i][0]) / 2
                        }
                    }
                }
                if(beatValues[i][1] == 1.0 && startPos == 0.0 && animationDuration <= 0.0){
                    if(danceNameFound == AppModel.ENGLISH_VALSE){
                        startPos = (beatValues[i][0] + beatValues[i-1][0]) / 2
                    } else if(danceNameFound == AppModel.QUICKSTEP){
                        startPos = (beatValues[i][0] + beatValues[i-1][0]) / 2
                    } else if(danceNameFound == AppModel.SLOWFOX){
                        startPos = (beatValues[i][0] + beatValues[i-1][0]) / 2
                    } else if(danceNameFound == AppModel.WIENER_VALSE){
                        startPos = (beatValues[i][0] + beatValues[i-1][0]) / 2
                    } else {
                        startPos = beatValues[i-1][0]
                    }
                }
                if(startPos != 0.0 && endPos != 0.0){
                    barCounts = barCounts + 1
                    let totalFrames = stepsInfo
                    let frameRate = 60.0
                    let framesByFrameRate = totalFrames / CGFloat(frameRate) / (speedRate / 100)
                    var duration = (framesByFrameRate / (endPos - startPos)) * (speedRate / 100)
                    if(danceMove.video.speed != 1.0){
                        duration = danceMove.video.speed * (speedRate / 100)
                    }
//                    switch(danceMove.name){
//                    case "2 Walk BW":
//                        duration = 1.011 * (speedRate / 100)
//                        break;
//                    case "One Walk With Rock Turn Fw Leader",
//                        "One Walk With Rock Turn Fw Follower":
//                        duration = 1.054 * (speedRate / 100)
//                        break;
//                    case "2 steps":
//                        duration = 1.001 * (speedRate / 100)
//                        break;
//                    case "tango choregraphy",
//                        "Tango Choregraphy Follower":
//                        duration = 1.125 * (speedRate / 100)
//                        break;
//                    case "1-3 Natural Turn BW",
//                        "1-3 Natural Turn FW":
//                        duration = 1.32 * (speedRate / 100)
//                        break;
//                    case "Chasse",
//                        "Chasse BW":
//                        duration = 1.274 * (speedRate / 100)
//                        break;
//                    case "1-6 natural turn",
//                        "1-6 Natural Turn",
//                        "LW Running Finish BW",
//                        "LW Running Finish",
//                        "Quarter Turn To Right Leader BW",
//                        "Quarter Turn To Right Leader FW",
//                        "1-6 Natural Turn Backward",
//                        "1-6 Natural Turn Leader",
//                        "Reverse Turn Backward",
//                        "Reverse Turn":
//                        duration = 1.203 * (speedRate / 100)
//                        break;
//                    default:
//                        break;
//                    }
                    adjustBeatValuesWithBar.append([startPos, endPos, totalFrames, duration, barCounts])
                    startPos = 0.0
                    endPos = 0.0
                }
            }
        }
        
        return adjustBeatValuesWithBar
    }
    
    // Get FootStep Data with Respect to Beat
    private func getAnimationSubMovesWithBeatByBar (beatValues : [[Double]], stepsInfo: [[Double]], speedRate: Double) -> [[Double]] {
        var adjustBeatValuesWithBar : [[Double]] = []
        var skipOffset = 2
        var barCounts = 0.0
        var startPos = 0.0
        var endPos = 0.0
        guard let danceMove = danceMove else {
            return adjustBeatValuesWithBar
        }
        let barInfo = danceMove.barCount
        var barCount = 0
        let beatInitial = 1.0
        var animationDuration = 0.0
        let totalFrames = getTotalFramesOfFootSteps(stepInfo: stepsInfo)
        var frameRate = danceMove.footStepAnimation.frames
        let duration = totalFrames / Double(frameRate)
        self.speedRate = speedRate
        do{
            for i in 0...beatValues.count - 1 {
                if (skipOffset >= 1){
                    if(beatValues[i][1] == beatInitial){
                        skipOffset = skipOffset - 1
                    }
                    continue
                } else {
                    var differenceStartEnd = beatValues[i][0] - startPos
                    if(danceNameFound == AppModel.ENGLISH_VALSE){
                        if(i+1 < beatValues.count){
                            if(differenceStartEnd >= duration && startPos != 0.0){
                                endPos = (beatValues[i+1][0] + beatValues[i][0]) / 2
                            }
                        }
                    } else if (danceNameFound == AppModel.TANGE) {
                        if(differenceStartEnd >= duration && startPos != 0.0){
                            endPos = beatValues[i][0]
                        }
                    } else if (danceNameFound == AppModel.QUICKSTEP) {
                        if(i+1 < beatValues.count){
                            differenceStartEnd = ((beatValues[i+1][0] + beatValues[i][0]) / 2) - startPos
                            if(differenceStartEnd >= duration && startPos != 0.0){
                                endPos = (beatValues[i+1][0] + beatValues[i][0]) / 2
                            }
                        }
                    } else if (danceNameFound == AppModel.WIENER_VALSE) {
                        if(i+1 < beatValues.count){
                            differenceStartEnd = ((beatValues[i+1][0] + beatValues[i][0]) / 2) - startPos
                            if(differenceStartEnd >= duration && startPos != 0.0){
                                endPos = (beatValues[i+1][0] + beatValues[i][0]) / 2
                            }
                        }
                    } else if (danceNameFound == AppModel.SLOWFOX) {
                        if(i+1 < beatValues.count){
                            differenceStartEnd = ((beatValues[i+1][0] + beatValues[i][0]) / 2) - startPos
                            if(differenceStartEnd >= duration && startPos != 0.0){
                                endPos = (beatValues[i+1][0] + beatValues[i][0]) / 2
                            }
                        }
                    }
                    if(beatValues[i][1] == 1.0 && startPos == 0.0 && animationDuration <= 0.0){
                        if(danceNameFound == AppModel.ENGLISH_VALSE){
                            startPos = (beatValues[i][0] + beatValues[i-1][0]) / 2
                        } else if(danceNameFound == AppModel.QUICKSTEP){
                            startPos = (beatValues[i][0] + beatValues[i-1][0]) / 2
                        } else if(danceNameFound == AppModel.SLOWFOX){
                            startPos = (beatValues[i][0] + beatValues[i-1][0]) / 2
                        } else if(danceNameFound == AppModel.WIENER_VALSE){
                            startPos = (beatValues[i][0] + beatValues[i-1][0]) / 2
                        } else {
                            startPos = beatValues[i-1][0]
                        }
                    }
                    if(startPos != 0.0 && endPos != 0.0){
                        barCounts = barCounts + 1
                        let totalFrames = getTotalFramesOfFootSteps(stepInfo: stepsInfo)
                        let frameRate = danceMove.footStepAnimation.frames
                        let framesByFrameRate = totalFrames / CGFloat(frameRate) / (speedRate / 100)
                        let duration = (framesByFrameRate / framesByFrameRate) * (speedRate / 100)
                        adjustBeatValuesWithBar.append([startPos, endPos, totalFrames, duration, barCounts])
                        startPos = 0.0
                        endPos = 0.0
                    }
                }
            }
        } catch {}
        
        return adjustBeatValuesWithBar
    }
    
    public func getBeatStartTime(speedRate: Double) -> [[Double]]{
        var timeStamps: [[Double]] = []
        var timeStampWithBeat: [Double] = []
        var beats: [[Double]] = []
        var skipOffset = 0
        let beatInitial = 1.0
        var index = 0
        guard let musicModel: MusicModel = self.music else {
            return timeStamps
        }
        guard let allBeats = musicModel.beats else {
            return timeStamps
        }
        for beat in allBeats {
            beats.append([beat[0] / (speedRate), beat[1]])
        }
        for i in 0...beats.count - 1 {
            if (skipOffset >= 1){
                if(beats[i][1] == beatInitial){
                    skipOffset = skipOffset - 1
                }
                continue
            } else {
                timeStampWithBeat.append(beats[i][0])
                if(beats[i][1] == englishValesBeatCount && danceNameFound == AppModel.ENGLISH_VALSE){
                    timeStamps.append(timeStampWithBeat)
                    timeStampWithBeat = []
                    index = index + 1
                } else if (beats[i][1] == tangoBeatCount && danceNameFound == AppModel.TANGE) {
                    timeStamps.append(timeStampWithBeat)
                    timeStampWithBeat = []
                    index = index + 1
                } else if (beats[i][1] == quickStepBeatCount && danceNameFound == AppModel.QUICKSTEP) {
                    timeStamps.append(timeStampWithBeat)
                    timeStampWithBeat = []
                    index = index + 1
                } else if (beats[i][1] == slowFoxBeatCount && danceNameFound == AppModel.SLOWFOX) {
                    timeStamps.append(timeStampWithBeat)
                    timeStampWithBeat = []
                    index = index + 1
                } else if (beats[i][1] == wienerValseBeatCount && danceNameFound == AppModel.WIENER_VALSE) {
                    timeStamps.append(timeStampWithBeat)
                    timeStampWithBeat = []
                    index = index + 1
                }
                if(index == 2){
                    return timeStamps
                }
            }
        }
        
        
        return timeStamps
    }
    
    // Reset Footsteps with respect to beat and speed rate
    public func resetAnimationWithSpeedChange (speedRate : Double) ->  [[Double]] {
        var beatVals: [[Double]] = []
        guard let music = self.music else {
            return beatVals
        }
        guard let beats = music.beats else {
            return beatVals
        }
        
        for beat in beats {
            beatVals.append([beat[0] / (speedRate / 100), beat[1]])
        }
        
        return self.getAnimationSubMovesWithBeatByBar(beatValues: beatVals, stepsInfo: self.animationSubMovesByFrames, speedRate: speedRate)
    }
    
    // Reset Footsteps with respect to beat and speed rate
    public func resetVideoWithSpeedChange (speedRate : Double) ->  [[Double]] {
        var beatVals: [[Double]] = []
        guard let music = self.music else {
            return beatVals
        }
        
        guard let beats = music.beats else {
            return beatVals
        }
        
        guard let videoPath = danceMove?.video.filename else {
            return beatVals
        }
        
        for beat in beats {
            beatVals.append([beat[0] / (speedRate / 100), beat[1]])
        }
        
        return self.getVideoWithBeat(beatValues: beatVals, stepsInfo: getVideoFrames(videoPathName: videoPath, danceName: self.danceMove!.name), speedRate: speedRate)
    }
    
    // Most comment duration for avataar
    private func findMostCommonBeatValue(data:[Double]) -> Double{
        var frequency: [Double:Int] = [:]
        for x in data {
            frequency[x] = (frequency[x] ?? 0) + 1
        }
        let sortedData  = frequency.sorted{ $0.1 > $1.1 }
        return sortedData.first?.key ?? 0
    }
    
    public func getScallingForFootSteps(val: Double) -> Double{
        let defaultScalingResolution = 400.0
        var defaultScale = 2.0
        if(val > defaultScalingResolution){
            return defaultScale + (val / defaultScalingResolution)
        }
        
        return defaultScale
    }
    
    public func removeObjects(){
        self.animationView = .init(name: "sadas")
        self.modelData = CustomScnNode()
    }
}

extension Double {
    func rounded(digits: Int) -> Double {
        let multiplier = pow(10.0, Double(digits))
        return (self * multiplier).rounded() / multiplier
    }
}
