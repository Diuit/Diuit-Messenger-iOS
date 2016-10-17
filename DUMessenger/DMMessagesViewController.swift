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

class DMMessagesViewController: DUMessagesViewController {
    
    // MARK: Mehtods required to be overriden
    
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
    
    override func didClick(rightBarButton: UIBarButtonItem?) {
        self.performSegue(withIdentifier: "toSettingSegue", sender: nil)
    }

    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        enableRefreshControl = false
        
        if let c = self.chat as? DUChat {
            c.listMessages() { [weak self] error, messages in
                for message: DUMessage in messages! {
                    // XXX: messageData is the data source of messages
                    self?.messageData.insert(message, at: 0)
                }
                // You MUST call this when done receiving messages
                self?.endReceivingMessage()
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DMSettingViewController {
            vc.chatDataForSetting = self.chat
        }
    }

}

// MARK: UIImagePickerControllerDelegate

extension DMMessagesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let imageURL = info[UIImagePickerControllerReferenceURL] as! URL
        var meta:[String: AnyObject] = [String:AnyObject]()
        
        if let imageName = imageURL.getAssetFullFileName() {
            print("choose image name: \(imageName)")
            meta["name"] = imageName as AnyObject
        }
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        picker.dismiss(animated: true, completion: {
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

private extension DMMessagesViewController {
    // present action sheet
    func presentActionSheet() {
        let actionController = UIAlertController.init(title: "Media message", message: "Choose one to demo", preferredStyle: .actionSheet)
        
        let sendImageAction = UIAlertAction.init(title: "Send image", style: .default){ [unowned self] action in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.present(picker, animated: true, completion: nil)
            }else{
                print("Read album error!")
            }
        }
        
        actionController.addAction(sendImageAction)
        actionController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel) { [unowned self] action in
            self.inputToolbar.contentView?.inputTextView.becomeFirstResponder()
            })
        
        self.present(actionController, animated: true, completion: nil)
    }
}
