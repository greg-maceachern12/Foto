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
}

class sentInquireViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

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
        
        //creates a cell in the table and sets information based on the tag (Check tag in main.storyboard)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2")
        
        
        
        let label1 = cell?.viewWithTag(1) as! UILabel
        label1.text = sentInqposts[indexPath.row].name
        
        
        let label2 = cell?.viewWithTag(2) as! UILabel
        label2.text = "\(sentInqposts[indexPath.row].theme!) (\(sentInqposts[indexPath.row].status!))"
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
    
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            //What happens when Edit button is tapped
            
             self.dataRef.child("users").child(self.loggedUser!.uid).child("Sent Inquires").child(self.sentInqposts[indexPath.row].code).child("deleted").setValue("True")
            
                self.sentInqposts.remove(at: indexPath.row)
            
                
                self.homeTab.deleteRows(at: [index], with: UITableViewRowAnimation.automatic)
        }
        return [delete]
        
            
            
    }
  
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if sentInqposts[indexPath.row].status == "Accepted"
        {
         
            
            let alertContoller = UIAlertController(title: "Alert!", message: "The Artist has accepted your inquire! Start a message or pay now :)", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            let payAction = UIAlertAction(title: "Pay Now", style: .default, handler: {
                alert -> Void in
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "Payment") as! PaymentViewController
                
               
                myVC.clientName = self.sentInqposts[indexPath.row].toName
                myVC.price = self.sentInqposts[indexPath.row].price
                
                self.present(myVC, animated: true)
            })

            
            let messageAction = UIAlertAction(title: "Message", style: .default, handler: {
                alert -> Void in
                
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "Mess") as! MessViewController
                
                myVC.token = self.sentInqposts[indexPath.row].token
                myVC.name = self.sentInqposts[indexPath.row].toName
                
                self.present(myVC, animated: true)
                

            })
            alertContoller.addAction(defaultAction)
            alertContoller.addAction(messageAction)
            alertContoller.addAction(payAction)
            self.present(alertContoller, animated:true, completion: nil)
            
            
        }
        else if sentInqposts[indexPath.row].status == "Pending"
        {
            
            let alertContoller = UIAlertController(title: "Alert!", message: "The Artist hasn't gotten to your inquire yet. They'll answer soon", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertContoller.addAction(defaultAction)
            self.present(alertContoller, animated:true, completion: nil)
            
            
        }
        else if sentInqposts[indexPath.row].status == "Declined"
        {
            
            let alertContoller = UIAlertController(title: "Alert!", message: "The Artist has declined your inquire. Don't be discouraged! Keep looking \n This inquire will now be deleted", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
         
                
            alertContoller.addAction(defaultAction)
          
            self.present(alertContoller, animated:true, completion: nil)
            
        }
    
    }
    
    func SetUp()
    {
        self.sentInqposts.removeAll()
        
        dataRef.child("users").child(loggedUser!.uid).child("Sent Inquires").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            //
            if snapshot.exists() == true{
                let snapshotValueName = snapshot.value as? NSDictionary
                let Name = snapshotValueName?["Client Name"] as? String
                
                let Token = snapshotValueName?["artistToken"] as? String
                
                let ToName = snapshotValueName?["toName"] as? String
                
                let snapshotValueTheme = snapshot.value as? NSDictionary
                let Theme = snapshotValueTheme?["Theme"] as? String
                
                let snapshotValueStatus = snapshot.value as? NSDictionary
                let Status = snapshotValueStatus?["Status"] as? String
                
                let snapshotValueCode = snapshot.value as? NSDictionary
                let Code = snapshotValueCode?["code"] as? String
                
                let Price = snapshotValueCode?["Pricing Option"] as? Float
                
                let snapshotValueDeleted = snapshot.value as? NSDictionary
               if (snapshotValueDeleted?["deleted"] as? String) != nil
               {
                self.deleted = true
                }
                
                
                if self.deleted != true
                {
                self.sentInqposts.insert(sentInqStuct(name: Name, toName: ToName, theme: Theme, price: Price, status: Status, token: Token, code: Code), at: 0)
                
                //print(self.inqposts)
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
