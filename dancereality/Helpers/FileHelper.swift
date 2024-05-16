//
//  FileHelper.swift
//  dancereality
//
//  Created by Saad Khalid on 02.08.22.
//

import Foundation

public class FileHelper {
    
    public func isDataDirectoryAvailable () -> Bool{
        return FileManager.default.fileExists(atPath: AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.STORE_DIRECTORY).relativePath)
    }
    
    public func isMediaDirectoryAvailable() -> Bool{
        return FileManager.default.fileExists(atPath: AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.DOWNLOAD_DIRECTORY).relativePath)
    }
    
    public func isMediaFileExist(fileName: String) -> Bool {
        return FileManager.default.fileExists(atPath: AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.DOWNLOAD_DIRECTORY+"/"+fileName).relativePath)
    }
    
    public func isDanceTypeFileExist () -> Bool{
        return FileManager.default.fileExists(atPath: AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.STORE_DIRECTORY+"/"+AppModel.DANCE_TYPE_FILE).relativePath)
    }
    
    public func isDanceFileExist (hash: String) -> Bool {
        return FileManager.default.fileExists(atPath: AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.STORE_DIRECTORY+"/"+hash+".json").relativePath)
    }
    
    public func createDataDirectory () -> Bool{
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                            in: .userDomainMask).first {
            do {
                try FileManager.default.createDirectory(atPath: documentDirectory.appendingPathComponent(AppModel.STORE_DIRECTORY).relativePath, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch let error as NSError {
                print(error.localizedDescription)
                return false
            }
            
        }
        return false
    }
    
    public func createMediaDirectory () -> Bool{
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                            in: .userDomainMask).first {
            do {
                try FileManager.default.createDirectory(atPath: documentDirectory.appendingPathComponent(AppModel.DOWNLOAD_DIRECTORY).relativePath, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch let error as NSError {
                print(error.localizedDescription)
                return false
            }
            
        }
        return false
    }
    
    public func isChangeDetectedInDanceType() -> Bool {
        return true
    }
    
    public func isChangeDetectedInDances() -> Bool {
        return true
    }
    
    public func createDancesFile(content: String, hash: String) -> Bool {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                            in: .userDomainMask).first {
            do {
                let filePath: String = AppModel.STORE_DIRECTORY+"/"+hash+".json"
                FileManager.default.createFile(atPath: documentDirectory.appendingPathComponent(filePath).relativePath, contents: nil, attributes: nil)
                try content.write(to: documentDirectory.appendingPathComponent(filePath), atomically: true, encoding: String.Encoding.utf8)
                return true
            } catch let error as NSError{
                print(error)
                return false
            }
            
        }
        return false
    }
    
    public func createDanceTypeFile(content: String) -> Bool {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                            in: .userDomainMask).first {
            do {
                let filePath: String = AppModel.STORE_DIRECTORY+"/"+AppModel.DANCE_TYPE_FILE
                FileManager.default.createFile(atPath: documentDirectory.appendingPathComponent(filePath).relativePath, contents: nil, attributes: nil)
                try content.write(to: documentDirectory.appendingPathComponent(filePath), atomically: true, encoding: String.Encoding.utf8)
                return true
            } catch let error as NSError{
                print(error)
                return false
            }
        }
        return false
    }
    
    public func updateDanceTypeFile(danceType: [DanceTypeModel]) -> Bool {
        return true
    }
    
    public func updateDancesFile(dance: DanceTypeModel) -> Bool {
        return true
    }
    
    public func getDancesByDanceType (danceTypeID: Int) -> [SubDance] {
        var danceSubData: [SubDance] = []
        var danceTypeData: [DanceTypeModel] = []
        do {
            let url = AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.STORE_DIRECTORY+"/"+AppModel.DANCE_TYPE_FILE)
            let jsonData = try String(contentsOf: url, encoding: .utf8)
            let parseJson: Data = jsonData.data(using: .utf8)!
            danceTypeData = try JSONDecoder().decode([DanceTypeModel].self, from: parseJson)
            for danceType in danceTypeData {
                if(danceType.id == danceTypeID){
                    danceSubData = danceType.danceMoves!
                }
            }
        } catch let error as NSError {
            print(error)
        }
        
        return danceSubData
    }
    
    public func getDanceTypeData() -> [DanceTypeModel]{
        var danceTypeData: [DanceTypeModel] = []
        if(!isDanceTypeFileExist()){
            return danceTypeData
        }
        
        do {
            let url = AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.STORE_DIRECTORY+"/"+AppModel.DANCE_TYPE_FILE)
            let jsonData = try String(contentsOf: url, encoding: .utf8)
            let parseJson: Data = jsonData.data(using: .utf8)!
            danceTypeData = try JSONDecoder().decode([DanceTypeModel].self, from: parseJson)
        } catch let error as NSError {
            print(error)
        }
        
        return danceTypeData
    }
    
    public func getDanceMoveData(hashFileName: String) -> DanceMoveModel?{
        var danceMoveData: DanceMoveModel? = nil
        if(!isDanceFileExist(hash: hashFileName)){
            return danceMoveData
        }
        
        do {
            let url = AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.STORE_DIRECTORY+"/"+hashFileName+".json")
            let jsonData = try String(contentsOf: url, encoding: .utf8)
            let parseJson: Data = jsonData.data(using: .utf8)!
            danceMoveData = try JSONDecoder().decode(DanceMoveModel.self, from: parseJson)
        } catch let error as NSError {
            print(error)
        }
        
        return danceMoveData
    }
    
    public func deleteDanceFiles(hash: String) {
        var danceMoveData: DanceMoveModel? = nil
        if(!isDanceFileExist(hash: hash)){
            return
        }
        
        do {
            let url = AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.STORE_DIRECTORY+"/"+hash+".json")
            let jsonData = try String(contentsOf: url, encoding: .utf8)
            let parseJson: Data = jsonData.data(using: .utf8)!
            danceMoveData = try JSONDecoder().decode(DanceMoveModel.self, from: parseJson)
            if(danceMoveData?.footStepAnimation != nil){
                deleteFile(filename: (danceMoveData?.footStepAnimation.path)!, dir: "Download")
            }
            if(danceMoveData?.characterModel != nil){
                deleteFile(filename: (danceMoveData?.characterModel.pathFileName)!, dir: "Download")
            }
            deleteFile(filename: hash+".json", dir: "Store")
        } catch let error as NSError {
            print(error)
        }
    }
    
    private func deleteFile(filename: String, dir: String) -> Bool {
        do {
            let defaultPath = dir == "Store" ? AppModel.STORE_DIRECTORY : AppModel.DOWNLOAD_DIRECTORY
            try FileManager.default.removeItem(atPath: defaultPath+"/"+filename)
            return true
        } catch {
            print("Could not delete file, probably read-only filesystem")
        }
        
        return false
    }
    
    public static func fileExistsInDownloadsDirectory(filename: String) -> Bool {
        let fileManager = FileManager.default
        if let downloadsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = downloadsURL.appendingPathComponent(AppModel.DOWNLOAD_DIRECTORY).appendingPathComponent(filename)
            return fileManager.fileExists(atPath: fileURL.path)
        }
        return false
    }
    
    public static func saveObjectToUserDefaults(object: LoginData, key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            let jsonString = String(data: encoded, encoding: .utf8)
            UserDefaults.standard.set(jsonString, forKey: key)
        }
    }

    // Retrieve object from UserDefaults and convert back to class
    public static func getObjectFromUserDefaults(key: String) -> LoginData? {
        if let jsonString = UserDefaults.standard.string(forKey: key),
            let data = jsonString.data(using: .utf8),
            let decodedObject = try? JSONDecoder().decode(LoginData.self, from: data) {
            return decodedObject
        }
        return nil
    }
    
    public static func emptyUserDefaults(){
        UserDefaults.standard.set(nil, forKey: "USER")
    }
    
    public static func saveObjectToUserRegisterDefaults(object: UserRegister?, key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            let jsonString = String(data: encoded, encoding: .utf8)
            UserDefaults.standard.set(jsonString, forKey: key)
        }
    }

    // Retrieve object from UserDefaults and convert back to class
    public static func getObjectFromUserRegisterDefaults(key: String) -> UserRegister? {
        if let jsonString = UserDefaults.standard.string(forKey: key),
            let data = jsonString.data(using: .utf8),
            let decodedObject = try? JSONDecoder().decode(UserRegister.self, from: data) {
            return decodedObject
        }
        return nil
    }
}
