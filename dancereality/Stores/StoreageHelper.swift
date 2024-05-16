//
//  StoreageHelper.swift
//  dancereality
//
//  Created by Saad Khalid on 02.08.22.
//

import Foundation

public class StoreageHelper {
    
    private let fileHelper: FileHelper = FileHelper()
    
    public func saveDanceTypes (data : String) -> Bool {
        return true
    }
    
    public func saveDances(data : String) -> Bool {
        return true
    }
    
    public func getDanceTypes () -> [DanceTypeModel] {
        var danceTypeData: [DanceTypeModel] = []
        
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
    
    public func getDanceTypeById (id: Int) -> DanceTypeModel {
        var danceTypeData: [DanceTypeModel] = []
        var danceType: DanceTypeModel? = nil
        do {
            let url = AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.STORE_DIRECTORY+"/"+AppModel.DANCE_TYPE_FILE)
            let jsonData = try String(contentsOf: url, encoding: .utf8)
            let parseJson: Data = jsonData.data(using: .utf8)!
            danceTypeData = try JSONDecoder().decode([DanceTypeModel].self, from: parseJson)
            for dance in danceTypeData {
                if (dance.id == id){
                    danceType = dance
                    break
                }
            }
        } catch let error as NSError {
            print(error)
        }
        
        return danceType!
    }
    
    public func getDanceSubByHash (id: Int, hash: String) -> SubDance {
        var danceTypeData: [DanceTypeModel] = []
        var danceType: SubDance? = nil
        do {
            let url = AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.STORE_DIRECTORY+"/"+AppModel.DANCE_TYPE_FILE)
            let jsonData = try String(contentsOf: url, encoding: .utf8)
            let parseJson: Data = jsonData.data(using: .utf8)!
            danceTypeData = try JSONDecoder().decode([DanceTypeModel].self, from: parseJson)
            for dance in danceTypeData {
                if (dance.id == id){
                    guard let dances = dance.danceMoves else {
                        continue
                    }
                    for danceSub  in dances {
                        if(danceSub.hash == hash){
                            danceType = danceSub
                            break
                        }
                    }
                }
            }
        } catch let error as NSError {
            print(error)
        }
        
        return danceType!
    }
    
    public func getDances (danceTypeID: Int) -> [SubDance] {
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
    
    public func getDanceByHash (hash: String) -> DanceMoveModel{
        var danceData: DanceMoveModel? = nil
        do {
            let url = AppModel.SOTRAGE_RELATIVE_PATH.appendingPathComponent(AppModel.STORE_DIRECTORY+"/"+hash+".json")
            let jsonData = try String(contentsOf: url, encoding: .utf8)
            let parseJson: Data = jsonData.data(using: .utf8)!
            danceData = try JSONDecoder().decode(DanceMoveModel.self, from: parseJson)
            
        } catch let error as NSError {
            print(error)
        }
        
        return danceData!
    }
    
}
