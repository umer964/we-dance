//
//  FeedBackResponseModel.swift
//  dancereality
//
//  Created by Saad Khalid on 02.09.22.
//

import Foundation
public struct FeedBackResponseModel {
    let data: String
}

extension FeedBackResponseModel: Decodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case data = "message"
    }
}
