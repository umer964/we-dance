//
//  ViewController.swift
//  dancetrain
//
//  Created by Saad Khalid on 22.11.21.
//

import UIKit
import SceneKit
import ARKit
import AVKit
import Lottie
import Vision
import CoreMotion
import CoreML

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet weak var menuBackBtn: UIImageView!
    @IBOutlet weak var menuHeading: UILabel!
    @IBOutlet weak var mainTableItems: UITableView!
    @IBOutlet weak var avatarMode: UIImageView!
    @IBOutlet weak var footstepMode: UIImageView!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var speedMove: UISlider!
    @IBOutlet weak var forbackMove: UISlider!
    @IBOutlet weak var playBtn: UIImageView!
    @IBOutlet weak var pauseBtn: UIImageView!
    @IBOutlet weak var trainBtn: UIImageView!
    @IBOutlet weak var footSettings: UIView!
    @IBOutlet weak var youtubeBtnImage: UIImageView!
    @IBOutlet weak var dancerBtnImage: UIImageView!
    @IBOutlet weak var musicBtnImage: UIImageView!
    @IBOutlet weak var resetView: UIView!
    @IBOutlet weak var resetViewBtn: UIImageView!
    @IBOutlet weak var settingBtnImage: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var menuHolder: UIView!
    @IBOutlet weak var gesturesHolder: UIView!
    @IBOutlet weak var speedStatus: UILabel!
    @IBOutlet weak var forwardBackStatus: UILabel!
    @IBOutlet weak var speedIcon: UIImageView!
    @IBOutlet weak var forbackIcon: UIImageView!
    private let minInstructions = 0;
    private let maxInstructions = 9;
    private var currentInstructionActiveDefault = true
    private var currentInstructions = 0;
    private var englishValseMusicCounter: EnglishValseMusicHelper?
    private var slowFoxMusicCounter: SlowFoxCounterHelper?
    private var quickStepMusicCounter: QuickStepCounterHelper?
    private var weinerValseMusicCounter: WeinerValseMusicHelper?
    private var tangoMusicCounter: TangoCounterHelper?
    private let counterLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 150))

    // Setup Tour
    let customView: UIView = {
            let view = UIView()
            view.backgroundColor = .lightGray
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        // UILabel inside the custom view
    let label: UILabel = {
            let label = UILabel()
            label.text = "Hello, this is a custom view."
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        // "Next" button
    let nextButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Next", for: .normal)
            button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
    let backButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Back", for: .normal)
            button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
    // Dance move info
    private var danceMove: Int?
    private var danceSubMove: String?
    var task: DispatchWorkItem? = nil
    // var mlModel: footstepDetector2?
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    private let serialQueue = DispatchQueue(label: "com.aboveground.dispatchqueueml")
    // Dance move statues
    private var avatarAdded : Bool = false
    private var footAdded : Bool = false
    private var isFootDummyAdded : Bool = false
    private var isAvatartClose : Bool = false
    private var actionType : String = ""
    private var sceneType : String = ""
    private var footAnimating : Bool = false
    private var modelAnimating : Bool = false
    private var isAlertPresented = false
    private var isDeviceDownFaced = false
    private var isDeviceUpFaced = false
    private var isFootModeActive = false
    private var isAvatarModeActive = true
    private var trainMode = false
    private var settingsOpen = false
    private var isModeEnabled = false
    private var isImageTrackingEnabled = false
    
    // Scheduler
    private var timer : Timer?
    
    // animation params
    private var footstepsAnimationData: [Timer] = []
    private var avatarAnimationData: [Timer] = []
    private var videoData: [Timer] = []
    private var footstepsFrameData: [[Double]] = []
    private var footAnimationProgress = 0
    
    // Data Sources
    private var dancesDataSource: MyData?
    private var danceMovesByDanceDataSource: DanceSubMovesAdapter?
    
    // Helpers
    private var musicHelper :MusicHelper! = MusicHelper.sharedHelper;
    
    private var sceneHelper : SceneScenarioHelper?
    private var stepDetectionHelper: StepDetectedHelper?
    private let motionManager: CMMotionManager = CMMotionManager();
    private let pedometer = CMPedometer()
    private var avatarAnimationPlayer: SCNAnimationPlayer = SCNAnimationPlayer()
    
    //Scene Nodes
    private var footPlaceHolder = SCNNode(geometry: SCNPlane(width: 1, height: 1))
    private var klausNode : CustomScnNode?
    private let avatarPlaceHolder = SCNNode(geometry: SCNPlane(width: 1, height: 1))
    private var boundingboxAlert = UIAlertController(title: "Bounding Box Alert", message: "Alert", preferredStyle: .alert)
    
    // Music Settings
    private var songDuration : Double = 0
    private var speedRate: Double = 1.0
    
    // Dynamic Views
    private let alert = UIAlertController(title: nil, message: "Move Quality: Very Good", preferredStyle: .alert)
    private var animationView: AnimationView?
    private var animationViewTemplate: AnimationView?
    private var animationViewInstructions: AnimationView?
    private var instrcutionMainAnimationView : AnimationView?
    private var avatarSliderAnimation: AnimationView?
    private var instructionSub: AnimationView?
    private let animationHolderView = UIView(frame: CGRect(x: 50, y: 0, width: 400, height: 400));
    private var spinnerLoader: SpinnerViewController?
    private var nextViewController: AlertViewController?
    
    // Position vectors
    private var cameraAngle: SCNVector3 = SCNVector3(0,0,0)
    private var avatarPosition : SCNVector3?
    private var footPosition : SCNVector3?
    private let avatarScaleDefalut = 0.008
    private let animationScaleDefault = 2
    private var avatarScale: SCNVector3 = SCNVector3(x: 0.008, y: 0.008, z: 0.008)
    private var footScale: SCNVector3 = SCNVector3(x: 2, y: 2, z: 2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        // Show statistics such as fps and timing information
        //        sceneView.showsStatistics = true
        //        sceneView.debugOptions = .showFeaturePoints
        self.becomeFirstResponder()
        let scene = SCNScene()
        do {
            //mlModel = try footstepDetector2()
        } catch {
            print("some error from model")
        }
        
        sceneView.scene = scene
        sceneView.preferredFramesPerSecond = 60
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        if let userInfo = FileHelper.getObjectFromUserDefaults(key: "USER"){
            if(userInfo.roles.contains("ADMIN")){
                trainBtn.isHidden = false
            } else {
                trainBtn.isHidden = true
            }
        } else {
            trainBtn.isHidden = true
        }
        // Zoom scene
        self.animationHolderView.isUserInteractionEnabled = true
        
        // Views
        counterLabel.center = self.view.center
        counterLabel.textAlignment = .center
        counterLabel.textColor = .black
        counterLabel.font = UIFont.boldSystemFont(ofSize: 100.0)
        // Gestures
        addBtnGestures()
        animationViewTemplate = .init(name: "marker")
        animationViewInstructions = .init(name: "insrtruction")
        animationView = .init(name: "")
        instrcutionMainAnimationView = .init(name : "main_instructions")
        instructionSub = .init(name : "123go")
        
        animationViewTemplate!.frame = view.bounds
        // 3. Set animation content mode
        animationViewTemplate!.contentMode = .scaleAspectFit
        // 4. Set animation loop mode
        animationViewTemplate!.loopMode = .loop
        // 5. Adjust animation speed
        speedMove.value = 1.0
        speedMove.maximumValue = 1.0
        speedMove.minimumValue = 0.5
        speedMove.isContinuous = false
        speedStatus.text = String(format: "%.0f", (speedMove.value * 100) - 100) + " % "
        animationViewTemplate!.animationSpeed = CGFloat(speedMove.value)
        view.addSubview(self.animationViewTemplate!)
        self.menuHolder.transform =  CGAffineTransform(rotationAngle: CGFloat.pi * -0.5)
        animationViewInstructions!.frame = view.bounds
        // 3. Set animation content mode
        animationViewInstructions!.contentMode = .scaleAspectFit
        // 4. Set animation loop mode
        animationViewInstructions!.loopMode = .loop
        // 5. Adjust animation speed
        
        animationViewInstructions!.animationSpeed = CGFloat(speedMove.value)
        view.addSubview(self.animationViewInstructions!)
        
        // sub
        instructionSub!.frame = view.bounds
        // 3. Set animation content mode
        instructionSub!.contentMode = .scaleAspectFit
        // 4. Set animation loop mode
        instructionSub!.loopMode = .loop
        // 5. Adjust animation speed
        
        instructionSub!.animationSpeed = CGFloat(speedMove.value)
        view.addSubview(self.instructionSub!)
        
        // main instructions
        instrcutionMainAnimationView!.frame = view.bounds
        // 3. Set animation content mode
        instrcutionMainAnimationView!.contentMode = .scaleAspectFit
        // 4. Set animation loop mode
        instrcutionMainAnimationView!.loopMode = .loop
        // 5. Adjust animation speed
        
        instrcutionMainAnimationView!.animationSpeed = CGFloat(speedMove.value)
        view.addSubview(self.instrcutionMainAnimationView!)
        // main instructions settings end
        footSettings.isHidden = true
        forbackMove.isHidden = true
        backBtn.isHidden = true
        resetView.isHidden = true
        resetViewBtn.isHidden = true
        forwardBackStatus.isHidden = true
        self.animationViewTemplate!.isHidden = true
        self.animationViewInstructions?.isHidden = true
        self.instrcutionMainAnimationView?.isHidden = true
        self.instructionSub?.isHidden = true
        self.animationViewInstructions?.pause()
        self.menuHolder.isHidden = true
        showMenu()
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
//        if(event!.subtype == UIEvent.EventSubtype.motionShake) {
//            if let screenHelper = self.sceneHelper,
//               let animationView = self.animationView {
//                animationView.currentFrame = 1
//                self.invalidateAllAvatarTimer()
//                self.invalidateAllFootStepTimers()
//                self.footstepsFrameData = Array(screenHelper.getFootStepsAnimationsFrames())
//                self.timer = Timer.scheduledTimer(timeInterval: 2.0,
//                                                  target: self,
//                                                  selector: #selector(timerFired),
//                                                  userInfo: nil,
//                                                  repeats: true)
//            }
//        }
    }
    
    private func moveFootAnimationWithShake(){
        if(self.footstepsFrameData.count <= 0){
            if let timer = self.timer {
                timer.invalidate()
            }
            return
        }
        if let animationView = self.animationView{
            animationView.play(fromFrame: self.footstepsFrameData[0][0], toFrame: self.footstepsFrameData[0][1]){ _ in
                self.stepDetectionHelper = StepDetectedHelper(window: self.footstepsFrameData[0][1] - self.footstepsFrameData[0][0], completion: {
                    self.footstepsFrameData.remove(at: 0)
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0,
                                                      target: self,
                                                      selector: #selector(self.timerFired),
                                                      userInfo: nil,
                                                      repeats: true)
                })
            }
        }
    }
    
    func captureScreenshot(image: @escaping(UIImage)->()){
        DispatchQueue.main.async {
            UIGraphicsBeginImageContext(self.sceneView.frame.size)
            self.sceneView.drawHierarchy(in: self.sceneView.bounds, afterScreenUpdates: true)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let screenshotFinal = screenshot {
                image(screenshotFinal)
            }
        }
    }
    
    func pixelBuffer(from image: UIImage, width: Int, height: Int) -> CVPixelBuffer? {
        let attributes: [NSObject: AnyObject] = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         kCVPixelFormatType_32ARGB,
                                         attributes as CFDictionary,
                                         &pixelBuffer)
        
        guard status == kCVReturnSuccess, let unwrappedPixelBuffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let pixelData = CVPixelBufferGetBaseAddress(unwrappedPixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(data: pixelData,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(unwrappedPixelBuffer),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: CGFloat(height))
        context?.scaleBy(x: 1, y: -1)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return unwrappedPixelBuffer
    }
    
    @objc private func timerFired(){
        serialQueue.async  {
            self.captureScreenshot { image in
                guard let capturedImageFixed = self.pixelBuffer(from:image, width: 600, height: 1200) else {
                    return
                    
                }
                let handler = VNImageRequestHandler(cvPixelBuffer: capturedImageFixed, options: [:])
                
                if let visionRequest = self.request{
                    do {
                        try handler.perform([visionRequest])
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
    
    func setupMlModel(){
//        guard let mlModel = self.mlModel else {
//            return
//        }
//        if let visionModel = try? VNCoreMLModel(for: mlModel.model) {
//            self.visionModel = visionModel
//            self.request = VNCoreMLRequest(model: visionModel, completionHandler: self.visionComplete)
//        }
    }
    
    func visionComplete(request: VNRequest, error: Error?) {
        if let error = error {
            print("Error: \(error)")
            return
        }
        
        guard let results = request.results as? [VNRecognizedObjectObservation] else {
            return
        }
        
        if let confidence = results.first?.confidence.magnitude,
           let prediction = results.first?.labels.first?.identifier{
            if(confidence >= 0.90 && prediction == "footsteps"){
                if let timer = self.timer {
                    self.moveFootAnimationWithShake()
                    timer.invalidate()
                }
                if(prediction == "footsteps"){
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
            }
        }
    }
    
//    @IBAction func forbackTouchDown(_ sender: Any) {
//        if UIDevice.current.orientation == .faceUp {
//            // Device is facing down
//            if(!self.isDeviceDownFaced){
//                self.isDeviceDownFaced = true
//                self.isDeviceUpFaced = false
//                setupForBackForFoot()
//            }
//            print("Device is facing down")
//        } else {
//            // Device is facing up
//            if(!self.isDeviceUpFaced){
//                self.isDeviceUpFaced = true
//                self.isDeviceDownFaced = false
//                setupForBackForAvataar()
//            }
//            print("Device is facing up")
//        }
//    }
//
//    @IBAction func forbackTouchUp(_ sender: Any) {
//        if UIDevice.current.orientation == .faceUp {
//            // Device is facing down
//            if(!self.isDeviceDownFaced){
//                self.isDeviceDownFaced = true
//                self.isDeviceUpFaced = false
//                setupForBackForFoot()
//            }
//        } else {
//            // Device is facing up
//            if(!self.isDeviceUpFaced){
//                self.isDeviceUpFaced = true
//                self.isDeviceDownFaced = false
//                setupForBackForAvataar()
//            }
//        }
//        print("touch removed")
//    }
    
    @IBAction func onForwardBackwardSlide(_ sender: Any) {
        animationView!.pause()
        self.invalidateAllFootStepTimers()
        self.invalidateAllAvatarTimer()
        if(self.isFootModeActive){
            if let animationView = self.animationView {
                animationView.currentFrame = AnimationFrameTime(self.forbackMove.value)
            }
            forwardBackStatus.text = String(format: "%.2f", forbackMove.value)
        }
        if(self.isAvatarModeActive){
            self.sceneView.scene.isPaused = false
            if let klausNode = self.klausNode {
                let minValue: Float = 0
                let maxValue: Float = 1
                let normalizedValue = ((sender as AnyObject).value - minValue) / (maxValue - minValue)
                let totalDuration = klausNode.getAnimationDuration()
                let timeOffset = TimeInterval(normalizedValue) * totalDuration
                if let player = klausNode.getAnimationPlayer(){
                    player.play()
                    player.animation.timeOffset = timeOffset
                    DispatchQueue.main.asyncAfter(deadline: .now()+timeOffset){
                        player.stop()
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("disappring now....")
    }
    
    private func checkDeviceOrientation(){
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion is not available.")
            return
        }
        motionManager.deviceMotionUpdateInterval = 1.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motionData, error in
            guard let motionData = motionData, error == nil else {
                print("Failed to receive device motion updates: \(error?.localizedDescription ?? "")")
                return
            }
            
            self?.processMotionData(motionData)
        }
    }
    
    private func processMotionData(_ motionData: CMDeviceMotion) {
        let orientation = UIDevice.current.orientation
        
        if orientation == .faceUp {
            // Device is facing down
            if(!self.isDeviceDownFaced){
                self.isDeviceDownFaced = true
                self.isDeviceUpFaced = false
                setupForBackForFoot()
            }
            print("Device is facing down")
        } else {
            // Device is facing up
            if(!self.isDeviceUpFaced){
                self.isDeviceUpFaced = true
                self.isDeviceDownFaced = false
                setupForBackForAvataar()
            }
            print("Device is facing up")
        }
        print(orientation)
    }
    
    private func setupForBackForFoot(){
        if let animationView = self.animationView,
           let sceneHelper = self.sceneHelper {
            self.forbackMove.value = 1
            self.forbackMove.maximumValue = Float((animationView.animation!.duration)) * 30
            if(sceneHelper.getDanceTypeDetails().name == AppModel.ENGLISH_VALSE ||
               sceneHelper.getDanceTypeDetails().name == AppModel.WIENER_VALSE){
                self.forbackMove.maximumValue = Float((animationView.animation!.duration)) * 30
            }
            if(sceneHelper.getDanceTypeDetails().name == AppModel.TANGE ||
               sceneHelper.getDanceTypeDetails().name == AppModel.SLOWFOX ||
               sceneHelper.getDanceTypeDetails().name == AppModel.QUICKSTEP){
                self.forbackMove.maximumValue = Float((animationView.animation!.duration)) * 60
            }
            animationView.isHidden = false
            animationView.alpha = 1
            self.forbackMove.minimumValue = 1
            self.footAnimating = false
            self.modelAnimating = false
            self.forbackMove.isContinuous = true
            self.invalidateAllFootStepTimers()
            self.invalidateAllAvatarTimer()
            if let slectedMusic = sceneHelper.getMusic(){
                musicHelper.playBackgroundMusic(dance: slectedMusic.orignalFileName,
                                                slowDance: nil,
                                                rate: 1.0,
                                                vol: 0.05)
            }
            self.forwardBackStatus.text = String(format: "%.2f", forbackMove.value)
            self.forbackMove.isContinuous = true
        }
    }
    
    private func setupForBackForAvataar(){
        if let sceneHelper = self.sceneHelper,
           let animationView = self.animationView{
            self.forbackMove.maximumValue = 1
            animationView.isHidden = false
            animationView.alpha = 1
            self.forbackMove.minimumValue = 0
            self.forbackMove.value = 0
            self.forbackMove.isContinuous = false
            self.footAnimating = false
            self.modelAnimating = false
            self.invalidateAllFootStepTimers()
            self.invalidateAllAvatarTimer()
            if let slectedMusic = sceneHelper.getMusic(){
                musicHelper.playBackgroundMusic(dance: slectedMusic.orignalFileName,
                                                slowDance: nil,
                                                rate: 1.0,
                                                vol: 0.05)
            }
            self.forwardBackStatus.text = String(format: "%.2f", forbackMove.value)
            self.forbackMove.isContinuous = true
        }
    }
    
    private func loadAnimation(){
        let flipping = CGAffineTransform(scaleX: -1, y: 1)
        let rotating = CGAffineTransform(rotationAngle: (-90 * .pi / 90))
        let fullTransformation = flipping.concatenating(rotating)
        if let animationView = self.animationView {
            animationView.tag = 200
            animationView.translatesAutoresizingMaskIntoConstraints = false
            animationView.transform =  fullTransformation
            animationView.frame = view.bounds
            // 3. Set animation content mode
            animationView.contentMode = .scaleAspectFit
            // 4. Set animation loop mode
            animationView.loopMode = .playOnce
            // 5. Adjust animation speed
            speedMove.value = Float(animationView.animationSpeed)
            animationHolderView.addSubview(animationView)
            animationHolderView.tag = 100
            animationHolderView.isHidden = true
            view.addSubview(animationHolderView)
        }
        
    }
    
    private func destroyAnimation(){
        for view in animationHolderView.subviews {
            view.removeFromSuperview()
        }
        for view in view.subviews {
            if(view.tag == 100){
                view.removeFromSuperview()
            }
        }
    }
    
    private func showAleart(){
        let refreshAlert = UIAlertController(title: "Area Alert",
                                             message: "Do you have space behind?",
                                             preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes",
                                             style: .default,
                                             handler: { (action: UIAlertAction!) in
            self.placeObjects()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No",
                                             style: .cancel,
                                             handler: { (action: UIAlertAction!) in
            DispatchQueue.main.async {
                self.resetEnviroment()
                self.animationHolderView.removeFromSuperview()
                self.backBtn.isHidden = true
                self.view.bringSubviewToFront(self.settingBtnImage)
            }
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    private func addBtnGestures (){
        // addTapGertureToMusicBtn
        let musicTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.musicBtnTapped))
        musicTapGesture.numberOfTapsRequired = 1
        let trainBtnGesture = UITapGestureRecognizer(target: self, action: #selector(trainBtnTapped(tapGestureRecognizer:)))
        trainBtnGesture.numberOfTapsRequired = 1
        trainBtn.isUserInteractionEnabled = true
        trainBtn.addGestureRecognizer(trainBtnGesture)
        playBtn.isUserInteractionEnabled = true
        playBtn.addGestureRecognizer(musicTapGesture)
     
        
        
        // addTapGertureToVideoBtn
        let videoTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.videoBtnTapped))
        videoTapGesture.numberOfTapsRequired = 1
        youtubeBtnImage.addGestureRecognizer(videoTapGesture)
        youtubeBtnImage.isUserInteractionEnabled = true
        
        let settingsTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.settingBtnTapped))
        settingsTapGesture.numberOfTapsRequired = 1
        settingBtnImage.addGestureRecognizer(settingsTapGesture)
        settingBtnImage.isUserInteractionEnabled = true
        
        let playBtnGesture = UITapGestureRecognizer(target: self, action: #selector(modelPlayBtnTapped(tapGestureRecognizer:)))
        avatarMode.isUserInteractionEnabled = true
        avatarMode.addGestureRecognizer(playBtnGesture)
        
        let pauseBtnGesture = UITapGestureRecognizer(target: self, action: #selector(footPlayBtnTapped(tapGestureRecognizer:)))
        footstepMode.isUserInteractionEnabled = true
        footstepMode.addGestureRecognizer(pauseBtnGesture)
        
        let playModeBtnGesture = UITapGestureRecognizer(target: self, action: #selector(playModes(tapGestureRecognizer:)))
        pauseBtn.addGestureRecognizer(playModeBtnGesture)
        pauseBtn.isUserInteractionEnabled = true
        
        let resetViewBtnGesture = UITapGestureRecognizer(target: self, action: #selector(settingBtnTap))
        resetView.isUserInteractionEnabled = true
        resetView.addGestureRecognizer(resetViewBtnGesture)
        
        
        let rotationGestureWithPan = UIPanGestureRecognizer(target: self, action: #selector(self.rotateNodeWithPanGesture(gesture:)))
        self.gesturesHolder.addGestureRecognizer(rotationGestureWithPan)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(self.handlePitch(withGestureRecognizer:)))
        self.gesturesHolder.addGestureRecognizer(pinchGestureRecognizer)
        
    }
    
    @objc func respondToDoubleTap(gesture: UIGestureRecognizer){
        if(!self.settingsOpen){
            self.settingsOpen = true
        } else {
            self.settingsOpen = false
        }
    }
    
    private func setForwardBackwardSlider() {
        if let animationView = self.animationView,
           let sceneHelper = self.sceneHelper {
            self.forbackMove.value = 1
            self.forbackMove.maximumValue = Float((animationView.animation!.duration)) * 30
            if(sceneHelper.getDanceTypeDetails().name == AppModel.ENGLISH_VALSE ||
               sceneHelper.getDanceTypeDetails().name == AppModel.WIENER_VALSE){
                self.forbackMove.maximumValue = Float((animationView.animation!.duration)) * 30
            }
            if(sceneHelper.getDanceTypeDetails().name == AppModel.TANGE ||
               sceneHelper.getDanceTypeDetails().name == AppModel.SLOWFOX ||
               sceneHelper.getDanceTypeDetails().name == AppModel.QUICKSTEP){
                self.forbackMove.maximumValue = Float((animationView.animation!.duration)) * 60
            }
            animationView.isHidden = false
            animationView.alpha = 1
            self.forbackMove.minimumValue = 1
            self.footAnimating = false
            self.invalidateAllFootStepTimers()
            self.invalidateAllAvatarTimer()
            if let slectedMusic = sceneHelper.getMusic(){
                musicHelper.playBackgroundMusic(dance: slectedMusic.orignalFileName,
                                                slowDance: nil,
                                                rate: 1.0,
                                                vol: 0.05)
            }
            self.forwardBackStatus.text = String(format: "%.2f", self.forbackMove.value)
            self.forbackMove.isContinuous = true
        }
    }
    
    @objc func settingBtnTapped(sender: UITapGestureRecognizer) {
        DispatchQueue.main.async {
            if let animationView = self.animationView,
               let sceneHelper = self.sceneHelper {
                sceneHelper.removeObjects()
                animationView.removeFromSuperview()
            }
            self.klausNode = CustomScnNode()
            self.footPlaceHolder = SCNNode()
            self.resetEnviroment()
            self.animationHolderView.removeFromSuperview()
            self.showMenu()
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.resetEnviroment()
            self.animationHolderView.removeFromSuperview()
            self.backBtn.isHidden = true
            self.view.bringSubviewToFront(self.settingBtnImage)
            self.showMenu()
        }
    }
    
    private func resetEnviroment(){
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            if(node.name == "dancer" ||
               node.name == "FOOT_HOLDER" || node.name == "DANCER_HOLDER"){
                node.removeFromParentNode()
            }
            if(node.name == "foot"){
                self.destroyAnimation()
                node.removeFromParentNode()
            }
        }
        self.resetMusicCounter()
        self.animationView = AnimationView()
        self.loadAnimation()
        self.isModeEnabled = false
        self.speedMove.value = 1.0
        self.speedMove.maximumValue = 1.0
        self.speedMove.minimumValue = 0.5
        self.speedRate = 1.0
        self.currentInstructionActiveDefault = true
        self.forbackMove.value = 1.0
        self.speedMove.isContinuous = false
        self.isImageTrackingEnabled = false
        self.forwardBackStatus.text = String(format: "%.2f", forbackMove.value)
        self.speedStatus.text = String(format: "%.0f", (speedMove.value * 100) - 100) + " % "
        self.footAdded = false
        self.avatarAdded = false
        self.isFootDummyAdded = false
        self.modelAnimating = false
        self.footAnimating = false
        self.isDeviceUpFaced = false
        self.isDeviceUpFaced = false
        self.motionManager.stopDeviceMotionUpdates()
        self.resetView.isHidden = true
        self.settingsOpen = false
        self.isAlertPresented = false
        self.menuHolder.isHidden = false
        if let timer = self.timer {
            timer.invalidate()
        }
        self.invalidateCounters()
        self.footSettings.isHidden = true
        self.menuHolder.isHidden = true
        self.resetViewBtn.isHidden = true
        self.forbackMove.isHidden = true
        self.avatarMode.isHidden = true
        self.footstepMode.isHidden = true
        self.youtubeBtnImage.isHidden = true
        self.settingBtnImage.isHidden = false
        self.trainBtn.isUserInteractionEnabled = true
        self.pauseBtn.isUserInteractionEnabled = true
        self.playBtn.isUserInteractionEnabled = true
        self.animationViewInstructions?.isHidden = true
        self.instrcutionMainAnimationView?.isHidden = true
        self.isFootModeActive = false
        self.isAvatarModeActive = true
        self.footstepMode.alpha = 0
        self.avatarMode.alpha = 0
        self.youtubeBtnImage.alpha = 0
        self.pauseBtn.image = UIImage(named: "start")
        self.playBtn.image =  UIImage(named: "musicicon")
        self.invalidateAllFootStepTimers()
        self.invalidateAllAvatarTimer()
        self.invalidateAllVideoTimer()
        self.musicHelper.stop()
        self.footstepsFrameData = []
        self.counterLabel.removeFromSuperview()
        self.footPosition = SCNVector3()
        self.avatarPosition = SCNVector3()
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func resetMusicCounter(){
        self.englishValseMusicCounter = nil
        self.slowFoxMusicCounter = nil
        self.tangoMusicCounter = nil
        self.weinerValseMusicCounter = nil
        self.quickStepMusicCounter = nil
    }
    
    private func invalidateCounters(){
        if let evMusicTimer = self.englishValseMusicCounter {
            evMusicTimer.invalidateAllTimer()
        }
        if let slowFoxMusicCounter = self.slowFoxMusicCounter {
            slowFoxMusicCounter.invalidateAllTimer()
        }
        if let tangoMusicCounter = self.tangoMusicCounter {
            tangoMusicCounter.invalidateAllTimer()
        }
        if let weinerValseMusicCounter = self.weinerValseMusicCounter {
            weinerValseMusicCounter.invalidateAllTimer()
        }
        if let quickStepMusicCounter = self.quickStepMusicCounter {
            quickStepMusicCounter.invalidateAllTimer()
        }
    }
    
    private func setupMusicCounter(){
        guard let sceneHelper = self.sceneHelper else {
            return
        }
        
        if(sceneHelper.getDanceTypeDetails().name == AppModel.ENGLISH_VALSE){
            self.englishValseMusicCounter = EnglishValseMusicHelper(musicBeat: (sceneHelper.getMusic()?.beats)!,
                                                                    klausData: sceneHelper.getDanceSubChildDetailts().timeStamps , rate: Double(self.speedMove.value) * 100.0)
        } else if (sceneHelper.getDanceTypeDetails().name == AppModel.SLOWFOX) {
            self.slowFoxMusicCounter = SlowFoxCounterHelper(musicBeat: (sceneHelper.getMusic()?.beats)!, klausData: sceneHelper.getDanceSubChildDetailts().timeStamps, rate: Double(self.speedMove.value) * 100.0)
        } else if (sceneHelper.getDanceTypeDetails().name == AppModel.TANGE) {
            self.tangoMusicCounter = TangoCounterHelper(musicBeat: (sceneHelper.getMusic()?.beats)!, klausData: sceneHelper.getDanceSubChildDetailts().timeStamps, rate: Double(self.speedMove.value) * 100.0)
        } else if (sceneHelper.getDanceTypeDetails().name == AppModel.QUICKSTEP) {
            self.quickStepMusicCounter = QuickStepCounterHelper(musicBeat: (sceneHelper.getMusic()?.beats)!, klausData: sceneHelper.getDanceSubChildDetailts().timeStamps, rate: Double(self.speedMove.value) * 100.0)
        } else if (sceneHelper.getDanceTypeDetails().name == AppModel.WIENER_VALSE ) {
            self.weinerValseMusicCounter = WeinerValseMusicHelper(musicBeat: (sceneHelper.getMusic()?.beats)!,
                                                                    klausData: sceneHelper.getDanceSubChildDetailts().timeStamps , rate: Double(self.speedMove.value) * 100.0)
        }
    }
    
    private func playMusicCounter(status: Bool){
        if let englishValseMusicCounter =  self.englishValseMusicCounter {
            englishValseMusicCounter.isPlaying(status: status, time: Date().timeIntervalSinceNow)
        }
        if let slowFoxMusicCounter = self.slowFoxMusicCounter {
            slowFoxMusicCounter.isPlaying(status: status, time: Date().timeIntervalSinceNow)
        }
        if let weinerValseMusicCounter =  self.weinerValseMusicCounter {
            weinerValseMusicCounter.isPlaying(status: status, time: Date().timeIntervalSinceNow)
        }
        if let quickStepMusicCounter =  self.quickStepMusicCounter {
            quickStepMusicCounter.isPlaying(status: status, time: Date().timeIntervalSinceNow)
        }
        if let tangoMusicCounter =  self.tangoMusicCounter {
            tangoMusicCounter.isPlaying(status: status, time: Date().timeIntervalSinceNow)
        }
    }
    
    private func playMusicCounter(status: Bool, avatarSpeedAdjusted: Double){
        if let englishValseMusicCounter =  self.englishValseMusicCounter {
            englishValseMusicCounter.isPlaying(status: status, time: Date().timeIntervalSinceNow, speedAdjustmentByAvatar: avatarSpeedAdjusted)
        }
        if let slowFoxMusicCounter = self.slowFoxMusicCounter {
            slowFoxMusicCounter.isPlaying(status: status, time: Date().timeIntervalSinceNow, speedAdjustmentByAvatar: avatarSpeedAdjusted)
        }
        if let weinerValseMusicCounter =  self.weinerValseMusicCounter {
            weinerValseMusicCounter.isPlaying(status: status, time: Date().timeIntervalSinceNow, speedAdjustmentByAvatar: avatarSpeedAdjusted)
        }
        if let quickStepMusicCounter =  self.quickStepMusicCounter {
            quickStepMusicCounter.isPlaying(status: status, time: Date().timeIntervalSinceNow, speedAdjustmentByAvatar: avatarSpeedAdjusted)
        }
        if let tangoMusicCounter =  self.tangoMusicCounter {
            tangoMusicCounter.isPlaying(status: status, time: Date().timeIntervalSinceNow, speedAdjustmentByAvatar: avatarSpeedAdjusted)
        }
    }
    
    @objc func playModes(tapGestureRecognizer: UITapGestureRecognizer){
        if(isAvatarModeActive){
            if(!avatarAdded){
                return
            }
            
            if let sceneHelper = self.sceneHelper {
                if(!sceneHelper.getDanceSubDetailts().characterModel.validity){
                    return
                }
            }
            
            if(!modelAnimating){
                if(self.avatarAnimationData.isEmpty){
                    self.invalidateAllFootStepTimers()
                    self.invalidateAllVideoTimer()
                    self.resetKlausNode()
                    guard let sceneHelper = self.sceneHelper else {
                        return
                    }
                    if(sceneHelper.getBeatStartTime(speedRate: speedRate).count == 2){
                        self.playBtn.image = UIImage(named: "person_stop")
                        let beatForCounter = sceneHelper.getBeatStartTime(speedRate: speedRate)[1]
                        if let slectedMusic = sceneHelper.getMusic(){
                            if let instrumentMusic = slectedMusic.instrumentalFileName {
                                musicHelper.playBackgroundMusic(dance: slectedMusic.orignalFileName,
                                                                slowDance: instrumentMusic, rate: self.speedRate)
                            } else {
                                musicHelper.playBackgroundMusic(dance: slectedMusic.orignalFileName,
                                                                slowDance: nil, rate: self.speedRate)
                            }
                        }
                        for i in 0...beatForCounter.count - 1{
                            DispatchQueue.main.asyncAfter(deadline: .now() + beatForCounter[i]) {
                                if(i == 0){
                                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                    self.modelAnimating = true
                                }
                            }
                        }
                        let data = sceneHelper.getAvatarAnimationByBeatDefault(speedRate: self.speedRate * 100)
                        self.setupMusicCounter()
                        for i in 0...data.count - 1{
                            self.hideUIViewWhileAnimation(status: true)
                            self.avatarAnimationData.append(Timer.scheduledTimer(timeInterval: data[i][0],
                                                                                 target: self,
                                                                                 selector: #selector(self.avatarAnimation),
                                                                                 userInfo: ["duration": data[i][3],"speed":data[i][7], "totalDuration": data[i][4], "startPos": data[i][6]],
                                                                                 repeats: false))
                        }
                    }
                } else {
                    self.hideUIViewWhileAnimation(status: true)
                    self.playBtn.image = UIImage(named: "person_stop")
                }
                self.modelAnimating = true
                self.trainBtn.isUserInteractionEnabled = false
                self.playBtn.isUserInteractionEnabled = false
                self.pauseBtn.isUserInteractionEnabled = false
            } else {
                self.modelAnimating = false
                self.trainBtn.isUserInteractionEnabled = true
                self.pauseBtn.isUserInteractionEnabled = true
                self.playBtn.image = UIImage(named: "person_start")
            }
        } else {
            self.setupAnimationPlay()
        }
    }
    
    @objc func modelPlayBtnTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let sceneHelper = self.sceneHelper {
            if(!sceneHelper.getDanceSubDetailts().characterModel.validity){
                self.showAvatarMissingError()
                return
            }
        } else {
            return
        }
        isAvatarModeActive = true
        isFootModeActive = false
        self.avatarMode.image =  UIImage(named: "avatar_play_border")
        self.footstepMode.image =  UIImage(named: "foot_start")
        self.invalidateCounters()
        setupForBackForAvataar()
        self.showAvatarInstructions()
        if let klausNode = self.klausNode,
           let animationView = self.animationView{
            klausNode.isHidden = false
            animationView.isHidden = true
        }
    }
    
    @objc func footPlayBtnTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        isAvatarModeActive = false
        isFootModeActive = true
        self.avatarMode.image =  UIImage(named: "person_start")
        self.footstepMode.image =  UIImage(named: "steps_play_border")
        setupForBackForFoot()
        self.invalidateCounters()
        self.showFootstepsInstructions()
        if let klausNode = self.klausNode,
           let animationView = self.animationView{
            klausNode.isHidden = true
            animationView.isHidden = false
        }
    }
    
    @objc func settingBtnTap(tapGestureRecogizer: UITapGestureRecognizer){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        self.currentInstructionActiveDefault = true
               // Add actions to the menu
               let tour = UIAlertAction(title: "Take a Tour", style: .default) { _ in
                   self.currentInstructions = 0;
                   self.highlightIcon()
                   self.setupTour(header: "Instructions for Avatar",
                                  instruction: "Activate 3D Model Mode by Pressing Highlighted Icon")
                   self.currentInstructions = self.currentInstructions + 1
               }

               let about = UIAlertAction(title: "About Us", style: .cancel) { _ in
                   self.aboutTapped()
               }

               let logout = UIAlertAction(title: "Logout", style: .default) { _ in
                   self.logoutTapped()
               }

               // Add the actions to the alert controller
               alertController.addAction(tour)
               alertController.addAction(about)
               alertController.addAction(logout)

               // Present the alert controller

               present(alertController, animated: true, completion: nil)
           
    }
    
    private func takeTourTapped(){
        setupUI()
    }
    
    private func logoutTapped(){
        NetworkManager.logout(){ data in
            guard let logout = data else {
                return
            }
            if let username = FileHelper.getObjectFromUserDefaults(key: "USER") {
                FileHelper.emptyUserDefaults()
            }
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
            nextViewController.modalPresentationStyle = .fullScreen
            self.present(nextViewController, animated:true, completion:nil)
        }
    }
    
    private func setupTour(header: String, instruction: String){
        let alertController = UIAlertController(
                    title: header,
                    message: instruction,
                    preferredStyle: .alert
                )

        let nextAction = UIAlertAction(title: "Next", style: .default) { _ in
                    // Handle Next button tap
            if(!self.currentInstructionActiveDefault){
                self.currentInstructions = self.currentInstructions + 1
                self.currentInstructionActiveDefault = true
            } 
                switch(self.currentInstructions){
                    case 0:
                        self.setupTour(header: "Instructions for Avatar",
                                       instruction: "Press Highlighted Icon " + AppModel.AVATAR_INSTRUCTIONS)
                    self.highlightIcon()
                        self.currentInstructions = self.currentInstructions + 1
                        break;
                    case 1:
                        self.setupTour(header: "Instructions for FootSteps",
                                       instruction: "Press Highlighted Icon " + AppModel.FOOTSTEPS_INSTRUCTIONS)
                    self.highlightIcon()
                    self.currentInstructions = self.currentInstructions + 1
                        break;
                case 2:
                    self.setupTour(header: "Instructions for Video",
                                   instruction: "Press Highlighted Icon " + AppModel.VIDEO_INSTRUCTIONS)
                    self.highlightIcon()
                    self.currentInstructions = self.currentInstructions + 1
                    break;
                case 3:
                    self.setupTour(header: "Instructions for Forward-Backward",
                                   instruction: "Slider on the Left " + AppModel.FOR_BACK_INSTRUCTIONS)
                    self.highlightIcon()
                    self.currentInstructions = self.currentInstructions + 1
                    break;
                case 4:
                    self.setupTour(header: "Instructions for Speed Control",
                                   instruction: "Slider on the Bottom " + AppModel.SPEED_INSTRCUTIONS)
                    self.highlightIcon()
                    self.currentInstructions = self.currentInstructions + 1
                    break;
                case 5:
                    self.setupTour(header: "Instructions for Play",
                                   instruction: AppModel.PLAY_INSTRUCTIONS)
                    self.highlightIcon()
                    self.currentInstructions = self.currentInstructions + 1
                    break;
                case 6:
                    self.setupTour(header: "Instructions for Music",
                                   instruction: "Highlighted Music Icon on bottom " + AppModel.MUSIC_INSTRUCTIONS)
                    self.highlightIcon()
                    self.currentInstructions = self.currentInstructions + 1
                    break;
                case 7:
                    self.setupTour(header: "Gesture Instructions",
                                   instruction: AppModel.GESTURES_INSTRUCTIONS)
                    self.highlightIcon()
                    self.currentInstructions = self.currentInstructions + 1
                    break;
                case 8:
                    self.setupTour(header: "Final Remarks",
                                   instruction: AppModel.FINAL_INSTRUCTIONS)
                    self.highlightIcon()
                    self.currentInstructions = self.currentInstructions + 1
                    break;
                default:
                    self.highlightIcon()
                    break;
                }
                    print("Next button tapped")
                }

        let backAction = UIAlertAction(title: "Back", style: .default) { _ in
            // Handle Back button tap or simply dismiss the dialog
            if(self.currentInstructionActiveDefault){
                self.currentInstructions = self.currentInstructions - 2
                self.currentInstructionActiveDefault = false
            } else {
                self.currentInstructions = self.currentInstructions - 1
            }
            
            switch(self.currentInstructions){
            case 0:
                self.highlightIcon()
                self.setupTour(header: "Instructions for Avatar",
                               instruction: "Press Highlighted Icon " + AppModel.AVATAR_INSTRUCTIONS)
                break;
            case 1:
                self.highlightIcon()
                self.setupTour(header: "Instructions for FootSteps",
                               instruction: "Press Highlighted Icon " + AppModel.FOOTSTEPS_INSTRUCTIONS)
                break;
            case 2:
                self.highlightIcon()
                self.setupTour(header: "Instructions for Video",
                               instruction: "Press Highlighted Icon " + AppModel.VIDEO_INSTRUCTIONS)
                break;
            case 3:
                self.highlightIcon()
                self.setupTour(header: "Instructions for Forward-Backward",
                               instruction: "Slider on the Left " + AppModel.FOR_BACK_INSTRUCTIONS)
                break;
            case 4:
                self.highlightIcon()
                self.setupTour(header: "Instructions for Speed Control",
                               instruction: "Slider on the Bottom " + AppModel.SPEED_INSTRCUTIONS)
                break;
            case 5:
                self.highlightIcon()
                self.setupTour(header: "Instructions for Play",
                               instruction: AppModel.PLAY_INSTRUCTIONS)
                break;
            case 6:
                self.highlightIcon()
                self.setupTour(header: "Instructions for Music",
                               instruction: "Highlighted Music Icon on bottom " + AppModel.MUSIC_INSTRUCTIONS)
                break;
            case 7:
                self.highlightIcon()
                self.setupTour(header: "Gesture Instructions",
                               instruction: AppModel.GESTURES_INSTRUCTIONS)
                
                break;
            case 8:
                self.highlightIcon()
                self.setupTour(header: "Final Remarks",
                               instruction: AppModel.FINAL_INSTRUCTIONS)
                
                break;
            default:
                self.highlightIcon()
                break;
            }
        }

                // Add the actions to the alert controller
        alertController.addAction(backAction)
                alertController.addAction(nextAction)
              

                // Present the alert controller
                present(alertController, animated: true, completion: nil)
    }
    
    private func highlightIcon(){
        switch(self.currentInstructions){
        case 0:
            forbackMove.alpha = 0.3
            speedMove.alpha = 0.3
            youtubeBtnImage.alpha = 0.3
            avatarMode.alpha = 1.0
            footstepMode.alpha = 0.3
            playBtn.alpha = 0.3
            pauseBtn.alpha = 0.3
            speedIcon.alpha = 0.3
            forbackIcon.alpha = 0.3
            settingBtnImage.alpha = 0.3
            backBtn.alpha = 0.3
            speedStatus.alpha = 0.3
            break;
        case 1:
            forbackMove.alpha = 0.3
            speedMove.alpha = 0.3
            youtubeBtnImage.alpha = 0.3
            avatarMode.alpha = 0.3
            footstepMode.alpha = 1.0
            playBtn.alpha = 0.3
            pauseBtn.alpha = 0.3
            speedIcon.alpha = 0.3
            forbackIcon.alpha = 0.3
            settingBtnImage.alpha = 0.3
            backBtn.alpha = 0.3
            speedStatus.alpha = 0.3
            break;
        case 2:
            forbackMove.alpha = 0.3
            speedMove.alpha = 0.3
            youtubeBtnImage.alpha = 1.0
            avatarMode.alpha = 0.3
            footstepMode.alpha = 0.3
            playBtn.alpha = 0.3
            pauseBtn.alpha = 0.3
            speedIcon.alpha = 0.3
            forbackIcon.alpha = 0.3
            settingBtnImage.alpha = 0.3
            backBtn.alpha = 0.3
            speedStatus.alpha = 0.3
            break;
        case 3:
            forbackMove.alpha = 1.0
            speedMove.alpha = 0.3
            youtubeBtnImage.alpha = 0.3
            avatarMode.alpha = 0.3
            footstepMode.alpha = 0.3
            playBtn.alpha = 0.3
            pauseBtn.alpha = 0.3
            speedIcon.alpha = 0.3
            forbackIcon.alpha = 1.0
            settingBtnImage.alpha = 0.3
            backBtn.alpha = 0.3
            speedStatus.alpha = 0.3
            break;
        case 4:
            forbackMove.alpha = 0.3
            speedMove.alpha = 1.0
            youtubeBtnImage.alpha = 0.3
            avatarMode.alpha = 0.3
            footstepMode.alpha = 0.3
            playBtn.alpha = 0.3
            pauseBtn.alpha = 0.3
            speedIcon.alpha = 1.0
            forbackIcon.alpha = 0.3
            settingBtnImage.alpha = 0.3
            backBtn.alpha = 0.3
            speedStatus.alpha = 0.3
            break;
        case 5:
            forbackMove.alpha = 0.3
            speedMove.alpha = 0.3
            youtubeBtnImage.alpha = 0.3
            avatarMode.alpha = 0.3
            footstepMode.alpha = 0.3
            playBtn.alpha = 0.3
            pauseBtn.alpha = 1.0
            speedIcon.alpha = 0.3
            forbackIcon.alpha = 0.3
            settingBtnImage.alpha = 0.3
            backBtn.alpha = 0.3
            speedStatus.alpha = 0.3
            break;
        case 6:
            forbackMove.alpha = 0.3
            speedMove.alpha = 0.3
            youtubeBtnImage.alpha = 0.3
            avatarMode.alpha = 0.3
            footstepMode.alpha = 0.3
            playBtn.alpha = 1.0
            pauseBtn.alpha = 0.3
            speedIcon.alpha = 0.3
            forbackIcon.alpha = 0.3
            settingBtnImage.alpha = 0.3
            backBtn.alpha = 0.3
            speedStatus.alpha = 0.3
            break;
        default:
            forbackMove.alpha = 1.0
            speedMove.alpha = 1.0
            youtubeBtnImage.alpha = 1.0
            avatarMode.alpha = 1.0
            footstepMode.alpha = 1.0
            playBtn.alpha = 1.0
            pauseBtn.alpha = 1.0
            speedIcon.alpha = 1.0
            forbackIcon.alpha = 1.0
            settingBtnImage.alpha = 1.0
            backBtn.alpha = 1.0
            speedStatus.alpha = 1.0
            break;
        }
        
    }
    
    private func setupUI() {
            // Add the custom view to the main view
            view.addSubview(customView)

            // Add constraints for the custom view
            NSLayoutConstraint.activate([
                customView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                customView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                customView.heightAnchor.constraint(equalToConstant: 400),
                customView.widthAnchor.constraint(equalToConstant: 220)
            ])
        
            // Add the label to the custom view
            customView.addSubview(label)

            // Add constraints for the label
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: customView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: customView.centerYAnchor)
            ])

            // Add the "Next" button to the custom view
            customView.addSubview(nextButton)

            // Add constraints for the "Next" button
            NSLayoutConstraint.activate([
                nextButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
                nextButton.centerXAnchor.constraint(equalTo: customView.centerXAnchor)
            ])

            // Add the "Back" button to the custom view
            customView.addSubview(backButton)

            // Add constraints for the "Back" button
            NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 20),
                backButton.centerXAnchor.constraint(equalTo: customView.centerXAnchor)
            ])
    }
    
    @objc func nextButtonTapped() {
            print("Next button tapped")
            // Implement your logic for the "Next" button action
        }

        @objc func backButtonTapped() {
            print("Back button tapped")
            // Implement your logic for the "Back" button action
        }
    
    private func aboutTapped(){
        let aboutViewController = AboutController()
        aboutViewController.modalPresentationStyle = .popover
               present(aboutViewController, animated: true, completion: nil)
        
    }
    
    @objc func resetViewBtnTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.hideUIViewWhileAnimation(status: false)
        self.invalidateAllAvatarTimer()
        self.invalidateAllFootStepTimers()
        self.footAnimating = false
        self.modelAnimating = false
        self.speedMove.isEnabled = true
        self.trainBtn.isUserInteractionEnabled = true
        self.pauseBtn.isUserInteractionEnabled = true
        self.playBtn.isUserInteractionEnabled = true
        self.counterLabel.removeFromSuperview()
        if let task = self.task {
            task.cancel()
        }
        if let timer = self.timer {
            timer.invalidate()
        }
        if let animationView = self.animationView {
            animationView.currentFrame = 1
            self.pauseBtn.image = UIImage(named: "start")
            
        }
        if let klausNode = self.klausNode {
            self.playBtn.image = UIImage(named: "musicicon")
            klausNode.stopAnimation()
        }
    }
    
    private func resetKlausNode (){
        if let player = klausNode?.getAnimationPlayer(){
            player.play()
            player.animation.timeOffset = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                player.stop()
            }
        }
    }
    
    private func setupAnimationPlay(){
        if(!footAdded){
            return
        }
        
        guard let animationView = self.animationView,
              let sceneHelper = self.sceneHelper else {
            return
        }
        
        if(!footAnimating){
            if(self.footstepsAnimationData.isEmpty){
                self.invalidateAllAvatarTimer()
                self.invalidateAllVideoTimer()
                
                let data: [[Double]] = sceneHelper.resetAnimationWithSpeedChange(speedRate: Double(speedRate * 100))
                let rate = Double(speedRate)
                animationView.currentFrame = 1
                self.pauseBtn.image = UIImage(named: "start")
                self.counterLabel.text = "Ready"
                self.view.addSubview(counterLabel)
                self.view.bringSubviewToFront(counterLabel)
                if(sceneHelper.getBeatStartTime(speedRate: speedRate).count == 2){
                    let beatsFound = sceneHelper.getBeatStartTime(speedRate: speedRate)
                    let beatForCounter = beatsFound[1]
                    let beatForCounter1 = beatsFound[0]
                    var finalCounter: [Double] = []
                    let lastBeatOfFisrtBar = beatForCounter1.last
                    for i in 0...beatForCounter.count - 1{
                        if(i == 0){
                            finalCounter.append(lastBeatOfFisrtBar!)
                        } else if(i <= beatForCounter.count - 1){
                            finalCounter.append(beatForCounter[i-1])
                        }
                    }
                    if let slectedMusic = sceneHelper.getMusic(){
                        if let instrumentMusic = slectedMusic.instrumentalFileName {
                            musicHelper.playBackgroundMusic(dance: slectedMusic.orignalFileName,
                                                            slowDance: instrumentMusic,
                                                            rate: rate)
                        } else {
                            musicHelper.playBackgroundMusic(dance: slectedMusic.orignalFileName,
                                                            slowDance: nil,
                                                            rate: rate)
                        }
                    }
                    self.setupMusicCounter()
//                    for i in 0...finalCounter.count - 1{
//                        if(i == beatForCounter.count - 1){
//                            Timer.scheduledTimer(timeInterval: finalCounter[i],
//                                                 target: self, selector: #selector(self.beatInterval),
//                                                 userInfo: ["counter": i, "step": "last"] as [String : Any],
//                                                 repeats: false)
//                        } else {
//                            Timer.scheduledTimer(timeInterval: finalCounter[i],
//                                                 target: self, selector: #selector(self.beatInterval),
//                                                 userInfo: ["counter": i, "step": "dump"] as [String : Any],
//                                                 repeats: false)
//                        }
//                    }
                    
                    for item in 0...data.count - 1 {
                        var stepName: String = "Middle"
                        if(item == data.count-1){
                            stepName = "Last"
                        }
                        if (item == 0){
                            stepName = "First"
                            
                        }
                        self.hideUIViewWhileAnimation(status: true)
                        self.footstepsAnimationData.append(Timer.scheduledTimer(timeInterval: data[item][0],
                                                                                target: self,
                                                                                selector: #selector(self.footAnimateWithBeat),
                                                                                userInfo: ["fromFrame": 0.0,
                                                                                           "toFrame": data[item][2],
                                                                                           "duration": data[item][3],
                                                                                           "step": 11.2,
                                                                                           "step_name": stepName,
                                                                                           "startTime": data[item][0]] as [String : Any],
                                                                                repeats: false))
                    }
                    self.footAnimating = true
                }
            } else {
                DispatchQueue.main.async {
                    self.hideUIViewWhileAnimation(status: true)
                    self.pauseBtn.image = UIImage(named: "start")
                }
                self.settingsOpen = true
            }
            
            self.footAnimating = true
            self.speedMove.isEnabled = false
            self.trainBtn.isUserInteractionEnabled = false
            self.playBtn.isUserInteractionEnabled = false
        } else {
            self.pauseBtn.image = UIImage(named: "start")
            self.trainBtn.isUserInteractionEnabled = true
            self.playBtn.isUserInteractionEnabled = true
            self.footAnimating = false
            self.speedMove.isEnabled = true
            self.animationView?.pause()
            self.animationView?.currentTime = 0
        }
    }
    
    @objc func beatInterval(sender: Timer) {
        let timerData = sender.userInfo as! [String : Any]
        let step: String = timerData["step"]! as! String
        let counter: Int = timerData["counter"]! as! Int
        self.counterLabel.text = String(counter + 1)
        if(step == "last"){
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait // Set the desired orientation mode, in this case, portrait only
    }
    
    @objc func avatarAnimation(sender: Timer){
        let timerData = sender.userInfo as! [String : Any]
        let duration: Double = timerData["duration"]! as! Double
        let speed: Double = timerData["speed"]! as! Double
        self.avatarAnimationData.removeFirst()
        
        if(!modelAnimating){
            return
        }
        
        guard let klausNode = self.klausNode,
              let sceneHelper = self.sceneHelper else {
            self.speedMove.isEnabled = true
            self.trainBtn.isUserInteractionEnabled = true
            self.pauseBtn.isUserInteractionEnabled = true
            self.playBtn.isUserInteractionEnabled = true
            return
        }
        
        self.modelAnimating = false
        let timeNow: DispatchTime = .now()
        klausNode.pauseAnimation()
        klausNode.speedAnimation(speed: speed)
        
        let estimatedDuration: DispatchTime = timeNow + duration
        
        self.task = DispatchWorkItem { [weak self] in
            if let thisSelf = self {
                let disapearAction  = SCNAction.fadeOut(duration: 1)
                thisSelf.klausNode!.pauseAnimation()
                thisSelf.klausNode!.runAction(disapearAction, completionHandler: {
                    DispatchQueue.main.async{
                        thisSelf.hideUIViewWhileAnimation(status: false)
                        var pos = SCNVector3()
                        var angle = SCNVector3()
                        thisSelf.playBtn.image = UIImage(named: "musicicon")
                        thisSelf.sceneView.scene.rootNode.enumerateChildNodes {(node, step) in
                            if(node.name == "dancer" ||
                               node.name == "DANCER_HOLDER"){
                                pos = node.position
                                angle = node.eulerAngles
                                node.removeFromParentNode()
                                node.animationPlayer(forKey: (sceneHelper.animationKeyString))?.play()
                            }
                        }
                        let apearAction  = SCNAction.fadeIn(duration: 1)
                        thisSelf.klausNode! = sceneHelper.getModelFile()
                        thisSelf.klausNode!.opacity = 0
                        thisSelf.klausNode!.name = "dancer"
                        thisSelf.klausNode!.position = pos
                        thisSelf.klausNode!.eulerAngles = angle
                        thisSelf.klausNode!.scale = thisSelf.avatarScale
                        thisSelf.klausNode!.prepareForAnimation()
                        thisSelf.klausNode!.pauseAnimation()
                        thisSelf.klausNode!.speedAnimation(speed: 1.0)
                        thisSelf.sceneView.scene.rootNode.addChildNode(thisSelf.klausNode!)
                        thisSelf.klausNode!.runAction(apearAction, completionHandler: {
                            klausNode.opacity = 1
                        })
                        thisSelf.speedMove.isEnabled = true
                        thisSelf.trainBtn.isUserInteractionEnabled = true
                        thisSelf.pauseBtn.isUserInteractionEnabled = true
                        thisSelf.playBtn.isUserInteractionEnabled = true
                    }
                })
            }
        }
        
        if let task = self.task {
            DispatchQueue.main.asyncAfter(deadline: estimatedDuration,
                                          execute: task)
        }
        
        //let timeDialationForMusic = timeNow + (((40/60) / speed) / (speed / Double(self.speedMove.value)))
        let timeDialationForMusic = timeNow + ((40 / 60) / speed)
        print(timeDialationForMusic)
        DispatchQueue.main.asyncAfter(deadline: timeDialationForMusic) {
            self.playMusicCounter(status: true, avatarSpeedAdjusted: speed)
        }
       
        klausNode.playAnimation()
        self.sceneView.preferredFramesPerSecond = 60
        self.sceneView.rendersContinuously = true
        self.sceneView.scene.isPaused = false
        self.playBtn.image = UIImage(named: "musicicon")
        
    }
    
    @objc func footAnimateWithBeat(sender: Timer) {
        let timerData = sender.userInfo as! [String : Any]
        let fromFrame: Double = timerData["fromFrame"]! as! Double
        let toFrame: Double =  timerData["toFrame"]! as! Double
        let duration: Double = timerData["duration"]! as! Double
        let start_time = timerData["startTime"]! as! Double
        let stepName: String = timerData["step_name"]! as! String
        self.instructionSub?.isHidden = true
        self.instructionSub?.pause()
        self.animationView!.animationSpeed = duration
        self.footAnimationProgress = self.footAnimationProgress + 1
        //        self.animationView!.currentFrame = toFrame
        self.footstepsAnimationData.removeFirst()
        if(stepName == "First"){
            self.counterLabel.removeFromSuperview()
        }
        
        if(!self.footAnimating){
            if(stepName == "Last"){
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.hideUIViewWhileAnimation(status: false)
                    self.pauseBtn.image = UIImage(named: "start")
                    self.speedMove.isEnabled = true
                    self.footAnimationProgress = 0
                    self.invalidateAllFootStepTimers()
                    self.resetAnimationOnfinished(view: self.animationView!, status: true)
                }
            }
            return
        }
        
       
        print("animation: " + String(start_time))
        self.footAnimating = false
        self.playMusicCounter(status: true)
        self.animationView!.play(fromFrame: CGFloat(fromFrame), toFrame: CGFloat(toFrame), completion: {_ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.hideUIViewWhileAnimation(status: false)
                self.pauseBtn.image = UIImage(named: "start")
                self.speedMove.isEnabled = true
                self.trainBtn.isUserInteractionEnabled = true
                self.playBtn.isUserInteractionEnabled = true
                self.footAnimationProgress = 0
                self.resetAnimationOnfinished(view: self.animationView!, status: true)
            }
        })
       
    }
    
    private func hideUIViewWhileAnimation(status: Bool){
        UIView.animate(withDuration: 0.3, animations: {
            if(status){
                self.footSettings.alpha = 0
                self.menuHolder.alpha = 0
                self.backBtn.alpha = 0
                self.forbackMove.alpha = 0
                self.footstepMode.alpha = 0
                self.avatarMode.alpha = 0
                self.youtubeBtnImage.alpha = 0
            } else {
                self.footSettings.alpha = 1
                self.menuHolder.alpha = 1
                self.backBtn.alpha = 1
                self.forbackMove.alpha = 1
                self.footstepMode.alpha = 1
                self.avatarMode.alpha = 1
                self.youtubeBtnImage.alpha = 1
            }
        }) { (finished) in
            self.footSettings.isHidden = status
            self.menuHolder.isHidden = status
            self.backBtn.isHidden = status
            self.forbackMove.isHidden = status
            self.footstepMode.isHidden = status
            self.avatarMode.isHidden = status
            self.youtubeBtnImage.isHidden = status
        }
    }
    
    private func resetAnimationOnfinished(view: AnimationView, status: Bool){
        UIView.animate(withDuration: 0.3, animations: {
            if(status){
                view.alpha = 0
            } else {
                view.alpha = 1
            }
        }) { (finished) in
            if(status && finished){
                view.currentFrame = 0
            }
            if(!status && finished){
                return
            }
            self.resetAnimationOnfinished(view: view, status: false)
        }
    }
    
    private func visibilityUIView(view: UIView, status: Bool){
        UIView.animate(withDuration: 0.3, animations: {
            if(status){
                view.alpha = 0
            } else {
                view.alpha = 1
            }
        }) { (finished) in
            view.isHidden = status
            if(!status){
                self.footAnimating = true
            }
        }
    }
    
    private func invalidateStoppingTimers(){
        if(!self.footstepsAnimationData.isEmpty){
            for t in 0...self.footstepsAnimationData.count - 1 {
                footstepsAnimationData[t].invalidate()
                self.footstepsAnimationData.removeFirst()
                if(t == self.footAnimationProgress){
                    break;
                }
            }
        }
        musicHelper.audioPlayer?.pause()
    }
    
    private func invalidateAllFootStepTimers(){
        if(!self.footstepsAnimationData.isEmpty){
            for timer in self.footstepsAnimationData {
                timer.invalidate()
                self.footstepsAnimationData.removeFirst()
            }
        }
        
        if let timer = self.timer {
            timer.invalidate()
        }
        
        if let musicHelperAudio = musicHelper.audioPlayer {
            musicHelperAudio.pause()
        }
    }
    
    private func invalidateAllVideoTimer(){
        if(!self.videoData.isEmpty){
            for timer in self.videoData {
                timer.invalidate()
                self.videoData.removeFirst()
            }
        }
        
        if let timer = self.timer {
            timer.invalidate()
        }
        
        if let musicHelperAudio = musicHelper.audioPlayer {
            musicHelperAudio.pause()
        }
    }
    
    private func invalidateAllAvatarTimer(){
        if(!self.avatarAnimationData.isEmpty){
            for timer in self.avatarAnimationData {
                timer.invalidate()
                self.avatarAnimationData.removeFirst()
            }
        }
        
        if let musicHelperAudio = musicHelper.audioPlayer {
            musicHelperAudio.pause()
        }
    }
    
    @objc func trainBtnTapped(tapGestureRecognizer: UITapGestureRecognizer){
        self.resetEnviroment()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "klauscontroller") as! KlausTrainerController
        nextViewController.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(nextViewController, animated:true, completion:nil)
        }
