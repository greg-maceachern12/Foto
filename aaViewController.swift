//
//  aaViewController.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-05-06.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SDWebImage

struct postStruct2 {
    let name: String!
    let price1: Float!
    let price2: Float!
    let skills: String!
    let picture: NSURL!
    let location: String!
    let token: String!
}


class aaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var Loader: UIActivityIndicatorView!
    
    @IBOutlet weak var homeTab: UITableView!
    
    //MARK: Declaration of variables
    var posts = [postStruct2]()
    var filteredPosts = [postStruct2]()
    var searchPosts = [postStruct2]()
    var dataRef: FIRDatabaseReference!
    var cellNumber : Int!
    var cellID: String!
    var run = false
    let loggedUser = FIRAuth.auth()?.currentUser

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //MARK: Grabbing Data
        
        let delayInSeconds = 0.2
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {}
        
        self.posts.removeAll()
        
                dataRef = FIRDatabase.database().reference()
        
        //grabbing the title, price, date and picture to a structure and storing that in an array
        
                dataRef.child("artistProfiles").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
//                    
                    if snapshot.exists() == true{
                    let snapshotValueName = snapshot.value as? NSDictionary
                    let name = snapshotValueName?["Name"] as? String

                    let snapshotValuePrice = snapshot.value as? NSDictionary
                    let Price1 = snapshotValuePrice?["Price1"] as? Float
                        
                    let snapshotValuePrice2 = snapshot.value as? NSDictionary
                    let Price2 = snapshotValuePrice2?["Price2"] as? Float
                        
                  
                    let loc = snapshotValuePrice2?["Location"] as? String
                
                    let snapshotValueDate = snapshot.value as? NSDictionary
                    let Skills = snapshotValueDate?["Skills"] as? String

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
                        
                        
                        self.posts.insert(postStruct2(name: name, price1: Price1,price2: Price2, skills: Skills, picture:url, location: loc, token: Token), at: 0)
                        
                        if self.run == false{
                        self.filteredPosts.insert(postStruct2(name: name, price1: Price1,price2: Price2, skills: Skills, picture:url, location: loc, token: Token), at: 0)
                        self.searchPosts.insert(postStruct2(name: name, price1: Price1,price2: Price2, skills: Skills, picture:url, location: loc, token: Token), at: 0)
                            
                        }
                        
                    }
                    else
                    {
                        let alertContoller = UIAlertController(title: "Oops!", message: "Please Enter a Username/Password", preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertContoller.addAction(defaultAction)
                        
                        self.present(alertContoller, animated:true, completion: nil)
                    }
                    
                    
                    
                   
                   
                    
                   
                    
                    self.homeTab.reloadData()
                    
                })
        
        
        //if the title is non existant (post doesn't exist), the activity moniter stops
        if (title == nil)
        {
            self.Loader.stopAnimating()
            
        }
       // print(filteredPosts)
    }

    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
                                        //MARK: TABLE FUNCTIONS
    
             func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                //creates as many rows as there are posts
                return searchPosts.count
            }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
            
             func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
                //creates a cell in the table and sets information based on the tag (Check tag in main.storyboard)
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2")
                
                print(searchPosts)
               
                
                let label1 = cell?.viewWithTag(1) as! UILabel
                label1.text = searchPosts[indexPath.row].name
                
                let label5 = cell?.viewWithTag(5) as! UILabel
                label5.text = "(\(searchPosts[indexPath.row].location!))"
                
            
                let label2 = cell?.viewWithTag(2) as! UILabel
                if let temp1 = searchPosts[indexPath.row].price1{
                    if let temp2 = searchPosts[indexPath.row].price2
                    {
                       label2.text = "$\(temp1) - $\(temp2)"
                    }
                }
            
                
                let label3 = cell?.viewWithTag(3) as! UILabel
                label3.text = searchPosts[indexPath.row].skills
                
                
                let img4 = cell?.viewWithTag(4) as! UIImageView
                img4.sd_setImage(with: searchPosts[indexPath.row].picture as URL!, placeholderImage: UIImage(named: "ProfileDefault")!)
                img4.layer.cornerRadius = 4
                img4.clipsToBounds = true
 
                return cell!
}
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        cellNumber = indexPath.row
        self.cellID = searchPosts[cellNumber].token
//        print("token is \(self.cellID)")
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "Artist") as! ArtistViewController

            myVC.token = self.cellID!
        
//            print(myVC.token)
            self.present(myVC, animated: true)
    
        
        
        
//        }
    }
    
    @IBAction func refreshAction(_ sender: Any) {
     
        self.viewDidLoad()
    }
    
    //MARK: Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        DispatchQueue.global(qos: .userInteractive).async {
            if searchText == ""
            {
                self.searchPosts = self.filteredPosts
                DispatchQueue.main.async {
                    self.homeTab.reloadData()
                }
                return
            }
            
            self.searchPosts = self.filteredPosts.filter{$0.name.lowercased().contains(searchText.lowercased())}
            DispatchQueue.main.async {
                self.homeTab.reloadData()
            }
            
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchPosts = self.filteredPosts
        self.view.endEditing(true)
        
    
    }
    
    @IBAction func showFilter(_ sender: Any) {
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "Filter") as! FilterViewController
        
        myVC.takenPosts = self.posts
        //myVC.filteredTakenPosts = self.posts
        
        //            print(myVC.token)
        self.present(myVC, animated: true)
        
    }
    @IBAction func backShow(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
