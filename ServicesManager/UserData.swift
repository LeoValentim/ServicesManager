//
//  UserData.swift
//  ServicesManager
//
//  Created by Megaleios DEV on 18/12/17.
//  Copyright © 2017 Megaleios. All rights reserved.
//

import Foundation

public class UserData {
    
    // Singleton
    public static func shared() -> UserData {
        return UserData()
    }
    
    private init() {
        print("Framework instance test")
    }
    
    public func test() {
        print("Printando via framework")
    }
}
