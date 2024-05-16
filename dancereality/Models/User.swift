//
//  User.swift
//  dancereality
//
//  Created by Saad Bin Khalid on 30.11.23.
//

import Foundation
public struct User {
    let name: String
    let firstName: String
    let gender: String
    let age: Int
    let password: String
    let email: String
    let isActive: Bool
}

extension User: Decodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case name
        case firstName
        case password
        case age
        case gender
        case email
        case isActive
    }
}

public struct Verification {
    let code: String
    let expiry: String
}

extension Verification: Decodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case code
        case expiry
    }
}

public struct UserRegisterResponse {
    let data: UserRegister
    let success: Bool
    let responseCode: Int
}

extension UserRegisterResponse: Decodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case data
        case success
        case responseCode
    }
}

public struct UserRegister {
    let user: User
    let verification: Verification
}

extension UserRegister: Decodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case user
        case verification
    }
}

public struct UserRegisterDemo {
    let user: User
}

extension UserRegisterDemo: Decodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case user
    }
}

public struct LogoutResponse: Decodable, Encodable {
    let data: String
    let success: Bool
    let responseCode: Int
}
