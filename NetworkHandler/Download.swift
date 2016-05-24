//
//  Download.swift
//  NetworkHandler
//
//  Created by Balram Singh on 14/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

class Download: NSObject {
    var url : String?
    var isDownloading = false
    var progress : Float = 0.0
    var downlaodTask : NSURLSessionDownloadTask?
    var resumeData : NSData?
    
    init(url : String) {
        self.url = url
    }
}
