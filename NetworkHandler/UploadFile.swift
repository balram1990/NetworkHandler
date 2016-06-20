//
//  UploadFile.swift
//  NetworkHandler
//
//  Created by Balram Singh on 24/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

class UploadFile: NSObject {
    var filePath : String?
    var name : String?
    var type : String?
    var shouldKeepInCloud = "False"
    var completeServerPath : String?
    var fileID : String?
    var fileUplaodID : String?
    var canBeShared : String?
    lazy var fileSize : Int = {
        let filePath = NSBundle.mainBundle().pathForResource(self.name, ofType: self.type)
        if let _ = filePath {
            do {
                let fileAttributes = try NSFileManager().attributesOfItemAtPath(filePath!)
                if let fileSize = fileAttributes[NSFileSize] as? NSNumber {
                    return fileSize.integerValue
                } else {
                    print("Failed to get a size attribute from path: \(filePath)")
                }
            } catch {
                print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
            }
        }
        return 0
    }()
    
    lazy var fileData : NSData? = {
        if let _ = self.name, _ = self.type {
            let fileURL = NSBundle.mainBundle().URLForResource(self.name!, withExtension: self.type)
            if let _ = fileURL {
                let data = NSData(contentsOfURL: fileURL!)
                return data
            }
            return nil
        }
        return nil
    }()
}
