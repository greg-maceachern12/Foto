//
//  ViewController.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-03-10.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

struct postStruct {
    let title: String!
    let description: String!
    let date: String!
    //let picture: UIImage!
}

class Home: UITableViewController{
   
  //  @IBOutlet weak var Loader: UIActivityIndicatorView!
   // @IBOutlet weak var HomeTable: UITableView!
    
    var posts = [postStruct]()
    
    var dataRef: FIRDatabaseReference!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let cell = HomeTable.dequeueReusableCell(withIdentifier: "Cell")
        //cell?.backgroundColor = UIColor.blue
        
        
        dataRef = FIRDatabase.database().reference()
        
        dataRef.child("posts").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            
            let snapshotValueTitle = snapshot.value as? NSDictionary
            let Title = snapshotValueTitle?["title"] as? String
            
            let snapshotValueDes = snapshot.value as? NSDictionary
            let Description = snapshotValueDes?["description"] as? String
            
            let snapshotValueDate = snapshot.value as? NSDictionary
            let Date = snapshotValueDate?["date"] as? String
            
            
            self.posts.insert(postStruct(title: Title, description: Description, date: Date), at: 0)
            

                self.tableView.reloadData()

            
//            let snapshotValue = snapshot.value as? NSDictionary
//            let title = snapshotValue?["title"] as? String
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        let label1 = cell?.viewWithTag(1) as! UILabel
        label1.text = posts[indexPath.row].title
        
        let label2 = cell?.viewWithTag(2) as! UITextView
        label2.text = posts[indexPath.row].description
        
        let label3 = cell?.viewWithTag(3) as! UILabel
        label3.text = posts[indexPath.row].date
        
        
        
        return cell!
    }
    
    
    
  }
