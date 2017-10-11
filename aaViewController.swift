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
import Cosmos


struct postStruct2 {
    let name: String!
    let price1: Float!
    let price2: Float!
    let skills: String!
    let picture: NSURL!
    let location: String!
    let token: String!
    let rating: Double!
    let verified: String!
}


class aaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIBarPositioningDelegate {
    
    
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
    var tokens = [String?]()
    var arrayPin = [String]()

    @IBOutlet weak var pinnedSeg: UISegmentedControl!
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //MARK: Grabbing Data
        
        let delayInSeconds = 0.2
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {}
        
        self.posts.removeAll()
        
                dataRef = FIRDatabase.database().reference()
        
        //grabbing the title, price, date and picture and appending it to a structure and storing that in an array. This is all information pertinant to the artist table cell
        dataRef.child("users").child(self.loggedUser!.uid).child("Pins").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            
            self.arrayPin.append((snapshot.value as? String)!)
        })
        
        
        
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
                        
                    let ver = snapshotValuePrice2?["Verified"] as? String
                        
                
                    let snapshotValueDate = snapshot.value as? NSDictionary
                    let Skills = snapshotValueDate?["Skills"] as? String
                        
                    var Rating = snapshotValueDate?["Ratings"] as? Double
                        
                        if Rating == nil{
                            Rating = 0
                        }

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
                        
//                      
                        //had to create 3 different arrays which are all responsible for different tasks. One is all of the artists, the other is the filtered data from the filtering algoithm. The search array is the list of artists which appear when the user uses the search bar
                        self.posts.insert(postStruct2(name: name, price1: Price1,price2: Price2, skills: Skills, picture:url, location: loc, token: Token, rating: Rating, verified: ver), at: 0)
                        
                        if self.run == false{
                        self.filteredPosts.insert(postStruct2(name: name, price1: Price1,price2: Price2, skills: Skills, picture:url, location: loc, token: Token, rating: Rating, verified: ver), at: 0)
                        self.searchPosts.insert(postStruct2(name: name, price1: Price1,price2: Price2, skills: Skills, picture:url, location: loc, token: Token, rating: Rating, verified: ver), at: 0)
                        
                            
                        }
    
                        
                    }
                    else
                    {
                        let alertContoller = UIAlertController(title: "Oops!", message: "No Artists!", preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertContoller.addAction(defaultAction)
                        
                        self.present(alertContoller, animated:true, completion: nil)
                    }
                    
                    
                    
                   
                   
                    
                   
                    
                    self.homeTab.reloadData()
                    
                })
        
    }

    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
                                        //MARK: TABLE FUNCTIONS
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //creates as many rows as there are posts
    return searchPosts.count
}
    
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
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
        label3.adjustsFontSizeToFitWidth = true;
        label3.text = searchPosts[indexPath.row].skills
    
        let view1 = cell?.viewWithTag(6) as! CosmosView
        view1.rating = searchPosts[indexPath.row].rating
    
        
        let img4 = cell?.viewWithTag(4) as! UIImageView
        img4.sd_setImage(with: searchPosts[indexPath.row].picture as URL!, placeholderImage: UIImage(named: "ProfileDefault")!)
        img4.layer.cornerRadius = 4
        img4.clipsToBounds = true
    
    if searchPosts[indexPath.row].verified == "true"{
        let img5 = cell?.viewWithTag(7) as! UIImageView
        img5.isHidden = false
    }
    else{
        let img5 = cell?.viewWithTag(7) as! UIImageView
        img5.isHidden = true
    }
    

        return cell!
}
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        cellNumber = indexPath.row
        self.cellID = searchPosts[cellNumber].token
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "Artist") as! ArtistViewController

            myVC.token = self.cellID!
        
            homeTab.deselectRow(at: indexPath, animated: true)
        homeTab.deselectRow(at: indexPath, animated: true)
            self.present(myVC, animated: true)
    
        
        
        

    }
    
//    @IBAction func refreshAction(_ sender: Any) {
//     
//        self.viewDidLoad()
//    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        //the rows will be editable if the segment controller is on pinned. The user can unpin artists using the edit function via swiping to the left
        if pinnedSeg.selectedSegmentIndex == 1{
            return true
        }
        else{
            return false
        }
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if pinnedSeg.selectedSegmentIndex == 1{
            
            let delete = UITableViewRowAction(style: .destructive, title: "Unpin") { action, index in
                //What happens when unpin button is tapped
               
                

                
                        
                self.dataRef.child("users").child(self.loggedUser!.uid).child("Pins").child(self.searchPosts[indexPath.row].token).removeValue(completionBlock: { (error,ref) in
                    if error != nil
                    {
                    let alertContoller = UIAlertController(title: "Error", message: error! as? String, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                    alertContoller.addAction(defaultAction)
                    self.present(alertContoller, animated: true, completion: nil)
                    
                    
                    return
                    }
                    self.searchPosts.remove(at: indexPath.row)
                    self.homeTab.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    self.homeTab.reloadData()
                    
                    })

                        
                

                
            }
            

            
            
            return [delete]
            
        }
        else{
            
            return nil
            
        }
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
            //filtering the posts based on skills or name
            self.searchPosts = self.filteredPosts.filter{$0.name.lowercased().contains(searchText.lowercased()) || $0.skills.lowercased().contains(searchText.lowercased())}
            DispatchQueue.main.async {
                self.homeTab.reloadData()
            }
            
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchPosts = self.filteredPosts
        self.view.endEditing(true)
        
    
    }
   
    @IBAction func segChange(_ sender: Any) {
        //when the user switches the segment control to all, the pinned artists will be replaced with all the artists and vice versa.
        if pinnedSeg.selectedSegmentIndex == 1{
           
            //filters the array
         self.searchPosts = self.posts.filter{arrayPin.contains($0.token)}
        self.filteredPosts = self.posts.filter{arrayPin.contains($0.token)}
            self.homeTab.reloadData()
//
    
        }
        else{
            //resets the array
            self.searchPosts = self.posts
            self.filteredPosts = self.posts
            self.homeTab.reloadData()
        }
    }
    
    @IBAction func showFilter(_ sender: Any) {
        //opens the filter page
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
