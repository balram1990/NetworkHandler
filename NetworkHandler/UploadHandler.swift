//
//  UploadHandler.swift
//  NetworkHandler
//
//  Created by Balram Singh on 24/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

class UploadHandler: NSObject, BaseUpload, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    
    var activeUploads = [String : Upload]()
    
    lazy var uploadSession : NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    override init() {
        super.init()
        _ = self.uploadSession
    }
    
    func upload(file: UploadFile) {
        let uploadURL =  NSURL(string : ViewController.UploadURL)
        let anUpload = Upload(url: uploadURL!, data: file.fileData, fileID: file.fileID)
        let upload_File_Req: NSMutableURLRequest = NSMutableURLRequest(URL: uploadURL!)
        upload_File_Req.HTTPMethod = "POST"
        upload_File_Req.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        upload_File_Req.setValue(file.filePath!, forHTTPHeaderField: "FilePath")
        //set it to particular location
        upload_File_Req.setValue("9314", forHTTPHeaderField: "UserID")
        upload_File_Req.setValue("28516", forHTTPHeaderField: "ComputerID")
        //
        upload_File_Req.setValue(file.shouldKeepInCloud, forHTTPHeaderField: "KeepCopyInCloud")
        upload_File_Req.setValue(file.fileID, forHTTPHeaderField: "FileID")
        upload_File_Req.setValue(file.fileUplaodID, forHTTPHeaderField: "FileUploadID")
        upload_File_Req.setValue(file.completeServerPath, forHTTPHeaderField: "CompleteFilePath")

        upload_File_Req.setValue("\(file.fileSize)", forHTTPHeaderField: "FileSize")
        let fileData = file.fileData
        anUpload.uploadTask = uploadSession.uploadTaskWithRequest(upload_File_Req, fromData: fileData!)
        anUpload.taskIndentifier = (anUpload.uploadTask?.taskIdentifier)!
        anUpload.uploadTask?.resume()
        anUpload.isUploading =  true
        activeUploads[anUpload.fileID!] = anUpload
    }
    
    func cancelUpload(file: UploadFile) {
//        //Get the object object corresponsind to file
//        if let urlString = file.url , anUpload = activeUploads[urlString] {
//            //cancel download
//            anUpload.uploadTask?.cancel()
//            //remove the downlaod object from active downlaods
//            activeUploads[urlString] =  nil
//        }
    }
    
    func resumeUpload(file: UploadFile) {
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        print("error : \(error)")
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, needNewBodyStream completionHandler: (NSInputStream?) -> Void) {
        if let fileURL = NSBundle.mainBundle().URLForResource("image", withExtension: "jpg"),
            path = fileURL.path,
            inputStream = NSInputStream(fileAtPath: path)
        {
            
            completionHandler(inputStream)
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = totalBytesSent/totalBytesExpectedToSend
        print("Progress : \(progress) made in task indentifer : \(task.taskIdentifier)")
    }
    
    
    //MARK: NSURLSeesionDelegate
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler()
                })
            }
        }
    }

}
