//
//  NetworkManager.swift
//  dancereality
//
//  Created by Saad Khalid on 02.08.22.
//
import Foundation
import UIKit

public class NetworkManager {
    
    public static func loadDanceTypes(withCompletion completion: @escaping ([DanceTypeModel]?) -> Void) {
        let url = URL(string: AppModel.serverURL + "/dance-types-mob")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) -> Void in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let wrapper = try? JSONDecoder().decode(DanceTypeResponse.self, from: data)
            DispatchQueue.main.async { completion(wrapper?.data) }
        }
        task.resume()
    }
    
    public static func loadDanceMove(id: Int, withCompletion completion: @escaping (DanceMoveModel?) -> Void) {
        let url = URL(string: AppModel.serverURL + "/moves-mob/"+String(id))!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) -> Void in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            do {
                let wrapper = try JSONDecoder().decode(DanceResponse.self, from: data)
                DispatchQueue.main.async { completion(wrapper.data) }
            } catch let error as NSError {
                DispatchQueue.main.async { completion(nil) }
                print(error)
            }
        }
        task.resume()
    }
    
    public static func registerUserRequest(user: User,completion: @escaping (UserRegister?) -> Void){
        let urlPath: String = AppModel.serverURL + "/register"
        let url = URL(string: urlPath)!
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the
        request.httpMethod = "POST"
        do{
            let params = try JSONEncoder.init().encode(user)
            request.httpBody = params
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
                guard let data = data else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                do {
                    let wrapper = try JSONDecoder().decode(UserRegisterResponse.self, from: data)
                    FileHelper.saveObjectToUserRegisterDefaults(object: wrapper.data, key: "USER_REGISTER")
                    DispatchQueue.main.async { completion(wrapper.data) }
                } catch {
                    DispatchQueue.main.async { completion(nil) }
                }
            }
            task.resume()
        } catch {
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    public static func loginRequest(email: String, password: String, completion: @escaping (LoginPassed?) -> Void){
        let urlPath: String = AppModel.serverURL + "/login"
        let url = URL(string: urlPath)!
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the
        request.httpMethod = "POST"
        let requestData: [String: String] = ["email": email, "password": password]
        do{
            let params = try JSONEncoder.init().encode(requestData)
            request.httpBody = params
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
                guard let data = data else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                do {
                    let wrapper = try JSONDecoder().decode(LoginPassed.self, from: data)
                    FileHelper.saveObjectToUserDefaults(object: wrapper.data, key: "USER")
                    DispatchQueue.main.async { completion(wrapper) }
                } catch {
                    DispatchQueue.main.async { completion(nil) }
                }
            }
            task.resume()
        } catch {
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    public static func logout(withCompletion completion: @escaping (LogoutResponse?) -> Void) {
        let url = URL(string: AppModel.serverURL + "/logout")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let wrapper = try? JSONDecoder().decode(LogoutResponse.self, from: data)
            DispatchQueue.main.async { completion(wrapper) }
        }
        task.resume()
    }
    
    public static func avatarUpdateRequest(avatarId: Int, speed: Double, completion: @escaping (AvatarModelUpdate?) -> Void){
        let urlPath: String = AppModel.serverURL + "/avatar/" + String(avatarId)
        let url = URL(string: urlPath)!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        let boundary = Boundary
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        guard let data = textFormField(speed: speed, validity: true, boundry: boundary) else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        request.httpBody = data as Data
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            do {
                let wrapper = try JSONDecoder().decode(AvatarModelUpdateRequest.self, from: data)
                DispatchQueue.main.async { completion(wrapper.data) }
            } catch {
                DispatchQueue.main.async { completion(nil) }
            }
        }
        task.resume()
        
    }
    
    public static func predictDanceMove(danceTypeName: String, danceMoveName: String, direction: String, data:[[Double]], completion: @escaping (PredictionModelResponse?) -> Void){
        let danceMoveNameFormatted = StringHelper.reFormatString(valueToFormat: danceMoveName)
        let danceTypeNameFormatted = StringHelper.reFormatString(valueToFormat: danceTypeName)
        let urlPath: String = AppModel.serverURL + "/predict/" + danceTypeNameFormatted.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! + "/" +
        danceMoveNameFormatted.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! + "/" + direction.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlPath)!
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
        request.httpMethod = "POST"
        do{
            let reqData: [String: [[Double]]] = ["data": data]
            let params = try JSONEncoder.init().encode(reqData)
            request.httpBody = params
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
                guard let data = data else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                do {
                    let wrapper = try JSONDecoder().decode(PredictionModelResponse.self, from: data)
                    DispatchQueue.main.async { completion(wrapper) }
                } catch {
                    DispatchQueue.main.async { completion(nil) }
                }
            }
            task.resume()
            
        } catch {
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    public static func predictDanceMoveFeedback(hash: String, feedback: String, completion: @escaping (FeedBackResponseModel?) -> Void){
        let urlPath: String = AppModel.serverURL + "/feedback"
        let url = URL(string: urlPath)!
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
        request.httpMethod = "POST"
        do{
            let reqData: [String: String] = ["hash": hash, "feedback": feedback, "device_ID": UIDevice.current.identifierForVendor!.uuidString]
            let params = try JSONEncoder.init().encode(reqData)
            request.httpBody = params
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
                guard let data = data else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                do {
                    let wrapper = try JSONDecoder().decode(FeedBackResponseModel.self, from: data)
                    DispatchQueue.main.async { completion(wrapper) }
                } catch {
                    DispatchQueue.main.async { completion(nil) }
                }
            }
            task.resume()
            
        } catch {
            DispatchQueue.main.async { completion(nil) }
        }
    }
}

var Boundary: String {
    return "Boundary-\(UUID().uuidString)"
}

private func textFormField(speed: Double, validity: Bool, boundry: String) -> Data? {
    var body = ""
    body += "--\(boundry)\r\n"
    body += "Content-Disposition:form-data; name=\"validity\""
    body += "\r\n\r\n\(validity)\r\n"
    body += "--\(boundry)\r\n"
    body += "Content-Disposition:form-data; name=\"speed\""
    body += "\r\n\r\n\(speed)\r\n"
    body += "--\(boundry)--\r\n"
    return body.data(using: .utf8)
}
