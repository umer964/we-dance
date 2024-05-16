//
//  DanceMove.swift
//  dancereality
//
//  Created by Saad Khalid on 03.08.22.
//
public struct DanceMoveModel{
    let id: Int
    let createdDate: String
    let updatedDate: String?
    let name: String
    let hash: String
    let direction: String
    let footStepAnimation: FootAnimationModel
    let barCount: Int
    let characterModel: AvatarModel
    let video: Video
}

extension DanceMoveModel: Decodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case name
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
        case id
        case hash
        case barCount = "barCount"
        case direction = "direction"
        case footStepAnimation = "footsteps"
        case characterModel = "avatar"
        case video
    }
}

public struct FootAnimationModel{
    let id: Int
    let name: String
    let path: String
    let frames: Int
    let steps: [[Double]]
    let size: Double
    let offSetX: Double
    let offSetY: Double
    let createdDate: String
    let updatedDate: String?
}

extension FootAnimationModel: Decodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case name = "fileName"
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
        case id
        case size
        case frames = "frameRate"
        case offSetX = "offsetX"
        case offSetY = "offsetY"
        case steps = "timeStamps"
        case path = "filePath"
    }
}

public struct AvatarModel{
    let id: Int
    let name: String?
    let path: String
    let pathFileName: String
    let avatarMatImagePath: String
    let avatarMatImageName: String
    let duration: Double
    let frames: Int
    let frameRate: Double
    let size: Double
    let smoothing: Double
    let validity: Bool
    let speed: Double
    let createdDate: String
    let updatedDate: String?
}

extension AvatarModel: Decodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case name
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
        case id
        case smoothing
        case size
        case speed
        case validity
        case avatarMatImagePath = "skinImagePath"
        case avatarMatImageName = "skinImageName"
        case pathFileName = "fileName"
        case duration = "duration"
        case frames = "frames"
        case frameRate = "frameRate"
        case path = "filePath"
    }
}

public struct Video{
    let id: Int
    let filename: String
    let path: String
    let duration: Double
    let size: Double
    let validity: Bool
    let speed: Double
    let createdDate: String
    let updatedDate: String?
}

extension Video: Decodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case filename = "fileName"
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
        case id
        case duration
        case path = "filePath"
        case size = "size"
        case speed = "videoSpeed"
        case validity = "videoValid"
    }
}

public struct DanceResponse {
    let data: DanceMoveModel
    let success: Bool
    let responseCode: Int
}

extension DanceResponse: Decodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case data = "data"
        case success = "success"
        case responseCode = "responseCode"
    }
}

public struct DanceMoveDecoderForFile: Decodable, Encodable {
    let moves: [DanceMoveModel]
}

public struct LoginFailed: Decodable, Encodable {
    let message: String
    let success: Bool
    let responseCode: Int
}

public struct LoginPassed: Decodable, Encodable {
    let data: LoginData
    let success: Bool
    let responseCode: Int
}

public struct LoginData: Decodable, Encodable {
    let id: String
    let roles: [String]
}

public struct AvatarUpdateData: Decodable, Encodable {
  let speed: Double
  let validity: Bool
  var parameters: [String: Any] { [
    "speed": speed,
    "validity": validity
    ]
  }
}

public struct AvatarModelUpdateRequest: Encodable, Decodable{
    let data: AvatarModelUpdate
    let success: Bool
    let responseCode: Int
}

public struct AvatarModelUpdate{
    let name: String?
    let path: String
    let pathFileName: String
    let avatarMatImagePath: String
    let avatarMatImageName: String
    let duration: Double
    let frames: Int
    let frameRate: Double
    let size: Double
    let smoothing: Double
    let validity: Bool
    let speed: Double
}

extension AvatarModelUpdate: Decodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case name
        case smoothing
        case size
        case speed
        case validity
        case avatarMatImagePath = "skinImagePath"
        case avatarMatImageName = "skinImageName"
        case pathFileName = "fileName"
        case duration = "duration"
        case frames = "frames"
        case frameRate = "frameRate"
        case path = "filePath"
    }
}
