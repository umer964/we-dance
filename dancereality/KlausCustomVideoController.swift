//
//  CustomViewController.swift
//  dancereality
//
//  Created by Saad Khalid on 24.01.23.
//

import UIKit
import AVKit

class KlausCustomVideoController: UIViewController {

    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    @IBOutlet weak var playBtn: UIImageView!
    @IBOutlet weak var forwardBackwardSlide: UISlider!
    @IBOutlet weak var videoViewHolder: UIView!
    @IBOutlet weak var beatLabel: UILabel!
    @IBOutlet weak var resetBtn: UIImageView!
    private var videoData: [Timer] = []
    private var videoPlaying: Bool = false
    private let musicHelper = MusicHelper()
    private var sceneHelper: SceneScenarioHelper!
    private var videoName: String = ""
    private var maxFrames: Float = 0.0
    private var previousStep: Int = 0
    @IBOutlet weak var speedLabel: UILabel!
    private var currentInterval : Float = 1.0
    private var isDefaultActive : Bool = true
   
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Confirmation", message: "Do you want to proceed?", preferredStyle: .alert)

        // Create the "Yes" action
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            let musicName = self.sceneHelper?.getMusic()?.fileName
            let fileURL = documentDirectory.appendingPathComponent((self.sceneHelper?.getDanceSubDetailts().name)!+"video.json")
            let data: [String: Any] = [
                "name": (self.sceneHelper?.getDanceSubDetailts().name)!,
                "speed": self.forwardBackwardSlide.value,
            ]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                
                // Write the JSON data to the file
                try jsonData.write(to: fileURL)
                UserDefaults.standard.set(self.forwardBackwardSlide.value, forKey: (self.sceneHelper?.getDanceSubDetailts().name)!+"video")
                self.invalidateAllVideoTimer()
                self.dismiss(animated: true, completion: nil)
            } catch {
                print("Error creating JSON file: \(error)")
            }
            
        }

        // Create the "No" action
        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
            
        }

        // Add the actions to the alert controller
        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let path = AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.DOWNLOAD_DIRECTORY)
        var videoPath: URL = URL(fileURLWithPath: path.absoluteString)
        switch(self.sceneHelper.getDanceSubDetailts().name){
        case "2 Walk BW":
            videoPath = Bundle.main.url(forResource: "TWF", withExtension: "mp4")!
            break;
        case "One Walk With Rock Turn Fw Leader":
            videoPath = Bundle.main.url(forResource: "OWWRTL", withExtension: "mp4")!
            break;
        case "2 steps":
            videoPath = Bundle.main.url(forResource: "TWL", withExtension: "mp4")!
            break;
        case "tango choregraphy":
            videoPath = Bundle.main.url(forResource: "Tango Choreo", withExtension: "mp4")!
            break;
        case "1-3 Natural Turn BW":
            videoPath = Bundle.main.url(forResource: "1-3NTF", withExtension: "mp4")!
            break;
        case "Chasse":
            videoPath = Bundle.main.url(forResource: "CRL", withExtension: "mp4")!
            break;
        case "1-6 natural turn":
            videoPath = Bundle.main.url(forResource: "1-6NTL", withExtension: "mp4")!
            break;
        default:
            break;
        }
        forwardBackwardSlide.minimumValue = 0.5
        forwardBackwardSlide.maximumValue = 1.5
        if let retrievedString = UserDefaults.standard.string(forKey: (self.sceneHelper?.getDanceSubDetailts().name)!+"video") {
            self.speedLabel.text = "Speed: " + String(retrievedString)
            self.forwardBackwardSlide.value = Float(retrievedString)!
            isDefaultActive = false
        } else {
            print("String not found in UserDefaults")
            forwardBackwardSlide.value = 1.0
            isDefaultActive = true
        }
        player = AVPlayer(url: videoPath)
        player.isMuted = true
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = UIScreen.main.bounds
        playerLayer.videoGravity = .resizeAspectFill
        videoViewHolder.layer.addSublayer(playerLayer)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        maxFrames = round(Float((player.currentItem?.asset.duration.seconds)!) * 60)
        forwardBackwardSlide.isContinuous = false
       
        let playTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.handlePlayBtn))
        playTapGetsure.numberOfTapsRequired = 1
        self.playBtn.addGestureRecognizer(playTapGetsure)
        
        let resetTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.handleResetBtn))
        resetTapGetsure.numberOfTapsRequired = 1
        self.resetBtn.addGestureRecognizer(resetTapGetsure)
        self.playBtn.isUserInteractionEnabled = true
        self.resetBtn.isUserInteractionEnabled = true
        self.beatLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.bringSubviewToFront(self.playBtn)
        self.view.bringSubviewToFront(self.forwardBackwardSlide)
    
    }
    
    private func setUpVideo(rate: Double) {
        if(!videoPlaying){
            if(self.videoData.isEmpty){
                if(sceneHelper?.getBeatStartTime(speedRate: rate / 100).count == 2){
                    let beatForCounter = sceneHelper?.getBeatStartTime(speedRate: rate / 100)[1]
                    if let slectedMusic = self.sceneHelper?.getMusic(){
                        if let instrumentMusic = slectedMusic.instrumentalFileName {
                            musicHelper.playBackgroundMusic(dance: slectedMusic.orignalFileName,
                                                            slowDance: instrumentMusic, rate: 1.0)
                        } else {
                            musicHelper.playBackgroundMusic(dance: slectedMusic.orignalFileName,
                                                            slowDance: nil, rate: 1.0)
                        }
                    }
                    self.beatLabel.isHidden = false
                    for i in 0...beatForCounter!.count - 1{
                        DispatchQueue.main.asyncAfter(deadline: .now() + beatForCounter![i]) {
                            if(i == 0){
                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                
                            }
                        }
                    }
                    let data = sceneHelper?.resetVideoWithSpeedChange(speedRate: 100.0)
                    for i in 0...data!.count - 1{
                        self.videoData.append(Timer.scheduledTimer(timeInterval: data![i][0],
                                                                   target: self,
                                                                   selector: #selector(self.videoWithBeat),
                                                                   userInfo: ["duration": data![i][3]],
                                                                   repeats: false))
                    }
                }
            }
            self.videoPlaying = true
        } else {
            self.videoPlaying = false
        }
    }
    
    @objc func handlePlayBtn() {
        setUpVideo(rate: Double(forwardBackwardSlide.value*100))
    }

    @objc func handleResetBtn() {
        self.isDefaultActive = true
        self.invalidateAllVideoTimer()
        setUpVideo(rate: Double(forwardBackwardSlide.value))
    }
    
    @IBAction func handleCloseBtn(_ sender: Any) {
        self.invalidateAllVideoTimer()
        dismiss(animated: true, completion: nil)
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
        if(isDefaultActive){
            player.playImmediately(atRate: Float(duration))
            self.speedLabel.text = String(format: "%.2f", duration)
            self.forwardBackwardSlide.value = Float(duration)
        } else {
            player.playImmediately(atRate: Float(self.forwardBackwardSlide.value))
        }
        
       
        self.playBtn.isUserInteractionEnabled = false
        self.playBtn.image = UIImage(named: "pause")

        DispatchQueue.main.asyncAfter(deadline: .now() + (player.currentItem?.duration.seconds ?? 1)) {
           
        }
        self.beatLabel.isHidden = true
    }
    
    @objc func playerDidFinishPlaying(_ notification: Notification) {
        // Perform actions after the video finishes playing
        self.playBtn.isUserInteractionEnabled = true
        self.playBtn.image = UIImage(named: "start")
        print("Video finished playing")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.invalidateAllVideoTimer()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            // Perform actions when the view is about to disappear
            
    }
    
    @IBAction func forwardBackwardChanged(_ sender: Any) {
        
//
        self.invalidateAllVideoTimer()
        self.videoPlaying = false
        self.isDefaultActive = false
        self.speedLabel.text = "Speed" + String(format: "%.2f", self.forwardBackwardSlide.value)
        setUpVideo(rate: Double(forwardBackwardSlide.value))
        
//        player.currentItem?.step(byCount: Int(forwardBackwardSlide.value))
   
//        player.seek(to: CMTime(seconds: Double(interval), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
    }
    
    public func movePlayerToFrame(interval: Int, countParam: Int){
        var index = 1
        while(index <= interval){
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
        
        musicHelper.audioPlayer?.pause()
    }
}

