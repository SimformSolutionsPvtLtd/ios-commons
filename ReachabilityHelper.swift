//
//  ReachabilityHelper.swift
//
//  Created by Harit Kothari on 12/10/16.
//  Copyright © 2016 Simform. All rights reserved.
//

import UIKit
import ReachabilitySwift

class ReachabilityHelper: NSObject {
    override private init() { }
    let reachability = Reachability(hostname: serverBaseURL)

    static let sharedInstance : ReachabilityHelper = {
        let instance = ReachabilityHelper()
        return instance
    }()
    
    func startMonitoring() {
        do {
            try reachability?.startNotifier()
        } catch {
            DLog(message: "could not start reachability notifier")
        }
    }
    
    func stopMonitoring() {
        reachability?.stopNotifier()
    }
}
