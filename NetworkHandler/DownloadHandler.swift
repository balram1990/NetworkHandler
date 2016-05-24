//
//  DownloadHandler.swift
//  NetworkHandler
//
//  Created by Balram Singh on 14/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

protocol DownloadHandlerDelegate : class {
    func downloadFinished(file : File)
    func progressUpdate(file : File, progress : Float)
}
class DownloadHandler: NSObject, BaseDownload, NSURLSessionDelegate {
    //initialize empty array of downlaods
    //This array will be synched with Db later
    var activeDownloads = [String : Download]()
    
    lazy var downlaodSession : NSURLSession = {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("bgDownloadSessionConfiguration")
        let session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        return session
    }()
    
    
    override init() {
        super.init()
        _ = self.downlaodSession
    }
    
    func download(file : File) {
        //create donwload object from file
        if let urlString =  file.url, url =  NSURL(string: urlString)  {
            //create download task of downlaod
            let aDownload =  Download(url: urlString)
            aDownload.downlaodTask = downlaodSession.downloadTaskWithURL(url)
            aDownload.downlaodTask?.resume()
            //update downloading status
            aDownload.isDownloading = true
            //add this downloading task to active downloads
            activeDownloads[aDownload.url!] = aDownload
        }
    }
    
    func pauseDownload(file : File) {
        if let urlString = file.url, aDownload = activeDownloads[urlString] {
            if  aDownload.isDownloading {
                //cancel downlaod
                aDownload.downlaodTask?.cancelByProducingResumeData({ (data) in
                    if let _ = data {
                        //save data
                        aDownload.resumeData = data
                    }
                })
                //update downloading status
                aDownload.isDownloading = false
            }
        }
    }
    
    func cancelDownload (file : File) {
        //Get the download object corresponsind to file
        if let urlString = file.url , aDownload = activeDownloads[urlString] {
            //cancel download
            aDownload.downlaodTask?.cancel()
            //remove the downlaod object from active downlaods
            activeDownloads[urlString] =  nil
        }
    }
    
    func resumeDownload (file : File) {
        //check whether file is already has some download data
        if let urlString =  file.url, aDownload = activeDownloads[urlString] {
            if let resumeData = aDownload.resumeData {
                //resume download, update downladd status
                aDownload.downlaodTask = downlaodSession.downloadTaskWithResumeData(resumeData)
                aDownload.downlaodTask?.resume()
                aDownload.isDownloading = true
            } else if let url = NSURL(string : aDownload.url!) {
                aDownload.downlaodTask = downlaodSession.downloadTaskWithURL(url)
                aDownload.downlaodTask?.resume()
                aDownload.isDownloading = true
            }
        }
       
        //if no, start a fresh download
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
            activeDownloads[url] = nil
            //inform delegte that downlaoding is finished
//            if let trackIndex = trackIndexForDownloadTask(downloadTask) {
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: trackIndex, inSection: 0)], withRowAnimation: .None)
//                })
//            }
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        // 1
        if let downloadUrl = downloadTask.originalRequest?.URL?.absoluteString,
            download = activeDownloads[downloadUrl] {
            // 2
            download.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            // 3
            let totalSize = NSByteCountFormatter.stringFromByteCount(totalBytesExpectedToWrite, countStyle: NSByteCountFormatterCountStyle.Binary)
            // 4
            
            //inform
//            if let trackIndex = trackIndexForDownloadTask(downloadTask), let trackCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: trackIndex, inSection: 0)) as? TrackCell {
//                dispatch_async(dispatch_get_main_queue(), {
//                    trackCell.progressView.progress = download.progress
//                    trackCell.progressLabel.text =  String(format: "%.1f%% of %@",  download.progress * 100, totalSize)
//                })
//            }
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
