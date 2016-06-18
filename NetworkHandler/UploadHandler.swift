//
//  UploadHandler.swift
//  NetworkHandler
//
//  Created by Balram Singh on 24/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

class UploadHandler: NSObject, BaseUpload, NSURLSessionDelegate, NSURLSessionStreamDelegate {
    
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
        if let urlString = file.url, url = NSURL(string : urlString) {
            let anUpload = Upload(url: urlString, data: file.data!)
            let upload_File_Req: NSMutableURLRequest = NSMutableURLRequest(URL: url)
            upload_File_Req.HTTPMethod = "POST"
            upload_File_Req.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            upload_File_Req.setValue("image_new.jpg", forHTTPHeaderField: "FilePath")
            upload_File_Req.setValue("9314", forHTTPHeaderField: "UserID")
            upload_File_Req.setValue("28516", forHTTPHeaderField: "ComputerID")
            upload_File_Req.setValue("True", forHTTPHeaderField: "KeepCopyInCloud")
            
            upload_File_Req.setValue("1035198", forHTTPHeaderField: "FileID")
            upload_File_Req.setValue("44426", forHTTPHeaderField: "FileUploadID")
            upload_File_Req.setValue("C:\\BaseFolder\\BaseFolderWebApp_Publish\\CloudFiles\\28516\\image_new.jpg", forHTTPHeaderField: "CompleteFilePath")

            let fileURL = NSBundle.mainBundle().URLForResource("image_new", withExtension: "jpg")
            let sourcePath = NSBundle.mainBundle().pathForResource("image_new", ofType: "jpg")
            let size = sizeForLocalFilePath(sourcePath!)
            upload_File_Req.setValue("\(size)", forHTTPHeaderField: "FileSize")
            let fileData = NSData(contentsOfURL: fileURL!)
            //let bodyStream = NSInputStream.init(data: fileData!)
            //bodyStream!.setProperty(0, forKey: NSStreamFileCurrentOffsetKey)
            //upload_File_Req.HTTPBodyStream  = bodyStream
            anUpload.uploadTask = uploadSession.uploadTaskWithRequest(upload_File_Req, fromData: fileData!)
            anUpload.uploadTask?.resume()
            anUpload.isUploading =  true
            activeUploads[anUpload.url!] = anUpload
        }
    }
    
    func sizeForLocalFilePath(filePath:String) -> Int {
        do {
            let fileAttributes = try NSFileManager().attributesOfItemAtPath(filePath)
            if let fileSize = fileAttributes[NSFileSize] as? NSNumber {
                return fileSize.integerValue
            } else {
                print("Failed to get a size attribute from path: \(filePath)")
            }
        } catch {
            print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
        }
        return 0
    }
    
    func cancelUpload(file: UploadFile) {
        //Get the object object corresponsind to file
        if let urlString = file.url , anUpload = activeUploads[urlString] {
            //cancel download
            anUpload.uploadTask?.cancel()
            //remove the downlaod object from active downlaods
            activeUploads[urlString] =  nil
        }
    }
    
    func resumeUpload(file: UploadFile) {
        
    }
    
    
    //MARK: URLSessionDelegate
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        // 1
        if let originalURL = downloadTask.originalRequest?.URL?.absoluteString,
            destinationURL = Util.localFilePathForUrl(originalURL) {
            
            print(destinationURL)
            
            // 2
            let fileManager = NSFileManager.defaultManager()
            do {
                try fileManager.removeItemAtURL(destinationURL)
            } catch {
                // Non-fatal: file probably doesn't exist
            }
            do {
                try fileManager.copyItemAtURL(location, toURL: destinationURL)
            } catch let error as NSError {
                print("Could not copy file to disk: \(error.localizedDescription)")
            }
        }
        
        // 3
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            activeUploads[url] = nil
            //inform delegte that downlaoding is finished
            //            if let trackIndex = trackIndexForDownloadTask(downloadTask) {
            //                dispatch_async(dispatch_get_main_queue(), {
            //                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: trackIndex, inSection: 0)], withRowAnimation: .None)
            //                })
            //            }
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("Task Description : \(downloadTask.taskDescription)")
            }
    
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        print("error : \(error)")
    }
    
    func URLSession(session: NSURLSession, writeClosedForStreamTask streamTask: NSURLSessionStreamTask) {
    }
    
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, needNewBodyStream completionHandler: (NSInputStream?) -> Void) {
        if let fileURL = NSBundle.mainBundle().URLForResource("image", withExtension: "jpg"),
            path = fileURL.path,
            inputStream = NSInputStream(fileAtPath: path)
        {
            
            completionHandler(inputStream)
        }
        
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
