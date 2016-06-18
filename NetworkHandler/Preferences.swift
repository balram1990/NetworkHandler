//
//  Preferences.swift
//  NetworkHandler
//
//  Created by Balram Singh on 25/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

class Preferences: NSObject {
    
    static let kUsername = "USER_NAME"
    static let kEmail = "EMAIL"
    
    static let Defaults = NSUserDefaults.standardUserDefaults()
    
    class func getUsername () -> String? {
        return Defaults.objectForKey(kUsername) as? String
    }

    class func setUsername (username : String) {
        Defaults.setObject(username, forKey: kUsername)
        Defaults.synchronize()
    }
    
    class func setEmail (email : String) {
        Defaults.setObject(email, forKey: kEmail)
        Defaults.synchronize()
    }
    
    class func getEmail () -> String? {
        return Defaults.objectForKey(kEmail) as? String
    }
    
    
    //follow the same approch for any new key
    
}
