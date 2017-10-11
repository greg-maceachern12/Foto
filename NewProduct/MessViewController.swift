


//The frameworks of the code were taken from the CocoaPod "JSQMessageViewController". I reworked it to operate with firebase and the rest of the application

import UIKit
import JSQMessagesViewController
import Firebase
import SDWebImage


class MessViewController: JSQMessagesViewController, UIBarPositioningDelegate {
    
    
    var messages = [JSQMessage]()
    var token: String!
    var loggedUser = FIRAuth.auth()?.currentUser
    var dataRef = FIRDatabase.database().reference()
    var run = true
    
    var name: String!

    var avatars = [String: JSQMessagesAvatarImage]()
    
    let storage = FIRStorage.storage()
    
    var dates = [String!]()
    
    var offsetY:CGFloat = 0
    
}

extension MessViewController{

    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        
        //retrieving information to upload to the database (date,name,token ect.)
        let strDate = Date()
        let day = Calendar.current.component(.day, from: strDate)
        let month = Calendar.current.component(.month, from: strDate)
        let year = Calendar.current.component(.year, from: strDate)
        
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.none
        formatter.timeStyle = .short
        let dateString = formatter.string(from: strDate)
        
        let token: [String: AnyObject] = [Messaging.messaging().fcmToken!: Messaging.messaging().fcmToken as AnyObject]
        
         self.postToken(Token: token)
        
        //this data is uploaded to the corresponding locations in the database (3 locations)

            self.dataRef.child("users").child(self.token).observeSingleEvent(of: .value, with: {  (snap) in
                if let dict = snap.value as? [String: AnyObject]
                {
                    
                    var temp1 = dict["pic"] as? String
                    if temp1 == nil{
                        temp1 = "default.ca"
                    }
                
        
                   
                    let messPost: [String : AnyObject] = ["toName": self.name as AnyObject,
                                                          "token": self.token as AnyObject,
                                                          //"pic": temp1 as AnyObject,
                                                          "text": text as AnyObject,
                                                          "date": "\(day)/\(month)/\(year)" as AnyObject]
                    
                    
                    
                    
                    self.dataRef.child("users").child(self.loggedUser!.uid).child("messages").child(self.token).setValue(messPost)
                   
                    
                }
                
            })
            
        
        
        self.dataRef.child("users").child(self.loggedUser!.uid).observeSingleEvent(of: .value, with: {  (snap) in
                
            if let dict = snap.value as? [String: AnyObject]
            {
                
                var temp1 = dict["pic"] as? String
                
                if temp1 == nil{
                    temp1 = "default.ca"
                }
                    
                
                
                    
                    
                    
                    let messPost: [String : AnyObject] = ["toName": senderDisplayName as AnyObject,
                                                          "token": self.loggedUser!.uid as AnyObject,
                                                          "pic": temp1 as AnyObject,
                                                          "text": text as AnyObject,
                                                          "date": "\(day)/\(month)/\(year)" as AnyObject]
                    
                    self.dataRef.child("users").child(self.token).child("messages").child(self.loggedUser!.uid).updateChildValues(messPost)
            }
                
            })

        
        
                self.run = false
        
        
        
                self.dataRef.child("users").child(self.loggedUser!.uid).child("messages").child(self.token).child("date").setValue("\(day)/\(month)/\(year)")
                self.dataRef.child("users").child(self.token).child("messages").child(self.loggedUser!.uid).child("date").setValue("\(day)/\(month)/\(year)")
        
        
                let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
                
                let FIRmessage: [String : AnyObject] = ["senderID": senderId as AnyObject,
                                                        "displayName": senderDisplayName as AnyObject,
                                                        "text": text as AnyObject,
                                                        "toID": self.token as AnyObject,
                                                        "date": dateString as AnyObject]
                
                self.dataRef.child("messages").childByAutoId().setValue(FIRmessage)
                
                self.messages.append(message!)
                self.dates.append(dateString)
                

