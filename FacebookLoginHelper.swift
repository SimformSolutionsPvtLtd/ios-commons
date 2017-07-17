//
//  FacebookLoginHelper.swift
//
//  Created by Harit Kothari on 07/10/16.
//  Copyright © 2016 Simform. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON

struct FacebookUserData {
    let firstName: String
    let lastName: String
    let email: String
    let userID: String
    let profilePicURL:String?
    let dateOfBirth:Date?
}

class FacebookLoginHelper: NSObject {
    typealias FacebookLoginResult = (_ isSuccess:Bool, _ error:Error?) -> ()
    typealias FacebookUserDataFetchResult = (_ userData:FacebookUserData?, _ error:Error?) -> ()
    
    let facebookReadPermissions = ["public_profile", "email"]
    
    override private init() { }
    
    static let sharedInstance : FacebookLoginHelper = {
        let instance = FacebookLoginHelper()
        return instance
    }()
    
    var lastUser:String? = ""
    
    func doLoginWithFacebook(parentVC:UIViewController, completion:@escaping FacebookLoginResult) {
        FBSDKAccessToken.refreshCurrentAccessToken({ (fbConn, obj, error) in
            if (obj != nil) {
                completion(true, nil)
            } else {
                self.proceedLoginFlow(parentVC: parentVC, completion: completion)
            }
        })
        
    }
    
    func proceedLoginFlow(parentVC:UIViewController, completion:@escaping FacebookLoginResult) {
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: self.facebookReadPermissions, from: parentVC) { (loginResult, error) in
            if error != nil {
                // Process error
                self.logoutFromFacebook()
                completion(false, error)
            } else if loginResult!.isCancelled {
                // Handle cancellations
                self.logoutFromFacebook()
                completion(false, nil)
            } else {
                var allPermsGranted = true
                
                let grantedPermissions = loginResult?.grantedPermissions.map( {"\($0)"} )
                for permission in self.facebookReadPermissions {
                    if (grantedPermissions?.contains(permission))! == false {
                        allPermsGranted = false
                        break
                    }
                }
                
                if allPermsGranted {
                    // let fbToken = loginResult?.token.tokenString
                    // let fbUserID = loginResult?.token.userID
                    completion(true, nil)
                } else {
                    let userInfo: [NSObject : AnyObject] =
                        [
                            NSLocalizedDescriptionKey as NSObject :  NSLocalizedString("Permission error", value: "User did not grant required permissions", comment: "") as AnyObject,
                            NSLocalizedFailureReasonErrorKey as NSObject : NSLocalizedString("Permission Error", value: "ser did not grant required permissions", comment: "") as AnyObject
                    ]
                    let err = NSError(domain: CustomErrorDomain.kLoginTypeFBpermission, code: CustomErrorCode.kLoginTypeFBpermission, userInfo: userInfo)
                    
                    completion(false, err)
                    self.logoutFromFacebook()
                }
            }
        }
    }
    
    func logoutFromFacebook() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        FBSDKProfile.setCurrent(nil)
        FBSDKAccessToken.setCurrent(nil)
    }
    
    func getLoggedInUserDetails(completion:@escaping FacebookUserDataFetchResult) {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, last_name, email, picture.type(large)"]).start(completionHandler: { (connection, result, error) -> Void in
            if result != nil {
                let jsonData = JSON(result ?? "")
                if jsonData != nil {
                    let responseData = FacebookUserData(firstName: jsonData["first_name"].stringValue, lastName: jsonData["last_name"].stringValue, email: jsonData["email"].stringValue, userID: jsonData["id"].stringValue, profilePicURL:jsonData["picture"]["data"]["url"].stringValue, dateOfBirth:nil)
                    completion(responseData, nil)
                } else {
                    let userInfo: [NSObject : AnyObject] =
                        [
                            NSLocalizedDescriptionKey as NSObject :  NSLocalizedString("Parsing error", value: "User data parsing error", comment: "") as AnyObject,
                            NSLocalizedFailureReasonErrorKey as NSObject : NSLocalizedString("Parsing Error", value: "User data parsing error", comment: "") as AnyObject
                    ]
                    let err = NSError(domain: CustomErrorDomain.kLoginTypeFBuserDetail, code: CustomErrorCode.kLoginTypeFBuserDetail, userInfo: userInfo)

                    completion(nil, err)
                }
                
                /*
                 do {
                 let json = try JSONSerialization.jsonObject(with: data!, options: [])
                 DLog(message: "json: \(json)")
                 } catch let jsonError as NSError {
                 DLog(message: "json error: \(jsonError.localizedDescription)")
                 }
                 */
            } else {
                completion(nil, error)
            }
        })
    }
}
