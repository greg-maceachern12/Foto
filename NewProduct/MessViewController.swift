

import UIKit
import JSQMessagesViewController
import Firebase
import SDWebImage


class MessViewController: JSQMessagesViewController {
    
    
    var messages = [JSQMessage]()
    var token: String!
    var loggedUser = FIRAuth.auth()?.currentUser
    var dataRef = FIRDatabase.database().reference()
    var run = true
    
    var name: String!
    //var picture: String!
    
    
    var avatars = [String: JSQMessagesAvatarImage]()
    
    let storage = FIRStorage.storage()
    
}

extension MessViewController{

    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let strDate = Date()
        let day = Calendar.current.component(.day, from: strDate)
        let month = Calendar.current.component(.month, from: strDate)
        let year = Calendar.current.component(.year, from: strDate)
        
        
        //if messages.count == 0{
            
//            let strDate = Date()
//            let day = Calendar.current.component(.day, from: strDate)
//            let month = Calendar.current.component(.month, from: strDate)
//            let year = Calendar.current.component(.year, from: strDate)
            
           // self.dataRef.child("users").child(self.loggedUser!.uid).child("messages").child(self.token).setValue("\(day)/\(month)/\(year)")
            
//
            self.dataRef.child("users").child(self.token).child("pic").observe(.value, with: { (snap) in
                
                if let temp1 = snap.value as? String{
                   
                    
                    
                    let messPost: [String : AnyObject] = ["toName": self.name as AnyObject,
                                                          "token": self.token as AnyObject,
                                                          "pic": temp1 as AnyObject,
                                                          "date": "\(day)/\(month)/\(year)" as AnyObject]
                    
                    
                    
                    
                    self.dataRef.child("users").child(self.loggedUser!.uid).child("messages").child(self.token).setValue(messPost)
                    
                }
            })
            
            self.dataRef.child("users").child(self.loggedUser!.uid).child("pic").observe(.value, with: { (snap) in
                
                if let temp1 = snap.value as? String{
                    
                    
                    
                    let messPost: [String : AnyObject] = ["toName": senderDisplayName as AnyObject,
                                                          "token": self.loggedUser!.uid as AnyObject,
                                                          "pic": temp1 as AnyObject,
                                                          "date": "\(day)/\(month)/\(year)" as AnyObject]
                    
                    self.dataRef.child("users").child(self.token).child("messages").child(self.loggedUser!.uid).updateChildValues(messPost)
                }
            })
            
                    
        
            
      //  }
        
        
        
                self.run = false
        
        
        
                self.dataRef.child("users").child(self.loggedUser!.uid).child("messages").child(self.token).child("date").setValue("\(day)/\(month)/\(year)")
                self.dataRef.child("users").child(self.token).child("messages").child(self.loggedUser!.uid).child("date").setValue("\(day)/\(month)/\(year)")
        
        
                let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
                
                let FIRmessage: [String : AnyObject] = ["senderID": senderId as AnyObject,
                                                        "displayName": senderDisplayName as AnyObject,
                                                        "text": text as AnyObject,
                                                        "toID": self.token as AnyObject ]
                
                self.dataRef.child("messages").childByAutoId().setValue(FIRmessage)
                
                self.messages.append(message!)
                
                
                
                //print(self.messages)
                
                self.finishSendingMessage()
                

            
           
           
            
            
        
        
        
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {

        let placeHolderImage = #imageLiteral(resourceName: "Default")
        let avatarImage = JSQMessagesAvatarImage(avatarImage: nil, highlightedImage: nil, placeholderImage: placeHolderImage)
        
        let message = messages[indexPath.item]
        
        if avatarImage?.avatarImage == nil {
            avatarImage?.avatarImage = SDImageCache.shared().imageFromDiskCache(forKey: message.senderId)
        }
        
        
        //saving avatar
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
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.row]
        //cell.textView.font = UIFont(name: "Avenir Next", size: 14)
        
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
            let message = messages[indexPath.row]
            let messageUsername = message.senderDisplayName
            
            return NSAttributedString(string: messageUsername!)
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        let message = messages[indexPath.row]
        
        if loggedUser!.uid == message.senderId{
            
            return bubbleFactory?.outgoingMessagesBubbleImage(with: .orange)
            
        }
        else{
//            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor(red: 218/255, green: 218/255, blue: 233/255, alpha: 1))
            
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor(red: 218/255, green: 218/255, blue: 233/255, alpha: 1))
            
        }
        
    }
    

}

extension MessViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        if messages.count == 0
        {
            
        }
        self.inputToolbar.contentView.leftBarButtonItem = nil
        //tell JSQMessagesView who is current user
        self.senderId = loggedUser?.uid
        self.senderDisplayName = "Loading"
        
        self.dataRef.child("users").child(loggedUser!.uid).child("Name").observe(.value){
            (snap: FIRDataSnapshot) in
            self.senderDisplayName = snap.value as? String
            
        }
        
        
        
        self.messages = getMessage2()
        
       
    }
 
    
}



extension MessViewController {
    func getMessage2() -> [JSQMessage]{
        let messages = [JSQMessage]()
        
       
        
        self.dataRef.child("messages").observe(.childAdded, with: { (snapshot) in
            
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
           
            
            
            
            
            if (tokensendertoID == self.loggedUser!.uid || tokensendertoID == self.token) && (tokensenderID == self.loggedUser!.uid || tokensenderID == self.token){
            
            let message = JSQMessage(senderId: tokensenderID, displayName: toName, text: texty)

            self.messages.append(message!)
                
                }
            }
           
            
        })
        
            return messages
        
        

        
        
        
    }
    
}
