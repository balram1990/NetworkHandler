//
//  UploadHandler.swift
//  NetworkHandler
//
//  Created by Balram Singh on 24/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

class UploadHandler: NSObject, BaseUpload {
    
    var activeUploads = [String : Upload]()
    
    lazy var uploadSession : NSURLSession = {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("bgUploadSessionConfiguration")
        let session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        return session
    }()
    
    override init() {
        super.init()
        _ = self.uploadSession
    }
    
    func upload(file: UploadFile) {
        if let urlString = file.url, dataToUpload = file.data, url = NSURL(string : urlString) {
            let anUpload = Upload(url: urlString, data: dataToUpload)
            let request = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 10)
            anUpload.uploadTask = uploadSession.uploadTaskWithRequest(request, fromData: dataToUpload)
            anUpload.uploadTask?.resume()
            anUpload.isUploading =  true
            activeUploads[anUpload.url!] = anUpload
        }
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
    
    
}
