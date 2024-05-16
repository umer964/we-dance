//
//  MainController.swift
//  dancereality
//
//  Created by Saad Khalid on 28.07.22.
//

import UIKit
import Lottie

class MainController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusProgress: UIProgressView!
    private var animationView : AnimationView = .init(name: "tanzapp_start")
    private var downloadableFiles: [[String]] = []
    private let fileHelper: FileHelper = FileHelper()
    
    @IBOutlet weak var animationHolder: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        changeStatusAndProgress(status: "Preparing App", progress: 0.0)
//        animationView = .init(name: "starting_sceern_placeholder_without_bg")
        
        animationView.frame = view.bounds
        
        // 3. Set animation content mode
        
        animationView.contentMode = .scaleAspectFit
        
        // 4. Set animation loop mode
        
        animationView.loopMode = .playOnce
        
        // 5. Adjust animation speed
        
        animationView.animationSpeed = 0.9
        
        animationHolder.addSubview(animationView)
        
        // 6. Play animation
        
        animationView.play(completion: {_ in
//            self.animationView.pause()
            self.createNecessaryDirectories()
        })
    }
    
    private func createNecessaryDirectories(){
        if (fileHelper.createDataDirectory() &&
                fileHelper.createMediaDirectory()){
            changeStatusAndProgress(status: "Syncing", progress: 0.25)
            startSycing()
        } else {
            print("Something went wrong")
        }
    }
    
    private func startSycing (){
        NetworkManager.loadDanceTypes { (data: [DanceTypeModel]?) in
            if (data != nil) {
                self.changeStatusAndProgress(status: "Downloading", progress: 0.5)
                self.initateDataSaver(data: data!)
            } else {
                self.moveToNextActivity()
            }
        }
    }
    
    private func initateDataSaver (data: [DanceTypeModel]){
        do{
            let encodedData = try JSONEncoder().encode(data)
            let jsonString = String(data: encodedData,
                        encoding: .utf8)
            if(self.fileHelper.createDanceTypeFile(content: jsonString!)){
                self.setDownloadableMedia(data: data)
                self.startDownloading()
                print("File Created")
            } else {
                print("File not Created")
            }
        } catch let error as NSError {
            print(error)
        }
        
    }
    
    private func startDownloading() {
        print(downloadableFiles.count)
        if(downloadableFiles.count > 0){
            if(self.fileHelper.isMediaFileExist(fileName: downloadableFiles.first![0])){
                self.downloadableFiles.remove(at: 0)
                self.startDownloading()
            } else {
                DownloadHelper.downloadFile(fileName: downloadableFiles.first![0], filePath: downloadableFiles.first![1]) { status, filePath in
                    self.downloadableFiles.remove(at: 0)
                    print("downloaded")
                    self.startDownloading()
                }
            }
        } else {
            self.changeStatusAndProgress(status: "Ready", progress: 0.75)
            self.moveToNextActivity()
        }
    }
    
    private func setDownloadableMedia (data:  [DanceTypeModel]){
        for danceInfo in data {
            for music in danceInfo.musics{
                self.downloadableFiles.append([music.orignalFileName, music.path])
                if(music.instrumentalPath != nil){
                    self.downloadableFiles.append([music.instrumentalFileName!, music.instrumentalPath!])
                }
            }
        }
    }
    
    private func moveToNextActivity() {
        let danceType: [DanceTypeModel] = self.fileHelper.getDanceTypeData()
        if(danceType.count > 0){
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if let username = FileHelper.getObjectFromUserDefaults(key: "USER") {
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "controller") as! ViewController
                    nextViewController.modalPresentationStyle = .fullScreen
                    self.present(nextViewController, animated:true, completion:nil)
                } else {
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
                    nextViewController.modalPresentationStyle = .fullScreen
                    self.present(nextViewController, animated:true, completion:nil)
                }
            }
        } else {
          print("resync")
        }
        self.changeStatusAndProgress(status: "Ready", progress: 0.99)
    }
    
    private func changeStatusAndProgress(status: String, progress: Float){
        DispatchQueue.main.async {
            self.statusProgress.setProgress(progress, animated: true)
            self.statusLabel.text = status
        }
    }
}
