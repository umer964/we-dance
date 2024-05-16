//
//  CustomViewController.swift
//  dancereality
//
//  Created by Saad Khalid on 24.01.23.
//

import UIKit
import AVKit

class CustomVideoController: UIViewController {

    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    @IBOutlet weak var playBtn: UIImageView!
    @IBOutlet weak var speedSlide: UISlider!
    @IBOutlet weak var forwardBackwardSlide: UISlider!
    @IBOutlet weak var forBackHolder: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var videoViewHolder: UIView!
    @IBOutlet weak var beatLabel: UILabel!
    private var videoData: [Timer] = []
    private var videoPlaying: Bool = false
    private let musicHelper = MusicHelper()
    private var sceneHelper: SceneScenarioHelper!
    @IBOutlet weak var forBackIcon: UIImageView!
    @IBOutlet weak var menuBtnHolder: UIView!
    @IBOutlet weak var speedVal: UILabel!
    private var videoName: String = ""
    private var maxFrames: Float = 0.0
    private var previousStep: Int = 0
    private var currentInterval : Float = 1.0
    private var roundedValue = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
            let path = AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.DOWNLOAD_DIRECTORY)
            let videoPath = path.appendingPathComponent(sceneHelper.getDanceSubDetailts().video.filename)
            player = AVPlayer(url: videoPath)
            player.isMuted = true
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = UIScreen.main.bounds
            playerLayer.videoGravity = .resizeAspectFill
            videoViewHolder.layer.addSublayer(playerLayer)
            speedSlide.minimumValue = 0.5
            speedSlide.maximumValue = 1.0
            speedSlide.value = 1.0
            speedSlide.isContinuous = false
            forwardBackwardSlide.frame = CGRect(x: 0, y: 0, width: self.speedSlide.frame.width, height: self.speedSlide.frame.height)
            forBackHolder.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
            forwardBackwardSlide.value = 0.0
            forwardBackwardSlide.minimumValue = 1.0
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            maxFrames = round(Float((player.currentItem?.asset.duration.seconds)!) * 60)
            forwardBackwardSlide.maximumValue = maxFrames
            forwardBackwardSlide.maximumValue = 100.0
            let playTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.handlePlayBtn))
            playTapGetsure.numberOfTapsRequired = 1
            self.playBtn.addGestureRecognizer(playTapGetsure)
            self.playBtn.isUserInteractionEnabled = true
            self.beatLabel.isHidden = true
            roundedValue = Double(roundf(self.speedSlide.value / 0.1) * 0.1);
            self.speedVal.text = String(format: "%.0f", ((speedSlide.value * 100) - 100)) + "%"
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.bringSubviewToFront(self.playBtn)
        self.view.bringSubviewToFront(self.speedSlide)
        self.view.bringSubviewToFront(self.forwardBackwardSlide)
        self.view.bringSubviewToFront(self.closeBtn)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.invalidateAllVideoTimer()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        if let player = self.musicHelper.audioPlayer{
            player.pause()
        }
    }
    
    @objc func playerDidFinishPlaying(_ notification: Notification) {
        // Perform actions after the video finishes playing
        self.playBtn.isUserInteractionEnabled = true
        self.playBtn.image = UIImage(named: "start")
        self.showControls()
        print("Video finished playing")
    }
    
    private func setUpVideo(rate: Double) {
        self.hideControls()
        if(!videoPlaying){
            if(self.videoData.isEmpty){
                guard let sceneHelper = self.sceneHelper else{
                    self.showControls()
                    return
                }
                if(sceneHelper.getBeatStartTime(speedRate: rate / 100).count == 2){
                    let beatForCounter = sceneHelper.getBeatStartTime(speedRate: rate / 100.0)[1]
                    if let slectedMusic = self.sceneHelper?.getMusic(){
                        if let instrumentMusic = slectedMusic.instrumentalFileName {
                            musicHelper.playBackgroundMusic(dance: slectedMusic.orignalFileName,
                                                            slowDance: instrumentMusic, rate: rate / 100.0)
                        } else {
                            musicHelper.playBackgroundMusic(dance: slectedMusic.orignalFileName,
                                                            slowDance: nil, rate: rate / 100.0)
                        }
                    }
                    self.beatLabel.isHidden = false
                    for i in 0...beatForCounter.count - 1{
                        DispatchQueue.main.asyncAfter(deadline: .now() + beatForCounter[i]) {
                            if(i == 0){
                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                            }
                        }
                    }
                    let data = sceneHelper.resetVideoWithSpeedChange(speedRate: rate)
                    for i in 0...data.count - 1{
                        self.videoData.append(Timer.scheduledTimer(timeInterval: data[i][0],
                                                                   target: self,
                                                                   selector: #selector(self.videoWithBeat),
                                                                   userInfo: ["duration": data[i][3]],
                                                                   repeats: false))
                    }
                }
            }
            self.videoPlaying = true
        } else {
            self.videoPlaying = false
        }
    }
    
    private func hideControls(){
        self.forBackHolder.isHidden = true
        self.menuBtnHolder.isHidden = true
    }
    private func showControls(){
       
        self.forBackHolder.isHidden = false
        self.menuBtnHolder.isHidden = false
    }
    
    @objc func handlePlayBtn() {
        forwardBackwardSlide.value = 0.0
        setUpVideo(rate: 100.0 * roundedValue)
    }

    @IBAction func handleCloseBtn(_ sender: Any) {
        self.invalidateAllVideoTimer()
        dismiss(animated: true, completion: nil)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .portrait // Set the desired orientation mode, in this case, portrait only
    }
    
    @objc func videoWithBeat(sender: Timer) {
        let timerData = sender.userInfo as! [String : Any]
        let duration: Double = timerData["duration"]! as! Double
        self.videoData.removeFirst()
        if(!self.videoPlaying){
            return
        }
        player.seek(to: CMTime(seconds: Double(0.0), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        self.videoPlaying = false
        //player.rate = Float(duration)
        player.playImmediately(atRate: Float(duration))
        self.playBtn.isUserInteractionEnabled = false
        self.playBtn.image = UIImage(named: "pause")
        self.beatLabel.isHidden = true
    }

    @IBAction func speedChanged(_ sender: Any) {
        self.player.rate = self.speedSlide.value
        self.player.pause()
        self.videoPlaying = false
        self.invalidateAllVideoTimer()
        roundedValue = Double(roundf(self.speedSlide.value / 0.1) * 0.1);
        musicHelper.setRate(rate: Float(roundedValue))
        self.speedSlide.value = Float(roundedValue)
        self.speedVal.text = String(format: "%.0f", (speedSlide.value * 100) - 100) + " % "
    }
    
    @IBAction func forwardBackwardChanged(_ sender: Any) {
        let interval = Int((forwardBackwardSlide.value))
        let diffInInterval = abs(interval - previousStep)
        if(currentInterval == Float(interval) || diffInInterval == 0){
            return
        }
        currentInterval = Float(interval)
        self.videoPlaying = false
        self.invalidateAllVideoTimer()
        if(Int(interval) >= previousStep){
            self.movePlayerToFrame(interval: diffInInterval, countParam: 1)
        } else {
            self.movePlayerToFrame(interval:  diffInInterval, countParam: -1)
        }
        previousStep = interval
//
        forwardBackwardSlide.value = Float(interval)
        
      
//        player.currentItem?.step(byCount: Int(forwardBackwardSlide.value))
   
//        player.seek(to: CMTime(seconds: Double(interval), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
    }
    
    public func movePlayerToFrame(interval: Int, countParam: Int){
        let total = round(Float((player.currentItem?.asset.duration.seconds)!) * 60)
        var intervl = Float(interval) / Float(100)
        intervl = Float(intervl) * Float(total)
        var index = 0
        while(index <= Int(intervl)){
            player.currentItem?.step(byCount: countParam)
            index += 1
        }
        
    }
    
    public func setVideoInformation(video: String ,sceneHelper: SceneScenarioHelper){
        self.videoName = video
        self.sceneHelper = sceneHelper
    }
    
    private func invalidateAllVideoTimer(){
        if(!self.videoData.isEmpty){
            for timer in self.videoData {
                timer.invalidate()
                self.videoData.removeFirst()
            }
            self.player.seek(to: .zero)
        }
        
        if let player = musicHelper.audioPlayer{
            player.pause()
            
        }
    }
}
