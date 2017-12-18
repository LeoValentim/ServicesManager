//
//  UserData.swift
//  ServicesManager
//
//  Created by Megaleios DEV on 18/12/17.
//  Copyright © 2017 Megaleios. All rights reserved.
//

import Foundation
import JWTDecode
import Alamofire

enum CustomError {
    case userNotLoggedIn, unknownError
}

public class TokenResult {
    init(_ :CustomError, _ :String) {
        
    }
}

protocol ResultProtocol: Codable {
    var erro : Bool? { get }
    var message : String? { get }
}

struct ResultToken: ResultProtocol, Codable {
    let data : ResultAcessToken?
    let erro : Bool?
    let message : String?
}
struct ResultAcessToken: Codable {
    let access_token : String?
    let refresh_token : String?
}

public class UserData {
    
    // Singleton
    static let sharedInstance = UserData()
    // Constructor
    private init(){}
    
    public var apiEndPoint: String = ""
    public var accessToken: JWT!
    public var refreshToken: JWT!
    
    func isLoggedIn() -> Bool {
        if UserDefaults.standard.object(forKey: "accessToken") != nil {
            return true
        } else {
            return false
        }
    }
    
    func setToken(accessToken: String?, refreshToken: String?) {
        print("setando token!!")
        UserDefaults.standard.set(accessToken, forKey: "accessToken")
        UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
    }
    
    func setSelectedProfile(id: String?) {
        print("setting selected profile id: \(String(describing: id))")
        UserDefaults.standard.set(id, forKey: "selectedProfile")
    }
    
    func getSelectedProfile() -> String? {
        return UserDefaults.standard.object(forKey: "selectedProfile") as? String
    }
    
    func getSavedToken() -> String {
        return UserDefaults.standard.object(forKey: "accessToken") as! String
    }
    
    func getToken(completed: @escaping (CustomError?, String) -> Void) {
        
        do {
            guard let token = UserDefaults.standard.object(forKey: "accessToken") as? String else {
                print("Nao esta logado. Erro.")
                completed(CustomError.userNotLoggedIn, "")
                return
            }
            
            let refToken = UserDefaults.standard.object(forKey: "refreshToken") as! String
            
            self.accessToken = try decode(jwt: token)
            self.refreshToken = try decode(jwt: refToken)
            
            let currentAccessToken = self.accessToken.string
            let currentRefreshToken = self.refreshToken.string
            
            if !self.accessToken.expired {
                //Normal
                print("token esta ok")
                completed(nil, currentAccessToken)
            } else if self.accessToken.expired {
                //Faz logoff
                print("token expirado. renovando...")
                
                let refreshTokenEndpoint = URL(string: "\(self.apiEndPoint)/api/v1/Profile/token")!
                
                let params: Parameters = [
                    "refresh_token": currentRefreshToken
                ]
                
                print(refreshTokenEndpoint)
                print(params)
                
                Alamofire.request(refreshTokenEndpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                    
                    print("statusCode: \(String(describing: response.response?.statusCode))")
                    
                    if let statusCode = response.response?.statusCode {
                        if statusCode == 400 {
                            completed(CustomError.userNotLoggedIn, "")
                            return
                        }
                    }
                    
                    if let data = response.data {
                        do {
                            let json = try JSONDecoder().decode(ResultToken.self, from: data)
                            if let newToken = json.data?.access_token, let refreshTkn = json.data?.refresh_token {
                                self.setToken(accessToken: newToken, refreshToken: refreshTkn)
                                completed(nil, newToken)
                            } else {
                                //error
                                self.logout()
                                completed(CustomError.userNotLoggedIn, "")
                            }
                        } catch {
                            print("Exception:\(error)")
                            self.logout()
                            completed(CustomError.userNotLoggedIn, "")
                        }
                    }
                }
                
            }
            
        } catch {
            print("Failed to decode JWT: \(error)")
            completed(CustomError.unknownError, "")
        }
        
        
    }
    
    func logout() {
        print("logging out")
        setToken(accessToken: nil, refreshToken: nil)
        setSelectedProfile(id: nil)
    }
    
    private func clear() {
        accessToken = nil
        refreshToken = nil
    }
    
}
