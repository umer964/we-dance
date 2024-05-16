//
//  KlausTrainerController.swift
//  dancereality
//
//  Created by Mahmoona Shahzadi on 11.05.23.
//

import Foundation
import ARKit

class KlausTrainerController: UIViewController, ARSCNViewDelegate, ARSessionDelegate{
    
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var menuHolder: UIView!
    @IBOutlet weak var speedLabel: UILabel!
    var task: DispatchWorkItem? = nil
    @IBOutlet weak var menuBackBtn: UIImageView!
    @IBOutlet weak var menuHeading: UILabel!
    @IBOutlet weak var mainTableItems: UITableView!
    @IBOutlet weak var reset: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var playBtn: UIImageView!
    //@IBOutlet weak var videoBtn: UIView!
    @IBOutlet weak var musicBtn: UIImageView!
    private var klausNode : CustomScnNode?
    
    @IBOutlet weak var gestureHolder: UIView!
    private var danceMove: Int?
    private var danceSubMove: String?
    private var sceneHelper: SceneScenarioHelper?
    
    private var dancesDataSource: MyData?
    private var danceMovesByDanceDataSource: DanceSubMovesAdapter?
    
    private var nextViewController: AlertViewController?
    private var musicHelper :MusicHelper! = MusicHelper.sharedHelper;
    private var avatarScale: SCNVector3 = SCNVector3(x: 0.008, y: 0.008, z: 0.008)
    private let avatarScaleDefalut = 0.008
    private let animationScaleDefault = 2
    private var avatarAdded = false
    private var modelAnimating = false
    private let fileHelper: FileHelper = FileHelper()
    private var isDefaultActive = true
    private var avatarAnimationData: [Timer] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.session.delegate = self
        //videoBtn.isHidden = true
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.preferredFramesPerSecond = 60
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        self.speedSlider.maximumValue = 1.5
        self.speedSlider.minimumValue = 0.5
        self.speedSlider.value = 1.0
        self.speedLabel.text = "Speed: " + String(self.speedSlider.value)
        self.speedSlider.isContinuous = true
        let playBtnGesture = UITapGestureRecognizer(target: self, action: #selector(modelPlayBtnTapped(tapGestureRecognizer:)))
        playBtn.isUserInteractionEnabled = true
        playBtn.addGestureRecognizer(playBtnGesture)
        
        //let videoBtnGesture = UITapGestureRecognizer(target: self, action: #selector(videoBtnTapped(tapGestureRecognizer:)))
        //videoBtn.isUserInteractionEnabled = true
        //videoBtn.addGestureRecognizer(videoBtnGesture)
        
        let resetBtnGesture = UITapGestureRecognizer(target: self, action: #selector(resetBtnTapped))
        reset.isUserInteractionEnabled = true
        reset.addGestureRecognizer(resetBtnGesture)
        
        let musicTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.musicBtnTapped))
        musicTapGesture.numberOfTapsRequired = 1
        musicBtn.addGestureRecognizer(musicTapGesture)
        musicBtn.isUserInteractionEnabled = true
        
