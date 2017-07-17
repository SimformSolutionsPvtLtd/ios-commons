//
//  FirebaseAnalyticsHelper.swift
//
//  Created by Harit Kothari on 24/10/16.
//  Copyright © 2016 Simform. All rights reserved.
//

import UIKit
import Crashlytics
import Localytics

struct ParamKeys {
    static let kVersion = "Version"
    static let kPlatform = "Platform"
    static let kIsSuccess = "isSuccess"
    static let kMessage = "Message"
    
    static let kUser = "User"
    static let kCode = "Code"
    
    static let kPlaceName = "Place Name"
    static let kPlaceType = "Place Type"
    
    static let kLocationLatitude = "Latitude"
    static let kLocationLongitude = "Longitude"
    
    static let kReviewStar = "Review Star"
    static let kReviewTitle = "Review Title"
    
    static let kType = "Type"
    
    static let kTotalPoints = "Total Points"
    static let kTotalReedemed = "Total Reedemed"
    static let kTotalEarned = "Total Earned"
    
    static let kTrophyEarned = "Trophy Earned"

}

struct ParamValues {
    static let kSuccess = "Success"
    static let kFailure = "Failure"
    
    static let kFacebook = "Facebook"
    static let kTwitter = "Twitter"
    static let kInstagram = "Instagram"
    
    static let kAppInvite = "App Invite"
}

struct EventKeys {
    static let kLogin = "Login"
    static let kShare = "Share"
    static let kCheckIn = "Check in"
    static let kLike = "Like"
    static let kPostReview = "Post Review"
    static let kPlaceSuggestion = "Place Suggestion"
    static let kInvite = "Invite"
    static let kPoints = "Points"
    static let kTrophy = "Trophy"
}

class AnalyticsHelper: NSObject {
    override private init() { }
    
    static let sharedInstance : AnalyticsHelper = {
        let instance = AnalyticsHelper()
        return instance
    }()
    
    func logEvent(eventType:String, params:Dictionary<String, NSObject>?) {
        // FIRAnalytics.logEvent(withName: eventType, parameters:params)
        
        Answers.logCustomEvent(withName: eventType, customAttributes: params)
        var localyticsDict:Dictionary<String, String> = [:]
        for key in (params?.keys)! {
            localyticsDict[key] = "\((params?[key])!)"
        }
        Localytics.tagEvent(eventType, attributes: localyticsDict)
    }
    
    func logAppOpen() {
        // FIRAnalytics.logEvent(withName: kFIREventAppOpen, parameters: nil)
    }
}
