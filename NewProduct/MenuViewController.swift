//
//  MenuViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit
import Firebase

protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ index : Int32)
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var artistCreate = false
      var artistOn = false
    var dataRef = FIRDatabase.database().reference()
    var loggedUser = FIRAuth.auth()?.currentUser
    var skills = ""
    var name: String!
    var email: String!
    /**
    *  Array to display menu options
    */
    @IBOutlet var tblMenuOptions : UITableView!
    
    /**
    *  Transparent button to hide menu
    */
    @IBOutlet var btnCloseMenuOverlay : UIButton!
    
    /**
    *  Array containing menu options
    */
    var arrayMenuOptions = [Dictionary<String,String>]()
    
    /**
    *  Menu button which was tapped to display the menu
    */
    var btnMenu : UIButton!
    
    /**
    *  Delegate of the MenuVC
    */
    var delegate : SlideMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
            
            if UserDefaults.standard.bool(forKey: "artistCreate") == true
            {
                self.artistCreate = true
            }
            else
            {
                self.artistCreate = false
            }
        
        
        
       
        
        
        tblMenuOptions.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateArrayMenuOptions()
    }
    
    func updateArrayMenuOptions(){

        arrayMenuOptions.append(["title":"Activate Artist Profile", "icon":"Artist"])
        arrayMenuOptions.append(["title":"Messages", "icon":"Message"])
        arrayMenuOptions.append(["title":"About", "icon":"Info"])
        arrayMenuOptions.append(["title":"Privacy Policy", "icon":"Privacy"])
        arrayMenuOptions.append(["title":"Payment Information", "icon":"Payment"])
        
        tblMenuOptions.reloadData()
        
        
    }
    
    @IBAction func onCloseMenuClick(_ button:UIButton!){
        btnMenu.tag = 0
        
        if (self.delegate != nil) {
            var index = Int32(button.tag)
            if(button == self.btnCloseMenuOverlay){
                index = -1
            }
            delegate?.slideMenuItemSelectedAtIndex(index)
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellMenu")!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        let imgIcon : UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        
        if indexPath.row == 0
        {
            let switcher : UISwitch = cell.contentView.viewWithTag(102) as! UISwitch
            if artistOn == true
            {
                switcher.isOn = true
            }
            else if artistOn == false{
                
                switcher.isOn = false
            }
            switcher.isHidden = false
            switcher.addTarget(self, action: #selector(MenuViewController.switchStateDidChange(_:)), for: .valueChanged)
        }
        
        imgIcon.image = UIImage(named: arrayMenuOptions[indexPath.row]["icon"]!)
        lblTitle.text = arrayMenuOptions[indexPath.row]["title"]!
        
        return cell
    }
    
    func switchStateDidChange(_ sender:UISwitch!)
    {
          let myVCHome = storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
          let myVCArtist = storyboard?.instantiateViewController(withIdentifier: "Artist") as! ArtistViewController
        if (sender.isOn == true){
            
          
            
            if artistCreate == true{
                myVCHome.artistOn = true
                UserDefaults.standard.set("true", forKey: "artistOn")
                
                
                present(myVCHome, animated: true)
                
            }
            else
            {
                let alertContoller = UIAlertController(title: "Oops!", message: "You haven't created an Artist Profile yet! Would you like to make one?", preferredStyle: .alert)
                
                let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
                    alert -> Void in
                    
                    self.dataRef.child("users").child(self.loggedUser!.uid).observe(.value, with: { (snapshot) in
                        if snapshot.exists() == true
                        {
                            let snapshotValueSkill = snapshot.value as? NSDictionary
                            if let tempskills = snapshotValueSkill?["Skills"] as? String {
                               // print(tempskills)
                                self.skills = tempskills
                            }
                            
                            let snapshotValueName = snapshot.value as? NSDictionary
                            let tempname = snapshotValueName?["Name"] as? String
                          //  print(tempname!)
                            self.name = tempname
                            
                            let snapshotValueEmail = snapshot.value as? NSDictionary
                            let tempemail = snapshotValueEmail?["Email"] as? String
                            self.email = tempemail
                            
                            
                            
                            
                            
//                            let profVC = self.storyboard?.instantiateViewController(withIdentifier: "Profile") as! ViewController
                            
                            
                            
                            if self.skills == ""{
                                
                                let alertContoller2 = UIAlertController(title: "Oops!", message: "You haven't filled out necessary information. \n Go to My Foto and fill out the information", preferredStyle: .alert)
                                
                                let defaultAction = UIAlertAction(title: "Okay", style: .default, handler: {
                                    alert -> Void in
                                    sender.isOn = false
                                    myVCHome.artistOn = false
                                    UserDefaults.standard.removeObject(forKey: "artistOn")
                                    
                                })
                                alertContoller2.addAction(defaultAction)
                                self.present(alertContoller2, animated:true, completion: nil)
                                
                                
                            }
                            else if self.skills != ""{
//                                
                                
                                let inquirePost: [String : AnyObject] = ["Name": self.name as                                                      AnyObject,
                                                                                                                                          "token": self.loggedUser!.uid as AnyObject,
                                                                                                     "Rating": Int(0) as AnyObject,
                                                                                                     "Skills": self.skills as AnyObject,
                                                                                                     "Email": self.email as AnyObject]

                               self.dataRef.child("artistProfiles").child(self.loggedUser!.uid).setValue(inquirePost)
                                
                                self.dataRef.child("users").child(self.loggedUser!.uid).child("pic").observe(.value){
                                    (snap: FIRDataSnapshot) in
                                    
                                    if snap.exists() == true
                                    {
                                        self.dataRef.child("artistProfiles").child(self.loggedUser!.uid).child("pic").setValue(snap.value as! String)
                                    }
                                    else{
                                        self.dataRef.child("artistProfiles").child(self.loggedUser!.uid).child("pic").setValue("default.ca")
                                    }
                                }
                                UserDefaults.standard.set("true", forKey: "artistOn")
                                myVCHome.artistOn = true
                            
                               // myVCArtist.token = self.loggedUser!.uid
                                self.present(myVCHome, animated: true)
                                
                                
                            }

                            
                        }
                        
                    })
                    
                    
                })
                
                let noAction = UIAlertAction(title: "No", style: .cancel, handler: {
                    alert -> Void in
                    
                    myVCHome.artistOn = false
                    UserDefaults.standard.removeObject(forKey: "artistOn")
                    sender.isOn = false
                })
                
                
                alertContoller.addAction(yesAction)
                alertContoller.addAction(noAction)
                self.present(alertContoller, animated:true, completion: nil)
            }

            
        }
        else{
            myVCHome.artistOn = false
            UserDefaults.standard.removeObject(forKey: "artistOn")
            
           present(myVCHome, animated: true)
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButtonType.custom)
        btn.tag = indexPath.row
        self.onCloseMenuClick(btn)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMenuOptions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
}