        let rotationGestureWithPan = UIPanGestureRecognizer(target: self, action: #selector(self.rotateNodeWithPanGesture(gesture:)))
        self.gestureHolder.addGestureRecognizer(rotationGestureWithPan)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(self.handlePitch(withGestureRecognizer:)))
        self.gestureHolder.addGestureRecognizer(pinchGestureRecognizer)
        self.showMenu()
        
    }
    
    @objc func handlePitch(withGestureRecognizer recognizer: UIPinchGestureRecognizer) {
        let nodeModel = sceneView.scene.rootNode.childNodes
        if recognizer.state == .changed {
            //            print(recognizer.scale)
            for node in nodeModel{
                if UIDevice.current.orientation.isFlat {
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
    
    @objc func rotateNodeWithPanGesture(gesture: UIPanGestureRecognizer){
        if(!self.avatarAdded){
            return
        }
        
        let translation = gesture.translation(in: gesture.view)
        var newAngleY = (Float)(translation.x)*(Float)(Double.pi)/1080.0
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
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Confirmation", message: "Do you want to proceed?", preferredStyle: .alert)

        // Create the "Yes" action
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            guard let sceneHelper = self.sceneHelper else {
                return
            }
            
            let avatar = sceneHelper.getDanceSubDetailts().characterModel
            NetworkManager.avatarUpdateRequest(avatarId: avatar.id, speed: Double(self.speedSlider.value)){ (data: AvatarModelUpdate?) in
                if(data != nil){
                    if let danceMoveExistedData = self.fileHelper.getDanceMoveData(hashFileName: sceneHelper.getDanceSubDetailts().hash) {
                        let existedAvatar = danceMoveExistedData.characterModel
                        let updatedAvatar = AvatarModel(id: existedAvatar.id, name: existedAvatar.name,
                                                        path: existedAvatar.path, pathFileName: existedAvatar.pathFileName, avatarMatImagePath: existedAvatar.avatarMatImagePath, avatarMatImageName: existedAvatar.avatarMatImageName
                                                        , duration: existedAvatar.duration, frames: existedAvatar.frames, frameRate: existedAvatar.frameRate, size: existedAvatar.size, smoothing: existedAvatar.smoothing, validity: true, speed: data!.speed, createdDate: existedAvatar.createdDate, updatedDate: existedAvatar.updatedDate)
                        let danceMoveNew = DanceMoveModel(id: danceMoveExistedData.id, createdDate: danceMoveExistedData.createdDate, updatedDate: danceMoveExistedData.updatedDate, name: danceMoveExistedData.name, hash: danceMoveExistedData.hash, direction: danceMoveExistedData.direction, footStepAnimation: danceMoveExistedData.footStepAnimation, barCount: danceMoveExistedData.barCount, characterModel: updatedAvatar, video: danceMoveExistedData.video)
                        do{
                            let encodedData = try JSONEncoder().encode(danceMoveNew)
                            let jsonString = String(data: encodedData,
                                                    encoding: .utf8)
                            self.fileHelper.createDancesFile(content: jsonString!, hash: danceMoveNew.hash)
                            alertController.dismiss(animated: false)
                            self.saveSuccessDialog(message: "Speed Saved at "+String(self.speedSlider.value))
                        } catch {
                            print("something wrong")
                            alertController.dismiss(animated: false)
                            self.saveSuccessDialog(message: "Speed could not be saved in File")
                        }
                    } else {
                        alertController.dismiss(animated: false)
                        self.saveSuccessDialog(message: "Speed could not be saved in File Folder")
                    }
                } else {
                    alertController.dismiss(animated: false)
                    self.saveSuccessDialog(message: "Speed could not be saved on Server")
                }
            }
        }
        
        // Create the "No" action
        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
            self.dismiss(animated: true)
        }

        // Add the actions to the alert controller
        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        // Present the alert controller
        present(alertController, animated: true, completion: nil)
        
    }
    
    private func saveSuccessDialog(message: String){
        let alertController = UIAlertController(title: "Save Status", message: message, preferredStyle: .alert)
                
                // Create the "OK" button action
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    // Handle the OK button tap (if needed)
                    print("OK tapped")
                    alertController.dismiss(animated: true)
                }
                
                // Add the OK button action to the alert controller
                alertController.addAction(okAction)
                
                // Present the alert controller
                present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onDragFinish(_ sender: Any) {
        self.invalidateAllAvatarTimer()
        self.isDefaultActive = false
        prepareModelAnimation()
    }
    
    @IBAction func onSlideFinish(_ sender: Any) {
        self.invalidateAllAvatarTimer()
        self.isDefaultActive = false
        prepareModelAnimation()
    }
    
    @objc func musicBtnTapped(sender: UITapGestureRecognizer) {
        let musicChooser = UIAlertController(title: "Musics", message: "Select Music", preferredStyle: .alert)
        
        if let result = self.sceneHelper?.getDanceTypeDetails().musics {
            for label in result{
                let labelAction = UIAlertAction(title: label.fileName, style: .default) { (action:UIAlertAction!) in
                    self.sceneHelper?.resetMusic(id: label.id)
                    self.invalidateAllAvatarTimer()
                    if let retrievedString = UserDefaults.standard.string(forKey: (self.sceneHelper?.getDanceSubDetailts().name)!) {
                        self.speedLabel.text = "Speed: " + String(retrievedString)
                        self.speedSlider.value = Float(retrievedString)!
                    }
                    self.musicHelper.audioPlayer?.pause()
                    self.playBtn.image = UIImage(named: "person_start")
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
    
    @objc func resetBtnTapped(sender: UITapGestureRecognizer) {
        self.invalidateAllAvatarTimer()
        prepareModelAnimation()
        self.isDefaultActive = true
        self.speedLabel.text = "Speed: " + String(1.0)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("disappring now....")
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
    }
    
    @IBAction func onSliderChange(_ sender: Any) {
       // self.invalidateAllAvatarTimer()
        //self.isDefaultActive = false
        //prepareModelAnimation()
        self.speedLabel.text = "Speed: " + String(format: "%.2f", self.speedSlider.value)
    }
    
    @objc func modelPlayBtnTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        prepareModelAnimation()
    }
    
    @objc func videoBtnTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        musicHelper.audioPlayer?.pause()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "custom_video_mode") as! KlausCustomVideoController
        nextViewController.setVideoInformation(video: (self.sceneHelper?.getDanceSubDetailts().video.filename)!,
                                        sceneHelper: self.sceneHelper!)
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    private func prepareModelAnimation(){
        if(!avatarAdded){
            return
        }
        if(!modelAnimating){
            if(self.avatarAnimationData.isEmpty){
                if(sceneHelper?.getBeatStartTime(speedRate: Double(self.speedSlider.value)).count == 2){
                    self.playBtn.image = UIImage(named: "person_stop")
                    let beatForCounter = sceneHelper?.getBeatStartTime(speedRate: Double(self.speedSlider.value))[1]
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
                            if(i == 0){
                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                self.modelAnimating = true
                            }
                        }
                    }
                    guard let data = self.sceneHelper?.getAvatarAnimationByBeatDefault(speedRate: Double(self.speedSlider.value) * 100) else {
                        self.modelAnimating = false
                        playBtn.image = UIImage(named: "person_start")
                        return
                    }
                    for i in 0...data.count - 1{
                        self.menuHolder.isHidden = true
                        self.avatarAnimationData.append(Timer.scheduledTimer(timeInterval: data[i][0], target: self, selector: #selector(self.avatarAnimation),
                                                                             userInfo: ["duration": data[i][3],"speed":data[i][7], "totalDuration": data[i][4], "startPos": data[i][6]], repeats: false))
                    }
                }
            } else {
                self.menuHolder.isHidden = true
                self.playBtn.image = UIImage(named: "person_stop")
            }
            self.modelAnimating = true
        } else {
            self.modelAnimating = false
            playBtn.image = UIImage(named: "person_start")
        }
    }
    
    private func hideUIViewWhileAnimation(status: Bool){
        UIView.animate(withDuration: 0.3, animations: {
            if(status){
                self.menuHolder.alpha = 0
                self.backBtn.alpha = 0
            } else {
                self.menuHolder.alpha = 1
                self.backBtn.alpha = 1
            }
        }) { (finished) in
            self.menuHolder.isHidden = status
            self.backBtn.isHidden = status
        }
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
                        thisSelf.playBtn.image = UIImage(named: "start")
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
                        thisSelf.speedSlider.isEnabled = true
                        thisSelf.playBtn.isUserInteractionEnabled = true
                    }
                })
            }
        }
        
        if let task = self.task {
            DispatchQueue.main.asyncAfter(deadline: estimatedDuration,
                                          execute: task)
        }
        
        klausNode.playAnimation()
        self.sceneView.preferredFramesPerSecond = 60
        self.sceneView.rendersContinuously = true
        self.sceneView.scene.isPaused = false
        self.playBtn.image = UIImage(named: "start")
        
    }
    
    private func invalidateAllAvatarTimer(){
        if(!self.avatarAnimationData.isEmpty){
            for timer in self.avatarAnimationData {
                timer.invalidate()
                self.avatarAnimationData.removeFirst()
            }
        }
        
        musicHelper.audioPlayer?.pause()
    }
    
    private func initateAR(){
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration, options: [])
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        let planeAnchor = anchor
        let x = planeAnchor.transform.columns.3.x
        let y = planeAnchor.transform.columns.3.y
        let z = planeAnchor.transform.columns.3.z
        self.klausNode!.position = SCNVector3(x: x, y: y, z: z)
        self.klausNode!.scale = self.avatarScale
        self.klausNode!.name = "dancer"
        self.klausNode!.stopAnimation()
        self.sceneView.scene.rootNode.addChildNode(self.klausNode!)
        DispatchQueue.main.async {
            self.view.bringSubviewToFront(self.gestureHolder)
        }
        self.avatarAdded = true
        let configuration = ARWorldTrackingConfiguration();
        self.sceneView.session.run(configuration)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.session.delegate = self
    }
    
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
                self.menuHeading.text = "Select Male or Female Move"
            }){ [self] (id, hash, subHash)->() in
                self.danceSubMove = hash
                let danceMoveHelper = DanceMoveHelper(id: id, hash: hash){(status, data) in
                    if let danceMoveData = data {
                        DispatchQueue.main.async {
                            self.sceneHelper = SceneScenarioHelper(danceName: self.danceMove! ,moveName: danceMoveData.hash, subHash: subHash)
                            
                            guard let sceneHelper = self.sceneHelper else {
                                self.destroyAlertWhenFail()
                                return
                            }
                            sceneHelper.setMode(mode: "KlausMode")
                            self.klausNode = sceneHelper.getModelData()
                            let speed = sceneHelper.getDanceSubDetailts().characterModel.speed
                            if(speed == 0.0){
                                self.speedSlider.value = 1.0
                                self.speedLabel.text = String(1.0)
                            } else {
                                self.speedSlider.value = Float((sceneHelper.getDanceSubDetailts().characterModel.speed))
                                self.speedLabel.text = String(format: "%.2f", Float((sceneHelper.getDanceSubDetailts().characterModel.speed)))
                            }
                            var animationOffSetX = sceneHelper.getDanceSubDetailts().footStepAnimation.offSetX
                            var animationOffSetY = sceneHelper.getDanceSubDetailts().footStepAnimation.offSetY
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
                            
                            self.menuHolder.isHidden = false
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
    
    @objc func backMenuTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        showMenu()
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
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.invalidateAllAvatarTimer()
        self.avatarAdded = false
        self.modelAnimating = false
        self.view.sendSubviewToBack(self.gestureHolder)
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            if(node.name == "dancer" ||
               node.name == "FOOT_HOLDER" || node.name == "DANCER_HOLDER"){
                node.removeFromParentNode()
            }
        }
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        showMenu()
    }
    
    func presentAlert(title: String) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        nextViewController = storyBoard.instantiateViewController(withIdentifier: "alert") as? AlertViewController
        if(nextViewController != nil){
            nextViewController!.modalPresentationStyle = .overCurrentContext
            nextViewController!.setStatus(title: title)
            self.present(nextViewController!, animated:true, completion:nil)
        }
    }
}
