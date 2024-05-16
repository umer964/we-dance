//
//  PredictionModel.swift
//  dancereality
//
//  Created by Saad Khalid on 01.09.22.
//

public struct PredictionModelResponse {
    let data: String
    let success: Bool
    let labels: [String]
    let hash: String
    let responseCode: Int
}

extension PredictionModelResponse: Decodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case data = "prediction"
        case hash = "hash"
        case labels = "labels"
        case success = "success"
        case responseCode = "response_code"
    }
}
