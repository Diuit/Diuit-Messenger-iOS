[![Duit logo](http://api.diuit.com/images/logo.png)](http://api.diuit.com/)

# Integrate In-app Messaging with Diuit PART3: Work with DUMessagingUIKit

This tutorial will guide you to integrate with our UIKit. You will have a real time message app which is capable of displaying all required information and sending multimedia messages.



## Requirements

* Xcode 8 (Swift 3)
* iOS 8.0 +
* Two session tokens (name they FIRST_TOKEN and SECOND_TOKEN)
* Web chatting page (optional) in this [section](https://camo.githubusercontent.com/ce5913e8e3a314c1f989b90116647e7d2facddf6/687474703a2f2f692e696d6775722e636f6d2f4f555a703468712e706e67)

If you have problem in getting last two things, please follow [last tutorial](https://github.com/Diuit/DUChat-iOS-demo).



## Getting Started

You can either clone this repo to start trial with only few setups or follow the tutorial in next section to create a new project step by step.

If you choose to clone this repo, here's what you need to do after clone:

1. run `pod install` in the project root folder.

2. Replace `APP_ID` and `APP_KEY` in AppDelegate.swift (at line 20) with yours.

   ```swift
   DUMessaging.set(appId: "APP_ID", appKey: "APP_KEY")
   ```

3. Replace `SESSION_TOKEN`  in DUChatListViewController.swift (at line 38) with yours.

   ```swift
   DUMessaging.auth(withSessionToken: "SESSION_TOKEN") { error, result in
   // ...
   }
   ```



Otherwise, please follow the following tutorial to create your own instant message app.

### Preparation

* Create a new project, name it 'DUMessenger'

* Use [CocoaPods](https://cocoapods.org/) to install the UIKit. First, execute the following command in terminal (in your project root foler)

  ```shell
  $ pod init
  ```

* Specify your `Podfile`:

  ```ruby
  platform :ios, '8.0'
  use_frameworks!

  # Require test version of some dependcies, so define an override
  def swift3_overrides
    pod 'Kanna', git: 'https://github.com/tid-kijyun/Kanna.git', branch: 'swift3.0'
    pod 'URLEmbeddedView', :git => 'https://github.com/marty-suzuki/URLEmbeddedView.git', :tag => '0.6.0'
  end

  target 'DUMessenger' do
    swift3_overrides
    pod 'DUMessagingUIKit', :git => 'https://github.com/Diuit/DUMessagingUIKit-iOS', :tag => '0.2.0''
  end

  # Use Swift 3 in all pod targets

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
  end
  ```

* Then, run the following command to install all dependent frameworks:

  ```shell
  $ pod install
  ```

* Open `DUMessenger.xcworkspace` (make sure that `DUMessaging.xcproject` is closed)

* Set app id and app key in `AppDelegate.swift` (check [here](https://developer.diuit.com/dashboard) if you don't know you id and key)

  ```swift
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
          // Set up your app id and app key
          DUMessaging.set(appId: "APP_ID", appKey: "APP_KEY")
          return true
      }
  ```

  ​

### Display Chat Room List

* Drag and drop a Navigation Controller in `Main.storyboard` and set it as Storyboard Entry Point![storyboard example](http://i.imgur.com/F7aFNau.png)

* Create a new subclass of UITableViewController, `DMChatListViewController` and make it conform to **DUChatListProtocolForViewController**

  ```swift
  import UIKit
  import DUMessagingUIKit
  import DUMessaging

  class DMChatListViewController: UITableViewController, DUChatListProtocolForViewController {
  }
  ```

* Let's implement a property and a method in this class to conform to protocol `DUChatListProtocolForViewController`

  ```swift
  // Data source of chat list
  var chatData: [DUChatData] = []

  // Action for new chat button
  func didClick(rightBarButton: UIBarButtonItem?) {
      print("Right bar button clicked")
  }
  ```

* Override method `viewDidLoad()` to setup UI and retrieve chat list by Diuit API (DUMessaging). Noted that you have to user your own FIRST_TOKEN to replace  **SESSION_TOKEN_1** in the following.

  ```swift
  override func viewDidLoad() {
      super.viewDidLoad()
      
      // You must call this function in viewDidLoad() to setup UI
      adoptProtocolUIApperance()

      // retrieve chat list
      DUMessaging.auth(withSessionToken: "SESSION_TOKEN_1") { error, result in
          guard error == nil else {
              print("auth error:\(error!.localizedDescription)")
              return
          }
          DUMessaging.listAllChatRooms() { [unowned self] error, chats in
              guard let _:[DUChat] = chats, error == nil else {
                  print("list error:\(error!.localizedDescription)")
                  return
              }
              self.chatData = chats!
              // Call this after you have done retrieving chat list data
              self.endGettingChatData()
          }
      }
  }
  ```

* Click build & run in Xcode, you should see some results similiar to the following (as long as you already have at least one chat room)
  ![chat list](http://i.imgur.com/Cgqujgf.png)

* We'd like to get in one chat room by clicking on it, so we will need anohter viewController for messages. Create another subclass of UIViewController, `DUMessengerViewController`, and drage a new ViewController in your `Main.storyboard`. Then drag a segue between `DUChatListViewController` and `DMMessagesViewController` with identifier **toMessengerSegue** in storyboard.

  ```swift
  import UIKit
  import DUMessagingUIKit
  import DUMessaging

  class DMMessagesViewController: DUMessagesViewController {}
  ```

  ![storyboard](http://i.imgur.com/YiGXJbb.png)

* Back to `DUChatListViewController.swift` and add code for seguing to next viewController.

  ```swift
  // Store the reference to the chatroom instance
  var selectedChat: DUChatData? = nil

  // Implement to handle cell selection event
  func didSelectCell(at indexPath: IndexPath) {
      selectedChat = chatData[indexPath.row]
      performSegue(withIdentifier: "toMessengerSegue", sender: nil)
  }

  // You need to set a chat room data source for `DUMessengerViewController`
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let vc = segue.destinationViewController as? DUMessengerViewController {
          vc.chat = selectedChat
      }
  }
  ```



### View & Send Messages

This is the most important element in this UIKit. We provide many features in `DUMessagesViewController`, all you have to do is to inherit this class and override some must-implemented methods.

* First, override some touching events. (If you miss some override, there is also  an assert function to remind you under Debug configuration)

  ```swift
  // You can do whatever you want in following three tap methods

  // Triggered by clicking avatars
  override func didTapAvatar(ofMessageCollectionViewCell cell: DUMessageCollectionViewCell) {
      print(" did tap avatar in demo app")
  }

  // Triggered by clicking message bubbles
  override func didTapMessageBubble(ofMessageCollectionViewCell cell: DUMessageCollectionViewCell) {
      print(" did tap bubble in demo app")
  }

  // Triggered by clicking areas outside message bubble but inside cell
  override func didTap(messageCollectionViewCell cell: DUMessageCollectionViewCell) {
      print(" did tap cell in demo app")
  }

  override func didClickRightBarButton(sender: UIBarButtonItem?) {
      // We'll modify this later
      print(" click setting button")
  }

  // Implement what to do when you press `send` button
  override func didPress(sendButton button: UIButton, withText: String) {
      if let du_chat = self.chat as? DUChat {
          du_chat.sendText(withText, beforeSend: { [weak self] message in
          	// Message is ready to be sent
              self?.messageData.append(message)
              self?.endSendingMessage()
          }) { [weak self] error, message in
          	// Message completed sending
              self?.collectionView?.reloadData()
          }
      }
  }
  ```

* We need to specify message data source to display historical messages

  ```swift
  // MARK: life cycle
  override func viewDidLoad() {
      super.viewDidLoad()
      // To show load ealier messages refresh control (pull-to-refresh) or not
      self.enableRefreshControl = false
      
      // Use Diuit API to list last 20 messages
      if let c = self.chat as? DUChat {
          c.listMessages() { [weak self] error, messages in
              for message: DUMessage in messages! {
              	// messageData is the data source of messages
                  self?.messageData.insert(message, at: 0)
              }
              // You MUST call this when done receiving messages
              self?.endReceivingMessage()
          }
      }
  }
  ```

* Build and run, you should see your historical messages
  ![messages list](http://i.imgur.com/yZ81x69.png)

* Now you can type some texts and send it out by clicking **Send**, or click on any messages to see the triggered tap methods by checking debug console. 

* Avatar will be the first character of user name in default. You can override `func avatarImage(atIndexPath indexPath: NSIndexPath, forCollectionView collectionView: DUMessageCollectionView) -> UIImage?` to customize your avatar.

* If you want to send rich-media messages, you have to implment the action for accessory button. Here we present an UIAlertController and let user choose image by UIImagePicker.

  ```swift
  override func didPress(accessoryButton button: UIButton) {
      self.inputToolbar.contentView?.inputTextView.resignFirstResponder()
      presentActionSheet()
  }

  // present action sheet
  private func presentActionSheet() {
      let actionController = UIAlertController.init(title: "Rich-media message", message: "Choose one", preferredStyle: .actionSheet)

      let sendImageAction = UIAlertAction.init(title: "Send image", style: .default){ [unowned self] action in
          if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
              let picker = UIImagePickerController()
              picker.delegate = self
              picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
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
  ```

* To make UIImagePicker run correctly, we still have to implement its delegate.

  ```swift
  class DMMessagesViewController: DUMessagesViewController {
  	// ...
  }

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
          picker.dismissViewControllerAnimated(true, completion: {
              () -> Void in
              if let du_chat = self.chat as? DUChat {
                  du_chat.sendImage(image, meta: meta, beforeSend:{ [unowned self] message in
                  	// This closure is executed before the message gets delivered. For sending images will take a while, we need to show the image right away for better user experience
                      message.localImage = image
                      self.messageData.append(message)
                      // This MUST be called after the message is sent
                      self.endSendingMessage()
                  }) { error, message in
                  	guard error == nil else {
    						print("failed to send image: \(error!.localizedDescriptiont)")
    						return
  					}
                      print("image sent")
                  }
              }
          })
      }
  }
  ```

* You should be able to send image message
  ![send image](http://i.imgur.com/YFC1VSD.png)

* You can also add other actions as you want, such as "send file" or "send video".

* Next, we will push to chat setting scene by clicking the right bar button on navigation bar. Therefore, we need create last new ViewController in storyboard and a subclass of UIViewController, `DMSettingViewController`. (Also a push segue named **toSettingSegue**)
  ![storyboard](http://i.imgur.com/VTZUkXL.png)

  ```swift
  override func didClick(rightBarButton: UIBarButtonItem?) {
      self.performSegueWithIdentifier("toSettingSegue", sender: nil)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let vc = segue.destinationViewController as? DMSettingViewController {
          vc.chatDataForSetting = self.chat
      }
  }
  ```

  ​

### Chat Setting

* Basically, you can see the result without any coding.
  ​
* ![chat setting page](http://i.imgur.com/bfXRwan.png)
  ​
* ![chat setting page 2](http://i.imgur.com/d7OiF5t.png)


* All the buttons here are with a default touch event with an assert inside to check if the event is overrided. You have to implement the touch events by overriding them.



### Communication Between Two Devices

If you run above code on a simulator, you will need either an iOS device or Android device to see the results. To build a real time chat app on Android, please check [here](http://zxcvbnius.tw/index.php/2016/07/27/how-to-implement-chat-app-in-20-min/). 

Jump to this [section](https://github.com/Diuit/Diuit-Messenger-iOS#communication-between-device-and-web) if you don't have any real device.

* Build and run this tutorial app on your simulator with your FIRST_SESSION

* In your `DUChatListViewController.swift`, replace the session token with your **SECOND_SESSION**

  ```swift
  // Replace SESSION_TOKEN_2 with your own SECOND_SESSION
  DUMessaging.authWithSessionToken("SESSION_TOKEN_2") { error, result in
  	// bla bla we just did ...
  }
  ```

* Change build targe to your real device

![targe](http://i.imgur.com/vhuz32j.png)

* Build & run.
* Now you can chat with yourself by an app of your own! Isn't that easy and great?

![forever alone](http://i.imgur.com/Ujcmzkj.jpg)



### Communication Between Device and Web

If you only have a simulator and no other real devices, you can use our sample chatting web page (please check this [section](https://github.com/Diuit/DUChat-iOS-demo#build-basic-ui--send-messages) to build one on your own).

* Open the page in your browser (the URL should be like `https://APP_NAME.herokusapp.com/webchat.html` if you use one-button-deploy on heroku)
* login with **SECOND_SESSION** and room id (you can get it by print it in the log when listing the chat room list)

![webchat](http://i.imgur.com/RFilXW4.png) 

* Then you can chat between your simulator and this web page (our sample page only support text message for now).



## Where to Go from Here?

Now you should be able to build a well functional real-time communication app with Diuit API and Diuit UIKit. It's time to integrate these features with your own application or to develop new service. 



We may have the tutorial to guide you to integrate with BOT service in the near future. Please stay tuned.



## Contact

This tutorial was prepared by [Diuit](http://api.diuit.com/) team. If you have any questions, feel free to [contact us](mailto:support@diuit.com) or join our [Slack channel](http://slack.diuit.com/).