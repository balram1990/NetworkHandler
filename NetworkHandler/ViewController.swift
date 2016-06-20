//
//  ViewController.swift
//  NetworkHandler
//
//  Created by Balram Singh on 14/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    static let UploadURL = "https://www.test-basefolder.com/BaseFolderMobileRestService/MobileUploads.svc/UploadFileWithStream"
    static let UploadQueryURL = "https://www.test-basefolder.com/BaseFolderMobileRestService/MobileUploads.svc/InsertUploadRequest"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initiateUploadRequestForFile("song_1", type: "mp3", keepInCloud: "True")
        initiateUploadRequestForFile("song", type: "mp3", keepInCloud: "True")
        initiateUploadRequestForFile("new_song", type: "mp3", keepInCloud: "True")
        
    }
    
//    func someTask(){
//        let networkIO = NetworkIO()
//        
//        let json =  ["DeviceID" : "12345", "MACAdress" : "1471414"]
//        networkIO.post("/MountainPowerRestService/SecurityInfo.svc/InsertSecurityInfo", json: json) { (data, response, error) in
//            print("\(data), response :\(response)")
//        }
//    }
    
    func uploadFile (file : UploadFile) {
        let handler = UploadHandler()
        handler.upload(file)
    }
    
    func initiateUploadRequestForFile(name : String, type : String, keepInCloud : String) {
        //create an uplaod item
        let uploadItem = UploadFile()
        uploadItem.name =  name
        uploadItem.type = type
        uploadItem.shouldKeepInCloud = keepInCloud
        let dictionary = [
            "FilePath" : name + "." + type,
            "UserID" : "9314",
            "ComputerID":"28516",
            "KeepCopyInCloud": keepInCloud,
            "FileSize": String(format: "%d", uploadItem.fileSize)
        ]
        NetworkIO().post(ViewController.UploadQueryURL, json: dictionary) { (data, response, error) in
            if let _ = error {
                print("Problem while placing upload request")
                return
            }
            var json: NSDictionary? = nil
            do  {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
            } catch {
                print("Something went wrong while parsing JSON")
                return
            }
            if let _ = json {
                //check upload response
                if "0" == json!["ReturnStatus"] as? String {
                    uploadItem.filePath = json!["File"] as? String
                    uploadItem.completeServerPath = json!["FilePath"] as? String
                    uploadItem.fileID = json!["FileID"] as? String
                    uploadItem.fileUplaodID = json!["FileUploadID"] as? String
                    uploadItem.canBeShared  = json!["CanBeShared"] as? String
                    self.uploadFile(uploadItem)
                } else {
                    print("Upload initiation failed : %@", json!["ReturnMsg"])
                }
            }
        }
    }
}

