//
//  MessagesViewController.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-06-23.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tfInput: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var navTitle: UINavigationItem!

    
    var dataRef = FIRDatabase.database().reference()
    var loggedUser = FIRAuth.auth()?.currentUser
    
    var name: String!
    var messengerName: String!
    var token: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        dataRef.child("users").child(loggedUser!.uid).child("Name").observe(.value){
            (snap: FIRDataSnapshot) in
            if let temp1 = snap.value as? String{
                self.name = temp1
                
            }

        }
        
        dataRef.child("users").child(loggedUser!.uid).child("Name").observe(.value){
            (snap: FIRDataSnapshot) in
            if let temp1 = snap.value as? String{
                self.messengerName = temp1
                self.navTitle.title = self.messengerName!
                
            }
        }

        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
    @IBAction func sendAction(_ sender: Any) {
        
        sendMessage()
    }
    
    
    
    func sendMessage(){
        let messageRef = dataRef.child("messages").childByAutoId()
        
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        let values = ["text": tfInput.text!, "fromName": name!, "toName": messengerName!, "toID":self.token,"fromID": self.loggedUser!.uid,  "timestamp": timestamp] as [String : Any]
        
        messageRef.updateChildValues(values)
    }
   

}
