//
//  UploadHandler.swift
//  NetworkHandler
//
//  Created by Balram Singh on 24/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

protocol UploadHandlerDelegate {
    func uploadDidMakeProgress(progress : Float, file : UploadFile?)
    func uploadDidCompleteWithError(error : NSError?, file : UploadFile?)
}

class UploadHandler: NSObject, BaseUpload, NSURLSessionDelegate, NSURLSessionTaskDelegate,NSURLSessionStreamDelegate {
    
    var activeUpload : Upload?
    var currentFile : UploadFile?
    var delegate : UploadHandlerDelegate?
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
        //let fileData = file.fileData
        let inputStream = NSInputStream.init(fileAtPath: file.directoryPath!)
        inputStream?.setProperty(0, forKey: NSStreamFileCurrentOffsetKey)
        upload_File_Req.HTTPBodyStream = inputStream
        anUpload.uploadTask = uploadSession.uploadTaskWithStreamedRequest(upload_File_Req)
        anUpload.taskIndentifier = (anUpload.uploadTask?.taskIdentifier)!
        anUpload.uploadTask?.resume()
        anUpload.isUploading =  true
        activeUpload = anUpload
        self.currentFile = file
    }
    
    func cancelUpload(file: UploadFile) {
        //Get the object object corresponsind to file
        if let anUpload = activeUpload {
            //cancel download
            anUpload.uploadTask?.cancel()
            //remove the downlaod object from active downlaods
            activeUpload =  nil
        }
    }
    
    func resumeUpload(file: UploadFile) {
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        self.delegate?.uploadDidCompleteWithError(error, file: currentFile)
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
        let progress = Float(totalBytesSent) / Float((currentFile?.fileSize)!)
        print("progress: \(progress)")
        self.delegate?.uploadDidMakeProgress(progress, file: currentFile)
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
