//
//  BaseUpload.swift
//  NetworkHandler
//
//  Created by Balram Singh on 24/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

protocol BaseUpload {
    func upload(file : UploadFile)
    func cancelUpload (file : UploadFile)
    func resumeUpload (file : UploadFile)
}