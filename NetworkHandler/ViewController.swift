//
//  ViewController.swift
//  NetworkHandler
//
//  Created by Balram Singh on 14/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UploadHandlerDelegate {

    static let UploadURL = "https://www.test-basefolder.com/BaseFolderMobileRestService/MobileUploads.svc/UploadFileWithStream"
    static let UploadQueryURL = "https://www.test-basefolder.com/BaseFolderMobileRestService/MobileUploads.svc/InsertUploadRequest"
    static let CheckFileAlreadyInUpload = "https://www.test-basefolder.com/BaseFolderMobileRestService/MobileUploads.svc/CheckFileExistsInUploads"
    
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progress3: UIProgressView!
    @IBOutlet weak var progress2: UIProgressView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        initiateUploadRequestForFile("song_1", type: "mp3", keepInCloud: "True")
//        initiateUploadRequestForFile("song", type: "mp3", keepInCloud: "True")
//        initiateUploadRequestForFile("new_song", type: "mp3", keepInCloud: "True")
        
        checkWhetherUploadAlreadyExist("song_1", type: "mp3", fileUploadID: "51414")
    }
    
    func uploadFile (file : UploadFile) {
        let handler = UploadHandler()
        handler.delegate = self
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
                    print("FileName: \(uploadItem.name! + uploadItem.type!), fileUploadID: \(uploadItem.fileUplaodID)")
                    uploadItem.canBeShared  = json!["CanBeShared"] as? String
                    self.uploadFile(uploadItem)
                } else {
                    print("Upload initiation failed : %@", json!["ReturnMsg"])
                }
            }
        }
    }
    
    func checkWhetherUploadAlreadyExist (name : String, type : String, fileUploadID : String) {
        let uploadItem = UploadFile()
        uploadItem.name =  name
        uploadItem.type = type
        let json = [
            "FileName" : name + "." + type,
            "FileUploadID" : fileUploadID
        ]
        NetworkIO().post(ViewController.CheckFileAlreadyInUpload, json: json) { (data, response, error) in
            if let _ = error {
                print("Could not determince status")
                return
            }
            var jsonResponse: NSDictionary? = nil
            do  {
                jsonResponse = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
            } catch {
                print("Something went wrong while parsing JSON")
                return
            }
            var offset : String?
            if let _ = jsonResponse {
                if jsonResponse!["ReturnStatus"] as? String == "0" {
                     offset = jsonResponse!["FileSize"] as? String
                }
            }
            print("Offset: \(offset)")
            
        }
    }
    
    //MARK: UploadHandlerDelegate 
    func uploadDidMakeProgress(progress: Float, file: UploadFile?) {
        dispatch_async(dispatch_get_main_queue()) {
            if file?.name == "song_1"{
                self.progressBar.progress = progress
            }else if file?.name == "song" {
                self.progress3.progress = progress
            } else if file?.name == "new_song" {
                self.progress2.progress = progress
            }
            
            
        }
    }
    
    func uploadDidCompleteWithError(error: NSError?, file: UploadFile?) {
        print("Upload complete with error: \(error)")
    }
    
}

