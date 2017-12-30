//
//  sentInquireViewController.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-06-22.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

struct sentInqStuct {
    let name: String!
    let toName: String!
    let theme: String!
    let price: Float!
    let status: String!
    let token: String!
    let code: String!
    let deleted: String!
}

class sentInquireViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIBarPositioningDelegate  {

    @IBOutlet weak var homeTab: UITableView!
    
    var dataRef = FIRDatabase.database().reference()
    var sentInqposts = [sentInqStuct]()
    
    let loggedUser = FIRAuth.auth()?.currentUser

    var deleted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SetUp()
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //creates as many rows as there are posts
        return sentInqposts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2")
        
        let label1 = cell?.viewWithTag(1) as! UILabel
        label1.text = sentInqposts[indexPath.row].toName
        
        
        let label2 = cell?.viewWithTag(2) as! UILabel
        label2.text = "\(sentInqposts[indexPath.row].theme!) (\(sentInqposts[indexPath.row].status!))"
        
        return cell!
        
      
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            //What happens when delete button is tapped
            
            //first, make sure data is stored in the database, then delete it from the users phone
            self.dataRef.child("users").child(self.loggedUser!.uid).child("Sent Inquires").child(self.sentInqposts[indexPath.row].code).updateChildValues(["deleted" : "true"], withCompletionBlock: { (error,ref) in
                if error != nil
                {
                    let alertContoller = UIAlertController(title: "Error", message: error! as? String, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                    alertContoller.addAction(defaultAction)
                    self.present(alertContoller, animated: true, completion: nil)
                    
                    return
                }
                
                self.sentInqposts.remove(at: indexPath.row)
                self.homeTab.deleteRows(at: [index], with: UITableViewRowAnimation.automatic)
            })
        }
        return [delete]
        
    }
  
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //The status of each inquiry will always only ever have 3 status's unless its nil.
        
        
        if sentInqposts[indexPath.row].status == "Accepted"
        {
            let alertContoller = UIAlertController(title: "Accepted!", message: "The Artist has accepted your inquiry! Start a message or pay now :)", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let messageAction = UIAlertAction(title: "Message", style: .default, handler: {
                alert -> Void in
                
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "Mess") as! MessViewController
                
                myVC.token = self.sentInqposts[indexPath.row].token
                myVC.name = self.sentInqposts[indexPath.row].toName
                
                self.present(myVC, animated: true)
            })
            alertContoller.addAction(defaultAction)
            alertContoller.addAction(messageAction)
            self.present(alertContoller, animated:true, completion: nil)
            
        }
        else if sentInqposts[indexPath.row].status == "Pending"
        {
            
            let alertContoller = UIAlertController(title: "Pending!", message: "The Artist hasn't gotten to your inquiry yet. They'll answer soon", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            let messageAction = UIAlertAction(title: "Message", style: .default, handler: {
                alert -> Void in
                
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "Mess") as! MessViewController
                
                myVC.token = self.sentInqposts[indexPath.row].token
                myVC.name = self.sentInqposts[indexPath.row].toName
                
                self.present(myVC, animated: true)
            })

            alertContoller.addAction(defaultAction)
            alertContoller.addAction(messageAction)
            self.present(alertContoller, animated:true, completion: nil)
        }
        else if sentInqposts[indexPath.row].status == "Declined"
        {
            let alertContoller = UIAlertController(title: "Declined!", message: "The Artist has declined your inquiry. Don't be discouraged! Keep looking", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertContoller.addAction(defaultAction)
            self.present(alertContoller, animated:true, completion: nil)
            
        }
        else{
            
            let alertContoller = UIAlertController(title: "Error!", message: "An error has occured. Please try again later", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertContoller.addAction(defaultAction)
            self.present(alertContoller, animated:true, completion: nil)
            
        }
    
    }
    
    func SetUp()
    {
        self.sentInqposts.removeAll()
        
        dataRef.child("users").child(loggedUser!.uid).child("Sent Inquires").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            if snapshot.exists() == true{
                let snapshotValue = snapshot.value as? NSDictionary
                
                let Name = snapshotValue?["ClientName"] as? String
                let Token = snapshotValue?["artistToken"] as? String
                let ToName = snapshotValue?["toName"] as? String
                let Theme = snapshotValue?["Theme"] as? String
                let Status = snapshotValue?["Status"] as? String
                let Code = snapshotValue?["code"] as? String
                let Price = snapshotValue?["PricingOption"] as? Float
                let Deleted = snapshotValue?["deleted"] as? String
 
                if Deleted != "true"
                {
                    self.sentInqposts.insert(sentInqStuct(name: Name, toName: ToName, theme: Theme, price: Price, status: Status, token: Token, code: Code, deleted: Deleted), at: 0)
                    self.homeTab.reloadData()
                }

            }
        })
        
        if sentInqposts.count == 0
        {
            let alertContoller = UIAlertController(title: "Oops!", message: "You've sent no inquires! Find an artist and send some out :)", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertContoller.addAction(defaultAction)
            self.present(alertContoller, animated:true, completion: nil)
        }
        
    }

    @IBAction func backShow(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }


}
