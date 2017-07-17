//
//  PermissionHelper.swift
//
//  Created by Harit Kothari on 16/12/16.
//  Copyright © 2016 Simform. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class PermissionHelper: NSObject {
    typealias PermissionResult = (_ result:Bool, _ message:String?, _ error:Error?) -> ()
    
    override private init() { }
    
    static let sharedInstance : PermissionHelper = {
        let instance = PermissionHelper()
        return instance
    }()
    
    func checkPhotoLibraryPermission(completion:@escaping PermissionResult) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: //handle authorized status
            completion(true, "", nil)
            
        case .denied, .restricted: //handle denied status
            completion(false, "", nil)
            
        case .notDetermined: // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    completion(true, "", nil)
                    
                case .denied, .restricted:
                    completion(false, "", nil)
                    
                case .notDetermined:
                    // won't happen but still
                    completion(false, "not determined", nil)
                }
            }
        }
    }
    
    func checkCameraPermission(completion:@escaping PermissionResult) {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized
        {
            // Already Authorized
            completion(true, "", nil)
        }
        else
        {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
                if granted == true
                {
                    // User granted
                    completion(true, "", nil)
                }
                else
                {
                    // User Rejected
                    completion(false, "", nil)
                }
            })
        }
    }
}
