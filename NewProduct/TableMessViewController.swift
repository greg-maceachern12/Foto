//
//  TableMessViewController.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-06-27.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage


struct messageStruct {
    let ToName: String!
    let date: String!
    let picture: NSURL!
    let token: String!
}
class TableMessViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var homeTab: UITableView!
    
    var info = [messageStruct]()
    var dataRef = FIRDatabase.database().reference()
    var cellID: String!
    let loggedUser = FIRAuth.auth()?.currentUser

    override func viewDidLoad() {
        super.viewDidLoad()

        self.info.removeAll()
        
        dataRef.child("users").child(loggedUser!.uid).child("messages").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            //
            if snapshot.exists() == true{
                let snapshotValueName = snapshot.value as? NSDictionary
                let toName = snapshotValueName?["toName"] as? String
                
                let snapshotValueDate = snapshot.value as? NSDictionary
                let FIRDate = snapshotValueDate?["date"] as? String
                
                let snapshotValuePic = snapshot.value as? NSDictionary
                var url = NSURL()
                if let pic = snapshotValuePic?["pic"] as? String
                {
                    url = NSURL(string:pic)!
                    
                }
                else{
                    url = NSURL(string:"")!
                    
                }
                
                let snapshotValueToken = snapshot.value as? NSDictionary
                let Token = snapshotValueToken?["token"] as? String
                
                
                self.info.insert(messageStruct(ToName: toName, date: FIRDate, picture: url, token: Token), at:0)
            }
            
            
            self.homeTab.reloadData()
            
        })
        

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //creates as many rows as there are posts
        return info.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            //What happens when delete button is tapped
            
            self.dataRef.child("users").child(self.loggedUser!.uid).child("messages").child(self.info[indexPath.row].token).removeValue()
            
            self.info.remove(at: indexPath.row)
            
            
            self.homeTab.deleteRows(at: [index], with: UITableViewRowAnimation.automatic)
        }
        return [delete]
        

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    //creates a cell in the table and sets information based on the tag (Check tag in main.storyboard)
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
    
    
    
    let label1 = cell?.viewWithTag(2) as! UILabel
    label1.text = info[indexPath.row].ToName
    
    
    let label2 = cell?.viewWithTag(3) as! UILabel
    label2.text = info[indexPath.row].date
    

    
    let img4 = cell?.viewWithTag(1) as! UIImageView
    img4.sd_setImage(with: info[indexPath.row].picture as URL!, placeholderImage: UIImage(named: "ProfileDefault")!)
    img4.layer.cornerRadius = 35
    img4.clipsToBounds = true
    
    return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    
        self.cellID = info[indexPath.row].token
        //        print("token is \(self.cellID)")
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "Mess") as! MessViewController
        
        myVC.token = self.cellID!
        myVC.name = info[indexPath.row].ToName
        
        self.homeTab.deselectRow(at: indexPath, animated: true)
        
       self.present(myVC, animated: true)
        
//
    }
    
    @IBAction func backClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }



}
