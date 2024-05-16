//
//  DownloadHelper.swift
//  dancereality
//
//  Created by Saad Khalid on 02.08.22.
//

import Foundation

public class DownloadHelper {
    
    public static func downloadFile (fileName: String, filePath : String, withCompletion: @escaping (Bool, String) -> ()){
        /**
         Get the Download Directory Path
         */
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                               in: .userDomainMask).first else {
            withCompletion(false, filePath)
            return
        }
        
        let fileName = documentDirectory.appendingPathComponent(AppModel.DOWNLOAD_DIRECTORY+"/"+fileName)
        /**
         Get the File Url
         */
        guard let fileUrl = URL(string: AppModel.serverURL+"/"+filePath) else {
            print(AppModel.DOWNLOAD_FILE_URI_NOT_AVAILABLE)
            withCompletion(false, filePath)
            return
        }
        
        URLSession.shared.downloadTask(with: fileUrl) { (tempFileUrl, response, error) in
            guard let fileTempUrl = tempFileUrl  else {
                print(AppModel.DOWNLOAD_FILE_URI_NOT_AVAILABLE)
                withCompletion(false, filePath)
                return
            }
            do {
                let fileData = try Data(contentsOf: fileTempUrl)
                try fileData.write(to: fileName)
                withCompletion(true, filePath)
            } catch {
                print(AppModel.DOWNLOAD_FAILED)
                withCompletion(false, filePath)
            }
            
        }.resume()
    }
}

