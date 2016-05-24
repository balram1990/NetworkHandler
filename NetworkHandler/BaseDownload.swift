//
//  BaseDownload.swift
//  NetworkHandler
//
//  Created by Balram Singh on 14/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

protocol BaseDownload {
    func download(file : File)
    func pauseDownload(file : File)
    func cancelDownload (file : File)
    func resumeDownload (file : File)
}