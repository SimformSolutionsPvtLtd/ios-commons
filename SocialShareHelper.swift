//
//  SocialShareHelper.swift
//
//  Created by Harit Kothari on 01/12/16.
//  Copyright © 2016 Simform. All rights reserved.
//

import UIKit
import FBSDKShareKit
import TwitterKit
import MessageUI
import Photos

enum ShareType {
    case image
    case video
    case link
    case any
}

// Custom Activity/action
// https://bjartes.wordpress.com/2015/02/19/creating-custom-share-actions-in-ios-with-swift/

class SocialShareHelper: NSObject {
    override private init() { }
    
    static let sharedInstance : SocialShareHelper = {
        let instance = SocialShareHelper()
        return instance
    }()
    
    // https://developers.facebook.com/docs/sharing/ios
    func shareViaFacebook(parentVC:UIViewController, shareType:ShareType, shareContent:[AnyObject], optionalText:String = "") {
        if shareContent.count < 1 {
            return
        }
        
        var content:FBSDKSharingContent!
        
        switch shareType {
        case .image:
            content = FBSDKShareMediaContent()
            let photo = FBSDKSharePhoto(image: shareContent.first as! UIImage, userGenerated: true)
            (content as? FBSDKShareMediaContent)?.media = [photo!]
            
        case .video:
            content = FBSDKShareMediaContent()
            let video = FBSDKShareVideo(videoURL: URL(string: "http://www.halal.place/video")!)
            (content as? FBSDKShareMediaContent)?.media = [video!]

        case .link:
            content = FBSDKShareLinkContent()
            for shareObj in shareContent {
                if shareObj is URL {
                    (content as? FBSDKShareLinkContent)?.contentURL = shareObj as? URL
                } else if shareObj is String {
                    (content as? FBSDKShareLinkContent)?.contentTitle = shareObj as? String // "Content Title"

                }
            }
            
            // (content as? FBSDKShareLinkContent)?.imageURL = URL(string: "http://www.ezdrone.com/wp-content/uploads/2015/11/Google-logo-2-2014.png")
            (content as? FBSDKShareLinkContent)?.contentDescription = optionalText // "This is the description"
            
        default:
            fatalError("undefined media")
        }
        
        let shareDialog = FBSDKShareDialog()
        
        if UIApplication.shared.canOpenURL(URL(string: "fbauth2://")!) == true {
            shareDialog.mode = .native
        } else {
            shareDialog.mode = .browser
        }
        shareDialog.fromViewController = parentVC
        shareDialog.shareContent = content
        shareDialog.delegate = self
        shareDialog.show()
    }
    
    // https://docs.fabric.io/apple/twitter/compose-tweets.html
    func shareViaTwitter(parentVC:UIViewController, shareType:ShareType, shareContent:[AnyObject], optionalText:String = "") {
        if shareContent.count < 1 {
            return
        }
        
        let composer = TWTRComposer()
        composer.setText("just setting up my Fabric")
        
        switch shareType {
        case .image:
            composer.setImage(shareContent.first as? UIImage)
            composer.setText(optionalText)
            
        case .video:
            fatalError("unsupported media")
            
        case .link:
            let shareText = optionalText.isBlank() ? shareContent.first?.absoluteString : (optionalText + " " + (shareContent.first?.absoluteString)!)
            composer.setText(shareText!)
            
        default:
            fatalError("undefined media")
        }
        
        // Called from a UIViewController
        composer.show(from: parentVC) { result in
            if (result == TWTRComposerResult.cancelled) {
                DLog(message: "Tweet composition cancelled")
            }
            else {
                DLog(message: "Sending tweet!")
            }
        }
    }
    
    var documentController:UIDocumentInteractionController?
    func shareViaInstagram(parentVC:UIViewController, shareType:ShareType, shareContent:[AnyObject], optionalText:String = "") {
        let instagramURL = URL(string: "instagram://app")
        if UIApplication.shared.canOpenURL(instagramURL!) == false {
            // cant support
            DLog(message: "no instagram app")
            Extension.showToast(type: .error, message: "You do not have instagram app.")
            return
        }
        
        if shareType != .image {
            fatalError("You cannot share anything except image to instagram")
        }
        
        let yourImage = shareContent.first as? UIImage
        let imageData = UIImageJPEGRepresentation(yourImage!, 100)
        // let captionString = "caption"
        let writePath = Extension.getDocumentsDirectory().appendingPathComponent("instagram.igo")
        
        do {
            try imageData?.write(to: writePath, options: [.atomic])
        } catch let error {
            DLog(message: "\(error)")
        }
        let fileURL = writePath
            
        documentController = UIDocumentInteractionController(url: fileURL)
        documentController?.delegate = self
        // documentController?.uti = "com.instagram.exlusivegram"
        documentController?.uti = "com.instagram.exclusivegram"
        documentController?.annotation = [optionalText]
        
        let rect = CGRect(x: 0, y: 0, width: 300, height: 300)
        documentController?.presentOpenInMenu(from: rect, in: parentVC.view, animated: true)
        // documentController.presentOpenInMenuFromRect(self.view.frame, inView: self.view, animated: true)
    }

    func shareViaEMail(parentVC:UIViewController, shareType:ShareType, shareContent:[AnyObject]) -> Bool {
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            
            mailComposerVC.setToRecipients(["support@halal.place"])
            mailComposerVC.setSubject("Feedback / support")
            mailComposerVC.setMessageBody("", isHTML: false)
            parentVC.present(mailComposerVC, animated: true, completion: nil)
            return true
        } else {
            Extension.showToast(type: .error, message: "Your device could not send e-mail. Please check e-mail configuration and try again.")
            return false
        }
    }
    
    func shareViaDialog(parentVC:UIViewController, shareType:ShareType, shareContent:[AnyObject]) {
        let activityViewController = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.airDrop, .openInIBooks, .postToVimeo, .postToWeibo, .postToTencentWeibo]
        
        parentVC.present(activityViewController, animated: true, completion: {
            DLog(message: "shared")
        })
    }
}

extension SocialShareHelper: FBSDKSharingDelegate {
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        DLog(message: "\(results)")
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        DLog(message: "\(error)")
        Extension.showToast(type: .error, message: "You do not have facebook app or something went wrong while sharing.")
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        DLog(message: "sharerDidCancel")
    }
}

extension SocialShareHelper: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        DLog(message: "result \(result)    error \(error)")
    }
}

extension SocialShareHelper: UIDocumentInteractionControllerDelegate {
    
}