                self.finishSendingMessage()
                

            
           
           
            
            
        
        
        
        
    }
    
    func postToken(Token: [String: AnyObject]){
        //uploads the FCM token to the database to recieve notifications
        print("FCM Token: \(Token)")
        let dbRef = FIRDatabase.database().reference()
        dbRef.child("users").child(self.loggedUser!.uid).child("fcmToken").setValue(Token)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {

        
        //the collection view is the message view and is controlled (for the most part) here
        let placeHolderImage = #imageLiteral(resourceName: "Default")
        let avatarImage = JSQMessagesAvatarImage(avatarImage: nil, highlightedImage: nil, placeholderImage: placeHolderImage)
       
        
        
        
        let message = messages[indexPath.item]
        
        if avatarImage?.avatarImage == nil {
            avatarImage?.avatarImage = SDImageCache.shared().imageFromDiskCache(forKey: message.senderId)
        }
        
        
        //saving the avatar image in tge cagceso the chat loads faster
        if (message.senderId) != nil {
            if loggedUser?.uid == message.senderId{
            dataRef.child("users").child(loggedUser!.uid).observe(.value, with: { (snapshot) in
                
                if let profileURL = (snapshot.value as AnyObject!)!["pic"] as! String! {
                    
                    let profileNSURL: NSURL = NSURL(string: profileURL)!
                    
                    // download avatar image here somehow!?
                    let manager: SDWebImageManager = SDWebImageManager.shared()
                    manager.downloadImage(with: profileNSURL as URL!, options: [], progress: { (receivedSize: Int, actualSize: Int) in
                        //print(receivedSize, actualSize)
                    }, completed: { (image, error, cached, finished, url) in
                        if image != nil {
                            manager.imageCache.store(image, forKey: message.senderId)
                            
                            DispatchQueue.main.async
                                {
                                    
                                    avatarImage!.avatarImage = image
                                    avatarImage!.avatarHighlightedImage = image
                            }
                        }
                    })
                }
            })
            }
            else{
                
                
                dataRef.child("users").child(self.token).observe(.value, with: { (snapshot) in
                    
                    if let profileURL = (snapshot.value as AnyObject!)!["pic"] as! String! {
                        
                        let profileNSURL: NSURL = NSURL(string: profileURL)!
                        
                        // download avatar image here somehow!?
                        let manager: SDWebImageManager = SDWebImageManager.shared()
                        manager.downloadImage(with: profileNSURL as URL!, options: [], progress: { (receivedSize: Int, actualSize: Int) in
                           // print(receivedSize, actualSize)
                        }, completed: { (image, error, cached, finished, url) in
                            if image != nil {
                                manager.imageCache.store(image, forKey: message.senderId)
                                
                                DispatchQueue.main.async
                                    {
                                        avatarImage!.avatarImage = image
                                        avatarImage!.avatarHighlightedImage = image
                                }
                            }
                        })
                    }
                })
 
                
                
            }
        }
    
        return avatarImage
        
        
    }
    
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //initalizing some charactistics about the bubble(text color, text size, font etc)
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.row]
        
        if loggedUser!.uid == message.senderId{
            
            cell.textView!.textColor = UIColor.white
            
        }
        else{
            cell.textView!.textColor = UIColor.black
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) ->
        
        NSAttributedString! {
            return NSAttributedString(string: dates[indexPath.row])

            
            
            
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
       return 15
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        //return the text for the message
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        //gives the ability to change the style of the bubble(shape, colour etc)
        
        let bubbleFactory = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: .zero)
    
        
        let message = messages[indexPath.row]
        
        if loggedUser!.uid == message.senderId{
            
            return bubbleFactory?.outgoingMessagesBubbleImage(with: .orange)
            
        }
        else{

            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor(red: 218/255, green: 218/255, blue: 233/255, alpha: 1))
            
        }
        
    }
    

}

extension MessViewController {
    override func viewDidLoad() {
        
       
        super.viewDidLoad()
        
        
        
        self.inputToolbar.contentView.leftBarButtonItem = nil
        
        NotificationCenter.default.addObserver(self, selector: #selector(MessViewController.keyboardFrameChangeNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        //tell JSQMessagesView who is current user
        self.senderId = loggedUser?.uid
        //the name will be Loading until it has loaded
        self.senderDisplayName = "Loading"
        
        self.dataRef.child("users").child(loggedUser!.uid).child("Name").observe(.value){
            (snap: FIRDataSnapshot) in
            self.senderDisplayName = snap.value as? String
            
        }
        self.navigationItem.title = "hein"
     
        
        

        self.messages = getMessage2()
        
        
        
       
    }
    
    @objc func keyboardFrameChangeNotification(notification: Notification) {
        if let userInfo = notification.userInfo {
            let endFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0
            let animationCurveRawValue = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int) ?? Int(UIViewAnimationOptions.curveEaseInOut.rawValue)
            let animationCurve = UIViewAnimationOptions(rawValue: UInt(animationCurveRawValue))
            if let _ = endFrame, endFrame!.intersects(self.inputToolbar.frame) {
                self.offsetY = self.inputToolbar.frame.maxY - endFrame!.minY
                UIView.animate(withDuration: animationDuration, delay: TimeInterval(0), options: animationCurve, animations: {
                    self.inputToolbar.frame.origin.y = self.inputToolbar.frame.origin.y - self.offsetY
                }, completion: nil)
            } else {
                if self.offsetY != 0 {
                    UIView.animate(withDuration: animationDuration, delay: TimeInterval(0), options: animationCurve, animations: {
                        self.inputToolbar.frame.origin.y = self.inputToolbar.frame.origin.y + self.offsetY
                        self.offsetY = 0
                    }, completion: nil)
                }
            }
        }
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }

 
    
}



extension MessViewController {
    func getMessage2() -> [JSQMessage]{
        let messages = [JSQMessage]()
        
        
        self.dataRef.child("messages").observe(.childAdded, with: { (snapshot) in
            
            //added this condition so this segment of the function isnt run when the user sends a new message. 
          if self.run == true
          {
            
            let snapshotValuetoName = snapshot.value as? NSDictionary
            let toName = snapshotValuetoName?["displayName"] as? String
            
            let snapshotValueID = snapshot.value as? NSDictionary
            let tokensenderID = snapshotValueID?["senderID"] as? String
            
            let snapshotValuetoID = snapshot.value as? NSDictionary
            let tokensendertoID = snapshotValuetoID?["toID"] as? String
            
            let snapshotValueText = snapshot.value as? NSDictionary
            let texty = snapshotValueText?["text"] as? String
            
            let dater = snapshotValueText?["date"] as? String
           
            
            
            
            
            if (tokensendertoID == self.loggedUser!.uid || tokensendertoID == self.token) && (tokensenderID == self.loggedUser!.uid || tokensenderID == self.token){
            
                let message = JSQMessage(senderId: tokensenderID, displayName: toName, text: texty)
                
                self.dates.append(dater)
                
            self.messages.append(message!)
                self.collectionView.reloadData()
                
                }
            }
           
            
        })
        
            return messages
        
        

        
        
        
    }
    
}