//           if let userInfo = FileHelper.getObjectFromUserDefaults(key: "USER"){
               
//            animationView.currentFrame = 1
//            self.invalidateAllAvatarTimer()
//            self.invalidateAllFootStepTimers()
//            self.footstepsFrameData = Array(screenHelper.getFootStepsAnimationsFrames())
//            self.timer = Timer.scheduledTimer(timeInterval: 2.0,
//                                              target: self,
//                                              selector: #selector(timerFired),
//                                              userInfo: nil,
//                                              repeats: true)
 //       }
//        if(!trainMode){
//            invalidateAllFootStepTimers()
//            // Prepare the Popup for the Instructions
//            let alertMessage = """
//                • Hold Phone in UP direction to follow 3Dmodel
//                • Hold Phone in DOWN direction to follow FootSteps
//                • See the count 1-3
//                • On Phone Vibrate Start the move to evaluate
//                """
//            let paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle.alignment = NSTextAlignment.left
//
//            let attributedMessageText = NSMutableAttributedString(
//                string: alertMessage,
//                attributes: [
//                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
//                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13.0)
//                ]
//            )
//            let refreshAlert = UIAlertController(title: "Instructions for Training", message: alertMessage, preferredStyle: UIAlertController.Style.alert)
//            refreshAlert.setValue(attributedMessageText, forKey: "attributedMessage")
//            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
//                print("Handle Ok logic here")
//                self.prepareTrainingProcess()
//                refreshAlert.dismiss(animated: true)
//            }))
//
//            present(refreshAlert, animated: true, completion: nil)
//            trainMode = true
//            animationView!.currentProgress = 0
//            trainBtn.backgroundColor =  UIColor(white: 1, alpha: 0.3)
//            self.pauseBtn.isUserInteractionEnabled = false
//            self.playBtn.isUserInteractionEnabled = false
//        }
    }
    
    private func prepareTrainingProcess(){
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 150))
        label.center = self.view.center
        label.textAlignment = .center
        label.text = "Ready"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 100.0)
        //        label.center = self.view.center
        self.view.addSubview(label)
        self.view.bringSubviewToFront(label)
        if(sceneHelper?.getBeatStartTime(speedRate: speedRate).count == 2){
            let beatForCounter = sceneHelper?.getBeatStartTime(speedRate: speedRate)[0]
            //            let realStartAnimation = sceneHelper?.getBeatStartTime()[1]
            if let slectedMusic = self.sceneHelper?.getMusic(){
                if let instrumentMusic = slectedMusic.instrumentalFileName {
                    musicHelper.playBackgroundMusic(dance: slectedMusic.orignalFileName,
                                                    slowDance: instrumentMusic, rate: 1.0)
                } else {
                    musicHelper.playBackgroundMusic(dance: slectedMusic.orignalFileName,
                                                    slowDance: nil, rate: 1.0)
                }
            }
            for i in 0...beatForCounter!.count - 1{
                DispatchQueue.main.asyncAfter(deadline: .now() + beatForCounter![i]) {
                    label.text = String(i+1)
                    if(i == beatForCounter!.count - 1){
                        label.removeFromSuperview()
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.prepareModeForTraining()
                        
                    }
                }
            }
        }
    }
    
    private func prepareModeForTraining(){
        var sensorReadings: [[Double]] = []
        self.motionManager.deviceMotionUpdateInterval = 1.0/60.0
        self.motionManager.startDeviceMotionUpdates(to: OperationQueue.current!){(motionData, error) in
            if (motionData != nil) {
                let data = motionData!
                print("Adjustment")
                let referenceFrame = simd_inverse(simd_quatd(ix: 0,iy: 0,iz: 0,r: 1))
                let userAcc = data.userAcceleration.toSIMD
                let adjusted = simd_act(simd_mul(referenceFrame, data.attitude.quaternion.toSIMD), userAcc)
                var accelX = 0.0
                var accelY = 0.0
                var accelZ = 0.0
                let gyroX = data.rotationRate.x;
                let gyroY = data.rotationRate.y;
                let gyroZ = data.rotationRate.z;
                let roll = data.attitude.roll
                let pitch = data.attitude.pitch
                let yaw = data.attitude.yaw
                let gravity = data.gravity
                accelX = adjusted[0];
                accelY = adjusted[1];
                accelZ = adjusted[2];
                let acceleronometerData = [accelX, accelY, accelZ, gyroX, gyroY, gyroZ, roll, pitch, yaw, gravity.x, gravity.y, gravity.z];
                sensorReadings.append(acceleronometerData)
            } else {
                print("skipped The Training Process")
            }
        }
        if UIDevice.current.orientation.isFlat {
            print("downwards")
            self.animationView!.loopMode = .playOnce
            self.animationView!.play(completion: {_ in
                self.motionManager.stopDeviceMotionUpdates()
                self.trainMode = false
                self.pauseBtn.isUserInteractionEnabled = true
                self.playBtn.isUserInteractionEnabled = true
                self.machineLearningResponse(sensorRecordings: sensorReadings)
            })
            
        } else {
            print("upwards")
            if(!self.modelAnimating){
                self.modelAnimating = true
                self.sceneView.scene.isPaused = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.motionManager.stopDeviceMotionUpdates()
                    self.trainMode = false
                    self.sceneView.scene.isPaused = true
                    self.modelAnimating = false
                    self.pauseBtn.isUserInteractionEnabled = true
                    self.playBtn.isUserInteractionEnabled = true
                    self.machineLearningResponse(sensorRecordings: sensorReadings)
                }
            }
        }
    }
    
    private func machineLearningResponse(sensorRecordings: [[Double]]){
        let resultAlert = UIAlertController(title: "Results Dialog", message: "Checking Results...", preferredStyle: .alert)
        self.present(resultAlert, animated: true, completion: nil)
        NetworkManager.predictDanceMove(danceTypeName: (self.sceneHelper?.getDanceTypeDetails().name)!, danceMoveName: (self.sceneHelper?.getDanceSubDetailts().name)!, direction: (self.sceneHelper?.getDanceSubDetailts().direction)!, data: sensorRecordings) { (data: PredictionModelResponse?) in
            if let result = data {
                resultAlert.message = result.data
                for label in result.labels{
                    let labelAction = UIAlertAction(title: label, style: .default) { (action:UIAlertAction!) in
                        // Code in this block will trigger when OK button tapped.
                        print("Incorrect button tapped");
                        NetworkManager.predictDanceMoveFeedback(hash: result.hash, feedback: label) { (data: FeedBackResponseModel?) in
                            if let feedback = data {
                                print(feedback.data)
                                resultAlert.dismiss(animated: true)
                            } else {
                                resultAlert.dismiss(animated: true)
                            }
                            self.musicHelper.stop()
                        }
                    }
                    resultAlert.addAction(labelAction)
                }
            } else {
                resultAlert.message = "Something Wrong"
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    resultAlert.dismiss(animated: true)
                }
            }
        }
    }
    
    @objc func avatarZoomIntapped(tapGestureRecognizer: UITapGestureRecognizer){
        scaleObject(scaleVal: 0.001, nodeType: "dancer", mode: "ZoomIn")
    }
    
    @objc func avatarZoomOuttapped(tapGestureRecognizer: UITapGestureRecognizer){
        scaleObject(scaleVal: 0.001, nodeType: "dancer", mode: "ZoomOut")
    }
    
    @objc func stepZoomIntapped(tapGestureRecognizer: UITapGestureRecognizer){
        scaleObject(scaleVal: 0.1, nodeType: "foot" , mode: "ZoomIn")
    }
    
    @objc func stepZoomOuttapped(tapGestureRecognizer: UITapGestureRecognizer){
        scaleObject(scaleVal: 0.1, nodeType: "foot", mode: "ZoomOut")
    }
    
    @objc func rotateNodeWithPanGesture(gesture: UIPanGestureRecognizer){
        if(!self.avatarAdded || gesture.state == .ended){
            return
        }
        
        let translation = gesture.translation(in: gesture.view)
        var newAngleY = (Float)(translation.x / 50)*(Float)(Double.pi)/360
        print(translation.x)
        newAngleY += self.klausNode!.eulerAngles.y
        self.klausNode!.eulerAngles.y = newAngleY
    }
    
    @objc func rotateNodeGesture(gesture: UIRotationGestureRecognizer){
        if(!self.avatarAdded){
            return
        }
        
        if gesture.state == .began || gesture.state == .changed {
            var newAngleY = Float(gesture.rotation) / 20
            newAngleY += self.klausNode!.eulerAngles.y
            self.klausNode!.eulerAngles.y = newAngleY
        }
    }
    
    private func setBtnClick(type: String) {
        if(type == "AVATAR"){
            dancerBtnImage.backgroundColor =  UIColor(white: 1, alpha: 0.3)
            youtubeBtnImage.backgroundColor = .none
            settingBtnImage.backgroundColor = .none
            musicBtnImage.backgroundColor = .none
        } else if (type == "FOOT"){
            youtubeBtnImage.backgroundColor = .none
            settingBtnImage.backgroundColor = .none
            musicBtnImage.backgroundColor = .none
            dancerBtnImage.backgroundColor = .none
        }
    }
    
    // new version update
    private func startLocatingPlaceForModel(){
        self.sceneType = "AVATAR"
        self.klausNode = self.sceneHelper?.getModelData()
        self.animationView = self.sceneHelper?.getFootAnimation()
        self.loadAnimation()
        self.avatarPosition = nil
        self.settingBtnImage.isHidden = true
        self.backBtn.isHidden = false
        view.bringSubviewToFront(backBtn)
        self.animationViewInstructions?.isHidden = false
        self.animationViewInstructions?.play()
        
    }
    
    private func startLocatingPlaceForFoot(){
        sceneType = "FOOT"
        footPosition = nil
    }
    
    private func footTapped() {
        setBtnClick(type: "FOOT")
        actionType = "FOOT"
        isFootDummyAdded = true
        trainMode = false
        trainBtn.isHidden = false
        footSettings.isHidden = true
        menuHolder.isHidden = true
        backBtn.isHidden = false
        footAdded = true
        animationViewInstructions?.isHidden = false
        animationViewTemplate?.isHidden = true
        animationViewInstructions?.play()
        sceneType = "FOOT"
        footSettings.isHidden = false
    }
    
    private func showVideoError(){
        let alertMessage = """
                • Cannot Find Video
                """
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.left

            let attributedMessageText = NSMutableAttributedString(
                string: alertMessage,
                attributes: [
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                   NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13.0)
                ]
            )
         let refreshAlert = UIAlertController(title: "Video Error", message: alertMessage, preferredStyle: UIAlertController.Style.alert)
            refreshAlert.setValue(attributedMessageText, forKey: "attributedMessage")
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                refreshAlert.dismiss(animated: true)
            }))

         present(refreshAlert, animated: true, completion: nil)
    }
    
    @objc func musicBtnTapped(sender: UITapGestureRecognizer) {
        let musicChooser = UIAlertController(title: "Musics", message: "Select Music", preferredStyle: .alert)
        if let sceneHelper = self.sceneHelper {
            for label in sceneHelper.getDanceTypeDetails().musics{
                let labelAction = UIAlertAction(title: label.fileName, style: .default) { (action:UIAlertAction!) in
                    sceneHelper.resetMusic(id: label.id)
                    self.invalidateAllAvatarTimer()
                    self.invalidateAllFootStepTimers()
                    self.musicHelper.audioPlayer?.pause()
                    self.setupAnimationPlay()
                }
                musicChooser.addAction(labelAction)
            }
        } else {
            musicChooser.message = "No Musics"
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                musicChooser.dismiss(animated: true)
            }
        }
        self.present(musicChooser, animated: true, completion: nil)
    }
    
    @objc func videoBtnTapped(sender: UITapGestureRecognizer) {
        if let sceneHelper = self.sceneHelper {
            if(!sceneHelper.getDanceSubDetailts().video.validity){
                self.showVideoError()
                return
            }
            if(!FileHelper.fileExistsInDownloadsDirectory(filename: sceneHelper.getDanceSubDetailts().video.filename)){
                self.showVideoError()
                return
            }
        } else {
            self.showVideoError()
            return
        }
        self.invalidateAllFootStepTimers()
        self.invalidateAllAvatarTimer()
        guard let sceneHelper = self.sceneHelper else {
            return
        }
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "custom_video") as! CustomVideoController
        nextViewController.setVideoInformation(video: sceneHelper.getDanceSubDetailts().video.filename,
                                               sceneHelper: sceneHelper)
        DispatchQueue.main.async {
            self.present(nextViewController, animated:true, completion:nil)
        }
    }
    
    @IBAction func onSlide(_ sender: Any) {
        guard let animationView = self.animationView else {
            return
        }
        self.invalidateAllFootStepTimers()
        self.invalidateAllAvatarTimer()
        animationView.pause()
        animationView.currentFrame = 1
        let roundedValue = roundf(speedMove.value / 0.1) * 0.1;
        animationView.animationSpeed = CGFloat(roundedValue)
        self.musicHelper.setRate(rate: roundedValue)
        self.speedMove.value = roundedValue
        self.speedRate = Double(roundedValue)
        self.speedStatus.text = String(format: "%.0f", (speedRate * 100) - 100) + " % "
        print(roundedValue)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if let currentFrame = session.currentFrame {
            let cameraZ = currentFrame.camera.transform.columns.3.z
            let cameraX = currentFrame.camera.transform.columns.3.x
            cameraAngle = SCNVector3(currentFrame.camera.eulerAngles.x,
                                     currentFrame.camera.eulerAngles.y,
                                     currentFrame.camera.eulerAngles.z)
            for node in sceneView.scene.rootNode.childNodes{
                DispatchQueue.main.async {
                    if(node.name == AppModel.FOOTSTEP_NODE_NAME && self.settingsOpen){
                        self.settingsOpen = false
                        let distanceY = abs(cameraZ - node.position.z)
                        let distanceX = abs(cameraX - node.position.x)
                        let boundingBoxX = AppModel.BOUNDING_BOX_PARAM + (node.boundingBox.max.x - node.boundingBox.min.x)
                        let boundingBoxY = AppModel.BOUNDING_BOX_PARAM + (node.boundingBox.max.y - node.boundingBox.min.y)
                        if(distanceY < boundingBoxY && distanceX < boundingBoxX){
                            return
                        } else {
                            self.boundingboxAlert = UIAlertController(title: "Bounding Box Alert", message: "Alert", preferredStyle: .alert)
                            let resurfaceAction = UIAlertAction(title: "Re-Surface", style: .default) { (action:UIAlertAction!) in
                                //                                        guard let pointOfView = self.sceneView.pointOfView else { return }
                                //                                        let transform = pointOfView.transform // transformation matrix
                                //                                        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33) // camera rotation
                                //                                        let location = SCNVector3(transform.m41, transform.m42, transform.m43) // camera translation
                                //
                                //                                        var currentPostionOfCamera = orientation + location
                                //                                        currentPostionOfCamera.y = node.position.y
                                //                                        node.position = currentPostionOfCamera
                                //                                        node.eulerAngles.y = currentFrame.camera.eulerAngles.y
                                self.isAlertPresented = false
                                self.boundingboxAlert.dismiss(animated: true)
                                if(self.sceneHelper?.getDanceSubDetailts().direction == "backward"){
                                    //                                            node.position.x = currentFrame.camera.transform.columns.3.x
                                    //                                            node.position.z = currentFrame.camera.transform.columns.3.z
                                    //                                            node.position.y = node.position.y
                                    //
                                    //                                            print(node.position.z)
                                    //                                            print((node.boundingBox.max.y - node.boundingBox.min.y) / 2)
                                    //                                    node.position.x = node.boundingBox.min.x - (node.boundingBox.min.x / 2)
                                }
                            }
                            //                                    let resurfaceIgnoreAction = UIAlertAction(title: "Ignore", style: .default) { (action:UIAlertAction!) in
                            //                                        return
                            //                                    }
                            self.boundingboxAlert.addAction(resurfaceAction)
                            //                                    self.boundingboxAlert.addAction(resurfaceIgnoreAction)
                            self.present(self.boundingboxAlert, animated: true, completion: nil)
                            self.isAlertPresented = true
                        }
                    } else {
                        if(self.isAlertPresented && node.name == AppModel.FOOTSTEP_NODE_NAME){
                            guard let pointOfView = self.sceneView.pointOfView else { return }
                            let transform = pointOfView.transform // transformation matrix
                            let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33) // camera rotation
                            let location = SCNVector3(transform.m41, transform.m42, transform.m43) // camera translation
                            
                            var currentPostionOfCamera = orientation + location
                            currentPostionOfCamera.y = node.position.y
                            node.position = currentPostionOfCamera
                            node.eulerAngles.y = currentFrame.camera.eulerAngles.y
                            //                            self.boundingboxAlert.dismiss(animated: true)
                        }
                    }
                }
                if(node.name == AppModel.DANCER_NODE_NAME){
                    let distance = abs(cameraZ - node.position.z)
                    if(distance < 1.2){
                        if(!self.isAlertPresented){
                            self.alert.message = "Please Hold Back"
                            //                            self.present(alert, animated: true)
                            //                            self.isAlertPresented = true
                        }
                    } else {
                        if(self.isAlertPresented){
                            //                            self.alert.dismiss(animated: true) {
                            //                            self.isAlertPresented = false
                            //                            }
                        }
                    }
                    
                } else if (node.name == "DANCER_HOLDER" && !self.avatarAdded){
                    let distance = abs(cameraZ - node.position.z)
                    // 2.5
                    if(distance < 0.2){
                        self.isAvatartClose = true
                    } else {
                        self.isAvatartClose = false
                        if(!self.footAdded){
                            //                            self.footTapped()
                            self.footAdded = true
                            self.instrcutionMainAnimationView?.isHidden = true
                            //                            self.footTapped()
                            self.placeFoot(x:cameraX, y:self.avatarPosition!.y, z:cameraZ)
                            print("saads")
                        }
                    }
                } else if(node.name == "FOOT_HOLDER"){
                    //                    node.position.x = cameraX
                    //                    node.position.z = cameraZ
                }
            }
        }
    }
    
    // This function Creates and Display the Menu
    private func showMenu(){
        self.mainTableItems.isHidden = false
        self.view.bringSubviewToFront(self.mainTableItems)
        let storageHelper = StoreageHelper()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backMenuTapped(tapGestureRecognizer:)))
        self.menuBackBtn.isUserInteractionEnabled = true
        self.menuBackBtn.addGestureRecognizer(tapGestureRecognizer)
        self.menuHeading.backgroundColor = .white
        self.menuHeading.textAlignment = .center
        self.menuBackBtn.isHidden = true
        self.menuHeading.text = "Select Dance"
        self.dancesDataSource = MyData(classes: storageHelper.getDanceTypes()) { (result) -> () in
            // do stuff with the result
            self.menuHeading.text = "Select Dance Move"
            self.menuBackBtn.isHidden = false
            self.danceMovesByDanceDataSource = DanceSubMovesAdapter(classes: storageHelper.getDances(danceTypeID: result), tapItem: {
                self.menuHeading.text = "Select Male Or Female Move"
            }){ [self] (id, hash, subHash)->() in
                self.danceSubMove = hash
                let danceMoveHelper = DanceMoveHelper(id: id, hash: hash){(status, data) in
                    if let danceMoveData = data {
                        DispatchQueue.main.async {
                            self.sceneHelper = SceneScenarioHelper(danceName: self.danceMove! ,moveName: danceMoveData.hash, subHash: subHash)
                            self.klausNode = self.sceneHelper?.getModelData()
                            self.animationView = self.sceneHelper?.getFootAnimation()
                            self.footstepsFrameData = Array((self.sceneHelper?.getFootStepsAnimationsFrames())!)
                            self.setupForBackForAvataar()
                            let animationWidth = self.animationView?.frame.width ?? 0.0
                            let animationHeight = self.animationView?.frame.height ?? 0.0
                            var animationOffSetX = self.sceneHelper?.getDanceSubDetailts().footStepAnimation.offSetX ?? 0.0
                            var animationOffSetY = self.sceneHelper?.getDanceSubDetailts().footStepAnimation.offSetY ?? 0.0
                            let resultantIncrease = abs(animationOffSetX) > abs(animationOffSetY) ? abs(animationOffSetX) : abs(animationOffSetY)
                            if(animationOffSetX <= 1.0){
                                animationOffSetX = 0.0
                            } else {
                                animationOffSetX = animationOffSetX + (resultantIncrease / 2)
                            }
                            if(animationOffSetY <= 1.0){
                                animationOffSetY = 0.0
                            } else {
                                animationOffSetY = animationOffSetY + (resultantIncrease / 2)
                            }
                            self.animationHolderView.frame = CGRect(x: 0.0, y: 0.0,
                                                                    width: animationWidth, height: animationHeight)
                            
                            self.loadAnimation()
                            self.menuHolder.isHidden = true
                            self.destroyAlert()
                        }
                    } else {
                        self.destroyAlertWhenFail()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.presentAlert(title: "Sync Failed")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.destroyAlertWhenFail()
                            }
                        }
                    }
                }
                
                presentAlert(title: "Preparing View")
                danceMoveHelper.checkForUpdate()
            }
            
            self.mainTableItems.dataSource = self.danceMovesByDanceDataSource
            self.mainTableItems.delegate = self.danceMovesByDanceDataSource
            self.mainTableItems.register(UINib(nibName: "CustomSubDanceTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
            self.mainTableItems.reloadData()
            self.danceMove = result
            print(result)
        }
        mainTableItems.dataSource = self.dancesDataSource
        mainTableItems.delegate = self.dancesDataSource
        self.mainTableItems.reloadData()
        mainTableItems.backgroundColor = UIColor(white: 1, alpha: 0.5)
        //        menuUiView.addSubview(backBt)
    }
    
    private func initateAR(){
        startLocatingPlaceForModel()
        let configuration = ARWorldTrackingConfiguration()
        if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
            configuration.detectionImages = referenceImages
        }
        
        configuration.maximumNumberOfTrackedImages = 1
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration, options: [])
    }
    
    @objc func backMenuTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.showMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.session.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
        self.invalidateAllAvatarTimer()
        self.invalidateAllFootStepTimers()
        self.invalidateStoppingTimers()
        self.modelAnimating = false
        self.footAnimating = false
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func placeFoot(x: Float, y: Float, z:Float){
        //        let footImage = UIImageView(image: UIImage(named: "art.scnassets/image_1.png"))
        self.animationViewInstructions?.isHidden = true
        self.animationViewInstructions?.pause()
        let footPlaceHolder =  SCNNode(geometry: SCNPlane(width: 1, height: 1))
        footPlaceHolder.name = "FOOT_HOLDER"
        footPlaceHolder.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        footPlaceHolder.eulerAngles.x = -.pi/2
        footPlaceHolder.eulerAngles.y = 0.0
        footPlaceHolder.position = SCNVector3(x,y,z)
        footPlaceHolder.eulerAngles = SCNVector3Make(-.pi/2, cameraAngle.y, 0);
        footPlaceHolder.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
        self.sceneView.scene.rootNode.addChildNode(footPlaceHolder)
        self.sceneType = "DEFAULT"
        self.instructionSub?.isHidden = true
        self.instructionSub?.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.instructionSub?.isHidden = true
            self.instructionSub?.pause()
            if(self.sceneHelper?.getDanceSubDetailts().direction == "backward"){
                self.showAleart()
            } else {
                self.placeObjects()
            }
        }
    }
    
    func placeObjects(){
        DispatchQueue.main.async {
            self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                if(node.name == "DANCER_HOLDER"){
                    print(node.position)
                    self.avatarPosition = node.position
                    node.removeFromParentNode()
                } else if (node.name == "FOOT_HOLDER"){
                    self.footPosition = node.position
                    self.footPosition!.z = self.footPosition!.z - 0.1
                    self.footPosition!.x = self.footPosition!.x - 0.0
                    node.removeFromParentNode()
                }
            }
            
            
            // foot
            self.footPlaceHolder = SCNNode(geometry: SCNPlane(width: 1, height: 1))
            self.footPlaceHolder.name = "foot"
            let width = self.animationView?.frame.width ?? 0.0
            let scale = self.sceneHelper?.getScallingForFootSteps(val: width)
            self.footScale = SCNVector3(x: Float(scale!), y: Float(scale!), z: Float(scale!))
            self.footPlaceHolder.scale = self.footScale
            self.footPlaceHolder.eulerAngles = SCNVector3Make(-.pi/2, self.cameraAngle.y, 0);
            //            self.animationView!.isHidden = true
            self.animationHolderView.isHidden = true
            self.animationView!.translatesAutoresizingMaskIntoConstraints = false
            self.animationView!.isHidden = true
            self.footPlaceHolder.position = self.footPosition!
            self.footPlaceHolder.geometry?.firstMaterial?.diffuse.contents = self.animationHolderView.layer
            self.sceneView.scene.rootNode.addChildNode(self.footPlaceHolder)
            
            self.klausNode!.name = "dancer"
            self.avatarPosition!.z = self.avatarPosition!.z + self.footPlaceHolder.boundingBox.min.y + (self.footPlaceHolder.boundingBox.min.y)
            self.klausNode!.position = self.avatarPosition!
            self.klausNode!.eulerAngles = SCNVector3Make(0, -((3 * .pi)/2), 0);
            self.klausNode!.scale = self.avatarScale
            self.sceneView.scene.rootNode.addChildNode(self.klausNode!)
            self.klausNode!.prepareForAnimation()
            if let sceneHelper = self.sceneHelper {
                if(!sceneHelper.getDanceSubDetailts().characterModel.validity){
                    self.klausNode!.isHidden = true
                    self.avatarMode.image = UIImage(named: "avatar_none")
                } else {
                    self.klausNode!.isHidden = false
                    self.avatarMode.image =  UIImage(named: "avatar_play_border")
                }
                if(!sceneHelper.getDanceSubDetailts().video.validity){
                    self.youtubeBtnImage.image = UIImage(named: "video_none")
                } else {
                    self.youtubeBtnImage.image = UIImage(named: "yticon")
                }
            } else {
                self.avatarMode.image = UIImage(named: "avatar_none")
                self.youtubeBtnImage.image = UIImage(named: "yticon")
                self.klausNode!.isHidden = true
            }
            self.sceneView.scene.isPaused = true
            print(self.footPlaceHolder.boundingBox)
            
            //                self.view.sendSubviewToBack(self.touchPlace)
            
            self.footSettings.isHidden = false
            self.forbackMove.isHidden = false
            self.menuHolder.isHidden = false
            self.resetView.isHidden = false
            self.resetViewBtn.isHidden = false
            self.avatarMode.isHidden = false
            self.footstepMode.isHidden = false
            self.avatarMode.isHidden = false
            self.youtubeBtnImage.isHidden = false
            self.footAdded = true
            self.avatarAdded = true
            
            self.view.bringSubviewToFront(self.resetView)
            self.view.bringSubviewToFront(self.footSettings)
            self.view.bringSubviewToFront(self.backBtn)
            self.view.bringSubviewToFront(self.avatarMode)
            self.view.bringSubviewToFront(self.footstepMode)
            self.view.bringSubviewToFront(self.youtubeBtnImage)
            self.view.bringSubviewToFront(self.menuHolder)
            self.view.bringSubviewToFront(self.gesturesHolder)
            // self.checkDeviceOrientation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                UIView.animate(withDuration: 1) {
                    //                    self.animationView!.isHidden = false
                    self.animationHolderView.isHidden = false
                }
            }
            
            self.footstepMode.image =  UIImage(named: "foot_start")
            self.footstepMode.alpha = 1
            self.avatarMode.alpha = 1
            self.youtubeBtnImage.alpha = 1
            self.setupMlModel()
            self.isImageTrackingEnabled = true
        }
    }
    
    private func showAvatarMissingError(){
        let alertMessage = """
                • Cannot Find Avatar
                """
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.left

            let attributedMessageText = NSMutableAttributedString(
                string: alertMessage,
                attributes: [
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                   NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13.0)
                ]
            )
         let refreshAlert = UIAlertController(title: "Message for Avatar", message: alertMessage, preferredStyle: UIAlertController.Style.alert)
            refreshAlert.setValue(attributedMessageText, forKey: "attributedMessage")
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
                refreshAlert.dismiss(animated: true)
            }))

         present(refreshAlert, animated: true, completion: nil)
    }
    
    private func showAvatarInstructions(){
        let alertMessage = """
                • Swipe to rotate the avatar
                • Pinch to adjust avatar size
                • Tap Play btn to start avatar
                """
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.left

            let attributedMessageText = NSMutableAttributedString(
                string: alertMessage,
                attributes: [
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                   NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13.0)
                ]
            )
         let refreshAlert = UIAlertController(title: "Instructions for Avatar", message: alertMessage, preferredStyle: UIAlertController.Style.alert)
            refreshAlert.setValue(attributedMessageText, forKey: "attributedMessage")
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
                refreshAlert.dismiss(animated: true)
            }))

         present(refreshAlert, animated: true, completion: nil)
    }
    
    private func showFootstepsInstructions(){
                let alertMessage = """
                        • Pinch to adjust footsteps size
                        • Tap Play btn to start footsteps
                        """
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = NSTextAlignment.left
        
                    let attributedMessageText = NSMutableAttributedString(
                        string: alertMessage,
                        attributes: [
                            NSAttributedString.Key.paragraphStyle: paragraphStyle,
                           NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13.0)
                        ]
                    )
                 let refreshAlert = UIAlertController(title: "Instructions for Footsteps", message: alertMessage, preferredStyle: UIAlertController.Style.alert)
                    refreshAlert.setValue(attributedMessageText, forKey: "attributedMessage")
                    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        print("Handle Ok logic here")
                        refreshAlert.dismiss(animated: true)
                    }))
        
                 present(refreshAlert, animated: true, completion: nil)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor  {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
        let planeAnchor = anchor
        let x = planeAnchor.transform.columns.3.x
        let y = planeAnchor.transform.columns.3.y
        let z = planeAnchor.transform.columns.3.z
        //        guard let pointOfView = sceneView.pointOfView else { return }
        //        let transform = pointOfView.transform // transformation matrix
        //        var location = SCNVector3(-transform.m31 + transform.m41, y, -transform.m33 + transform.m43)
        var location = SCNVector3(x,y,z)
        let locationSite = SCNVector3(x, y, z)
        if(sceneType == "FOOT"){
            DispatchQueue.main.async {
                let footImage = UIImageView(image: UIImage(named: "art.scnassets/image_1.png"))
                self.animationViewInstructions?.isHidden = true
                self.animationViewInstructions?.pause()
                self.footPosition = location
                let footPlaceHolder =  SCNNode(geometry: SCNPlane(width: 1, height: 1))
                footPlaceHolder.name = "FOOT_HOLDER"
                footPlaceHolder.geometry?.firstMaterial?.diffuse.contents = footImage
                footPlaceHolder.eulerAngles.x = -.pi/2
                footPlaceHolder.eulerAngles.y = 0.0
                footPlaceHolder.position = locationSite
                footPlaceHolder.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
                footPlaceHolder.eulerAngles = SCNVector3Make(0, .pi/2, 0);
                self.sceneView.scene.rootNode.addChildNode(footPlaceHolder)
                self.sceneType = "DEFAULT"
                let configuration = ARWorldTrackingConfiguration();
                if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
                    configuration.detectionImages = referenceImages
                    configuration.maximumNumberOfTrackedImages = .max
                }
                self.sceneView.session.run(configuration)
            }
        } else if(sceneType == "AVATAR") {
            DispatchQueue.main.async {
                //                let footImage = UIImageView(image: UIImage(named: "art.scnassets/dancer_place.png"))
                self.animationViewInstructions?.isHidden = true
                self.animationViewInstructions?.pause()
                location.x = location.x - 4.0
                location.z = location.z - 0.5
                self.avatarPosition = location
                let dancerDummy =  SCNNode(geometry: SCNPlane(width: 2, height: 2))
                dancerDummy.name = "DANCER_HOLDER"
                dancerDummy.geometry?.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.0)
                //                self.dancerDummy.eulerAngles.x = -.pi/2
                dancerDummy.eulerAngles.y = 0
                dancerDummy.position =  locationSite
                dancerDummy.eulerAngles = SCNVector3Make(0, self.cameraAngle.y, 0);
                dancerDummy.scale = SCNVector3(x: 1, y: 1, z: 1)
                self.sceneView.scene.rootNode.addChildNode(dancerDummy)
                self.instrcutionMainAnimationView?.isHidden = false
                self.instrcutionMainAnimationView?.play()
                self.avatarAdded = false
                self.footAdded = false
                self.sceneType = "DEFAULT"
                
            }
        }
    }
    
    @objc func handlePitch(withGestureRecognizer recognizer: UIPinchGestureRecognizer) {
        let nodeModel = sceneView.scene.rootNode.childNodes
        if recognizer.state == .changed {
            //            print(recognizer.scale)
            for node in nodeModel{
                if (isFootModeActive) {
                    if(node.name != "dancer" && ((Float(recognizer.scale) * node.scale.x) < Float((self.animationScaleDefault * 2)))
                       && ((Float(recognizer.scale) * node.scale.x) > Float((self.animationScaleDefault / 2)))){
                        let pinchScaleX = (Float(recognizer.scale) * node.scale.x)
                        let pinchScaleY = (Float(recognizer.scale) * node.scale.y)
                        let pinchScaleZ = (Float(recognizer.scale) * node.scale.z)
                        node.scale = SCNVector3(x: Float(pinchScaleX), y: Float(pinchScaleY), z: Float(pinchScaleZ))
                    }
                } else {
                    if(node.name == "dancer" && ((Float(recognizer.scale) * node.scale.x) < Float((self.avatarScaleDefalut * 2)))
                       && ((Float(recognizer.scale) * node.scale.x) > Float((self.avatarScaleDefalut / 2)))){
                        let pinchScaleX = (Float(recognizer.scale) * node.scale.x)
                        let pinchScaleY = (Float(recognizer.scale) * node.scale.y)
                        let pinchScaleZ = (Float(recognizer.scale) * node.scale.z)
                        let resetScale = SCNVector3(x: Float(pinchScaleX), y: Float(pinchScaleY), z: Float(pinchScaleZ))
                        self.avatarScale = resetScale
                        node.scale = resetScale
                        recognizer.scale = 1.0
                    }
                }
                
            }
        }
    }
    
    private func scaleObject(scaleVal: Double, nodeType: String, mode: String){
        let nodeModel = sceneView.scene.rootNode.childNodes
        for node in nodeModel{
            if(node.name == nodeType){
                var pinchScaleX = Float(scaleVal) + node.scale.x
                var pinchScaleY =  Float(scaleVal) + node.scale.y
                var pinchScaleZ =  Float(scaleVal) + node.scale.z
                if(mode == "ZoomOut"){
                    pinchScaleX =  node.scale.x - Float(scaleVal)
                    pinchScaleY =  node.scale.y - Float(scaleVal)
                    pinchScaleZ =  node.scale.z - Float(scaleVal)
                }
                
                node.scale = SCNVector3(x: Float(pinchScaleX), y: Float(pinchScaleY), z: Float(pinchScaleZ))
            }
        }
    }
}

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )
        
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}

extension ViewController {
    func presentAlert(title: String) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        nextViewController = storyBoard.instantiateViewController(withIdentifier: "alert") as? AlertViewController
        if(nextViewController != nil){
            nextViewController!.modalPresentationStyle = .overCurrentContext
            nextViewController!.setStatus(title: title)
            self.present(nextViewController!, animated:true, completion:nil)
        }
    }
    
    func destroyAlert(){
        if (nextViewController != nil) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                DispatchQueue.main.async {
                    self.nextViewController?.dismiss(animated: true)
                        self.mainTableItems.isHidden = true
                        self.view.sendSubviewToBack(self.mainTableItems)
                        self.initateAR()
                    
                }
            }
        }
    }
    
    func destroyAlertWhenFail(){
        if (nextViewController != nil) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                DispatchQueue.main.async {
                    self.nextViewController?.dismiss(animated: true)
                }
            }
        }
    }
}

extension CMQuaternion {
    var toSIMD: simd_quatd {
        return simd_quatd(ix: x, iy: y, iz: z, r: w)
    }
}

extension CMAcceleration {
    var toSIMD: SIMD3<Double> {
        return SIMD3<Double>(x,y,z)
    }
}

extension SCNVector3 {
    static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    }
}


