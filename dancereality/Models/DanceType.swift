//
//  DanceMoves.swift
//  dancereality
//
//  Created by Saad Khalid on 02.08.22.
//
public struct DanceTypeModel {
    let name: String
    let id: Int
    let createdDate: String
    let updatedDate: String?
    let hash: String
    let musics: [MusicModel]
    let danceMoves: [SubDance]?
}

extension DanceTypeModel: Decodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case name
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
        case id
        case hash = "hash"
        case musics
        case danceMoves = "dances"
    }
}

public struct MusicModel {
    let id: Int
    let fileName: String?
    let orignalFileName: String
    let instrumentalFileName: String?
    let path: String
    let instrumentalPath :String?
    let beats: [[Double]]?
    let updatedDate: String?
    let createdDate: String
}

extension MusicModel: Decodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case fileName = "name"
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
        case id
        case beats = "beats"
        case path = "filePath"
        case orignalFileName = "fileName"
        case instrumentalFileName = "fileInstName"
        case instrumentalPath = "fileInstPath"
    }
}

public struct SubDance {
    let name: String
    let id: Int
    let female: ChildDance
    let male: ChildDance
    let priority: Int
    let description: String?
    let isCompleted: Bool
    let timeStamps: [[Double]]
    let hash: String
    let updatedDate: String?
    let createdDate: String
}

extension SubDance: Decodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case name
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
        case hash = "hash"
        case id
        case female
        case male
        case priority
        case description
        case isCompleted
        case timeStamps
    }
}

public struct ChildDance {
    let name: String
    let id: Int
    let hash: String
    let updatedDate: String?
    let createdDate: String
}

extension ChildDance: Decodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case name
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
        case hash = "hash"
        case id
    }
}

public struct DanceTypeResponse {
    let data: [DanceTypeModel]
    let success: Bool
    let responseCode: Int
}

extension DanceTypeResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case data = "data"
        case success = "success"
        case responseCode = "responseCode"
    }
}
