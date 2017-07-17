//
//  TwitterLoginHelper.swift
//
//  Created by Harit Kothari on 07/10/16.
//  Copyright © 2016 Simform. All rights reserved.
//

import UIKit
import TwitterKit
import SwiftyJSON


struct TwitterUserData {
    let firstName: String
    let lastName: String
    let email: String
    let userID: String
    let profilePicURL:String?
    let dateOfBirth:Date?
}

class TwitterLoginHelper: NSObject {
    typealias TwitterLoginResult = (_ isSuccess:Bool, _ error:Error?) -> ()
    typealias TwitterUserDataFetchResult = (_ userData:TwitterUserData?, _ error:Error?) -> ()
    
    
    override private init() { }
    
    static let sharedInstance : TwitterLoginHelper = {
        let instance = TwitterLoginHelper()
        return instance
    }()
    
    var lastUser:String? = ""
    
    func doLoginWithTwitter(completion:@escaping TwitterLoginResult) {
        Twitter.sharedInstance().logIn(withMethods: [.webBased]) { (session, error) in
            if (session != nil) {
                DLog(message:"signed in as \(session?.userName)");
                self.lastUser = session?.userID
                completion(true, nil)
            } else {
                DLog(message:"error: \(error?.localizedDescription)")
                completion(false, error)
            }
        }
        
        
        /*
         Twitter.sharedInstance().logIn { session, error in
         if (session != nil) {
         DLog(message:"signed in as \(session?.userName)");
         self.lastUser = session?.userID
         } else {
         DLog(message:"error: \(error?.localizedDescription)");
         }
         }
         */
    }
    
    func getLoggedInUserDetails(completion:@escaping TwitterUserDataFetchResult) {
        let store = Twitter.sharedInstance().sessionStore
        // let userID = store.session()?.userID
        
        if store.session(forUserID: self.lastUser!) != nil   {
            let client = TWTRAPIClient.withCurrentUser()
            let request = client.urlRequest(withMethod: "GET", url: "https://api.twitter.com/1.1/account/verify_credentials.json", parameters: ["include_email": "true", "skip_status": "true"], error: nil)
            
            client.sendTwitterRequest(request, completion: { (response, data, error) in
                DLog(message: "\(data) \(response) \(error)")
                if data != nil {
                    let jsonData = JSON(data:data!)
                    if jsonData != nil {
                        let responseData = TwitterUserData(firstName: jsonData["name"].stringValue, lastName: "", email: jsonData["email"].stringValue, userID: jsonData["id"].stringValue, profilePicURL: jsonData["profile_image_url"].stringValue, dateOfBirth: nil)
                        completion(responseData, nil)
                    } else {
                        let userInfo: [NSObject : AnyObject] =
                            [
                                NSLocalizedDescriptionKey as NSObject :  NSLocalizedString("Parsing error", value: "User data parsing error", comment: "") as AnyObject,
                                NSLocalizedFailureReasonErrorKey as NSObject : NSLocalizedString("Parsing Error", value: "User data parsing error", comment: "") as AnyObject
                        ]
                        let err = NSError(domain: CustomErrorDomain.kLoginTypeTwitterUserDetail, code: CustomErrorCode.kLoginTypeTwitterUserDetail, userInfo: userInfo)
                        
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
            
        } else {
            let userInfo: [NSObject : AnyObject] =
            [
                    NSLocalizedDescriptionKey as NSObject :  NSLocalizedString("Unauthorized", value: "User no ogged in", comment: "") as AnyObject,
                    NSLocalizedFailureReasonErrorKey as NSObject : NSLocalizedString("Unauthorized", value: "User no ogged in", comment: "") as AnyObject
            ]
            let err = NSError(domain: "ShiploopHttpResponseErrorDomain", code: 401, userInfo: userInfo)
            
            completion(nil, err)
        }
    }
    
    func logoutFromTwitter() {
        // Looks like Method2 is not working properly
        // Method 1
        let url:URL = URL.init(string: "https://api.twitter.com")!
        let cookies = HTTPCookieStorage.shared.cookies(for: url)
        for cookie in cookies! {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
        
        // Method 2
        Twitter.sharedInstance().sessionStore.logOutUserID(lastUser!)
    }
}
