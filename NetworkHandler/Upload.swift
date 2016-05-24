//
//  Upload.swift
//  NetworkHandler
//
//  Created by Balram Singh on 24/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

class Upload: NSObject {

    var url : String?
    var isUploading = false
    var progress : Float = 0.0
    var uploadTask : NSURLSessionUploadTask?
    var resumeData : NSData?
    var data : NSData?
    init(url : String, data : NSData?) {
        self.url = url
        self.data = data
    }
}
