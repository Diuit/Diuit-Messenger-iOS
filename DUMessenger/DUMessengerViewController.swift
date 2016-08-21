//
//  DUMessengerViewController.swift
//  DUMessenger
//
//  Created by Pofat Diuit on 2016/8/22.
//  Copyright © 2016年 duolC. All rights reserved.
//

import UIKit
import DUMessaging
import DUMessagingUIKit

class DUMessengerViewController: DUMessagesViewController {
    
    override func didPress(sendButton button: UIButton, withText: String) {
        if let du_chat = self.chat as? DUChat {
            du_chat.sendText(withText, beforeSend: { [weak self] message in
                self?.messageData.append(message)
                self?.endSendingMessage()
            }) { [weak self] error, message in
                self?.collectionView?.reloadData()
            }
        }
    }
    
    override func didPress(accessoryButton button: UIButton) {
        self.inputToolbar.contentView?.inputTextView.resignFirstResponder()
        presentActionSheet()
    }
    
    override func didTapAvatar(ofMessageCollectionViewCell cell: DUMessageCollectionViewCell) {
        print(" did tap avatar in demo app")
    }
    
    override func didTapMessageBubble(ofMessageCollectionViewCell cell: DUMessageCollectionViewCell) {
        print(" did tap bubble in demo app")
    }
    
    override func didTap(messageCollectionViewCell cell: DUMessageCollectionViewCell) {
        print(" did tap cell in demo app")
    }
    
    override func didClickRightBarButton(sender: UIBarButtonItem?) {
        self.performSegueWithIdentifier("toSettingSegue", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

}

extension DUMessengerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        var meta:[String: AnyObject] = [String:AnyObject]()
        
        if let imageName = imageURL.getAssetFullFileName() {
            print("choose image name: \(imageName)")
            meta["name"] = imageName
        }
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        picker.dismissViewControllerAnimated(true, completion: {
            () -> Void in
            if let du_chat = self.chat as? DUChat {
                du_chat.sendImage(image, meta: meta, beforeSend:{ message in
                    message.localImage = image
                    self.messageData.append(message)
                    self.endSendingMessage()
                }) { error, message in
                    print("image sent")
                }
            }
        })
    }
}

// MARK: private methods
private extension DUMessengerViewController {
    // present action sheet
    func presentActionSheet() {
        let actionController = UIAlertController.init(title: "Media message", message: "Choose one to demo", preferredStyle: .ActionSheet)
        
        let sendImageAction = UIAlertAction.init(title: "Send image", style: .Default){ [unowned self] action in
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary){
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(picker, animated: true, completion: nil)
            }else{
                print("Read album error!")
            }
        }
        
        actionController.addAction(sendImageAction)
        actionController.addAction(UIAlertAction.init(title: "Cancel", style: .Cancel) { [unowned self] action in
            self.inputToolbar.contentView?.inputTextView.becomeFirstResponder()
            })
        
        self.presentViewController(actionController, animated: true, completion: nil)
    }
}