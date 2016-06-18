//
//  ViewController.swift
//  NetworkHandler
//
//  Created by Balram Singh on 14/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        uploadAFile()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func someTask(){
        let networkIO = NetworkIO()
        
        let json =  ["DeviceID" : "12345", "MACAdress" : "1471414"]
        networkIO.post("/MountainPowerRestService/SecurityInfo.svc/InsertSecurityInfo", json: json) { (data, response, error) in
            print("\(data), response :\(response)")
        }
    }
    
    func uploadAFile () {
    
        let uploadHanlder = UploadHandler()
        let uploadfile = UploadFile()
        uploadfile.name = "Myfile.PNG"
        uploadfile.url = "https://www.test-basefolder.com/BaseFolderMobileRestService/MobileUploads.svc/UploadFileWithStream"
        uploadfile.data  = UIImagePNGRepresentation(UIImage(named: "Icn")!)
        uploadHanlder.upload(uploadfile)
        
    }
}

