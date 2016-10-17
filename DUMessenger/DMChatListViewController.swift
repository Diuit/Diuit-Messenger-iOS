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

class DMChatListViewController: UITableViewController, DUChatListProtocolForViewController {

    // MARK: Properties and methods required to be implemented
    var chatData: [DUChatData] = []
    
    func didClick(rightBarButton: UIBarButtonItem?) {
        // handle righbtBarButton click event
        print("Right bar button clicked")
    }
    
    func didSelectCell(at indexPath: IndexPath) {
        selectedChat = chatData[indexPath.row]
        performSegue(withIdentifier: "toMessengerSegue", sender: nil)
    }
    
    // MARK: Self properties
    var selectedChat: DUChatData? = nil
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Adopt UI protocol, this method must be called in `viewDidLoad`
        adoptProtocolUIApperance()
        
        // Retrieve chat room list
        DUMessaging.auth(withSessionToken: "SESSION_TOKEN") { error, result in
            guard error == nil else {
                print("auth error:\(error!.localizedDescription)")
                return
            }
            DUMessaging.listAllChatRooms() { [unowned self] error, chats in
                guard let _:[DUChat] = chats , error == nil else {
                    print("list error:\(error!.localizedDescription)")
                    return
                }
                
                self.chatData = chats!
                
                // Call this after you done retrieving data
                self.endGettingChatData()
            }
        }
        
    }
    
    // You need to set a chat room data source for `DUMessengerViewController`
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DMMessagesViewController {
            vc.chat = selectedChat
        }
    }

}

