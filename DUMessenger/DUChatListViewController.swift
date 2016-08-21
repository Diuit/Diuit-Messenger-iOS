//
//  ViewController.swift
//  DUMessenger
//
//  Created by Pofat Diuit on 2016/8/21.
//  Copyright © 2016年 duolC. All rights reserved.
//

import UIKit
import DUMessagingUIKit
import DUMessaging

class DUChatListViewController: UITableViewController, DUChatListProtocolForViewController {

    // MARK: followings are propeties and methods that you should implement
    var chatData: [DUChatData] = []
    
    func didClickRightBarButton(sender: UIBarButtonItem?) {
        // handle righbtBarButton click event
        print("Right bar button clicked")
    }
    
    func didSelectCell(atIndexPath indexPath: NSIndexPath) {
        // handle cell selection event
        selectedChat = chatData[indexPath.row]
        
    }
    
    var selectedChat: DUChatData? = nil
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // adopt UI protocol
        adoptProtocolUIApperance()
        
        // retrieve chat list
        DUMessaging.authWithSessionToken("SESSION_TOKEN") { error, result in
            guard error == nil else {
                print("auth error:\(error!.localizedDescription)")
                return
            }
            DUMessaging.listAllChatRooms() { [unowned self] error, chats in
                guard let _:[DUChat] = chats where error == nil else {
                    print("list error:\(error!.localizedDescription)")
                    return
                }
                
                // You must use .map to assign array, or you will get a runtime errro.
                // For Swift still has to bridge to NSArray in runtime to deal with collection, and NSArray can not handle protocol type.
                self.chatData = chats!.map({$0 as DUChatData})
                
                // Call this after you done retrieving data
                self.endGettingChatData()
            }
        }
        
    }
    

}

