//
//  DanceMoveHelper.swift
//  dancereality
//
//  Created by Saad Khalid on 09.08.22.
//

import Foundation

public class DanceMoveHelper {
    private let fileHelper: FileHelper = FileHelper()
    private let id: Int
    private let hash: String
    private var danceMovedata: DanceMoveModel?
    private var downloadableFiles: [[String]] = []
    private let withCompletion: (String, DanceMoveModel?) -> ()
    
    init(id: Int, hash: String, withCompletion : @escaping (String, DanceMoveModel?) -> ()){
        self.id = id
        self.hash = hash
        self.withCompletion = withCompletion
    }
    
    public func checkForUpdate(){
        NetworkManager.loadDanceMove(id: self.id) { [self] (data: DanceMoveModel?) in
            if let dance: DanceMoveModel = data{
                self.danceMovedata = dance
                if(dance.hash != self.hash){
                    fileHelper.deleteDanceFiles(hash: self.hash)
                }
                createFile()
            } else {
                if let danceMoveExistedData = fileHelper.getDanceMoveData(hashFileName: self.hash) {
                    withCompletion("All_Good", danceMoveExistedData)
                } else {
                    withCompletion("Data_Fetch_Failed", nil)
                }
            }
        }
    }
    
    private func createFile() {
        do{
            let encodedData = try JSONEncoder().encode(self.danceMovedata)
            let jsonString = String(data: encodedData,
                    encoding: .utf8)
            if(fileHelper.createDancesFile(content: jsonString!, hash: self.danceMovedata!.hash)){
                downloadableFiles.append([self.danceMovedata!.footStepAnimation.name, self.danceMovedata!.footStepAnimation.path])
                downloadableFiles.append([self.danceMovedata!.characterModel.pathFileName, self.danceMovedata!.characterModel.path])
                downloadableFiles.append([self.danceMovedata!.video.filename, self.danceMovedata!.video.path])
                downloadableFiles.append([self.danceMovedata!.characterModel.avatarMatImageName, self.danceMovedata!.characterModel.avatarMatImagePath])
                startDownloading()
            } else {
                withCompletion("File_Failed", nil)
            }
        } catch {
            withCompletion("Conversion Failer", nil)
        }
    }
    
    private func startDownloading() {
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
            withCompletion("All_Good", self.danceMovedata)
        }
    }
}
