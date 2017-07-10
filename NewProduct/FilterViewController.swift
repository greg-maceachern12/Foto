//
//  FilterViewController.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-07-04.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//
import UIKit

class FilterViewController: UIViewController, UITextFieldDelegate {

 
    @IBOutlet weak var tbSkills: UITextField!
    @IBOutlet weak var tbMaximum: UITextField!
     @IBOutlet weak var FingerClick: UIButton!
    
    var takenPosts = [postStruct2]()
    var filteredTakenPosts = [postStruct2]()
    //var newarray = [postStruct2]()
    let step: Float = 5
    var skill: String!
    var maxNumber: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbMaximum.delegate = self
        tbSkills.delegate = self
        

        
        //print(takenPosts)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
   
    @IBAction func FingerApply(_ sender: Any) {
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ArtistTable") as! aaViewController
//        
        if tbMaximum.text != "" && tbSkills.text != ""{
            
            skill = tbSkills.text?.lowercased()
            print(takenPosts)
            
            maxNumber = Float(tbMaximum.text!)
            
             filteredTakenPosts  = self.takenPosts.filter{$0.skills.lowercased().contains(skill!)}
            
            
            filteredTakenPosts  = self.filteredTakenPosts.filter{$0.price2 < maxNumber}
            
            
           
        }
        
        else if tbMaximum.text != "" && tbSkills.text == ""{
            
            
            maxNumber = Float(tbMaximum.text!)
            
            filteredTakenPosts  = self.takenPosts.filter{$0.price2 < maxNumber}
    
        }
        else if tbMaximum.text == "" && tbSkills.text != ""{
            
            
            skill = tbSkills.text?.lowercased()
          
            
   
            self.filteredTakenPosts  = self.filteredTakenPosts.filter{$0.skills.lowercased().contains(self.skill!)}
            print(self.filteredTakenPosts)
            
            
        }
        
        myVC.searchPosts.removeAll()
        myVC.filteredPosts.removeAll()
        myVC.filteredPosts = filteredTakenPosts
        myVC.searchPosts = filteredTakenPosts
        myVC.run = true
        
        self.present(myVC, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        tbMaximum.resignFirstResponder()
        tbSkills.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tbMaximum{
//            if tbMaximum.text == ""
//            {
//                print("YE")
//                filteredTakenPosts = takenPosts
//                FingerClick.isHidden = true
//            }
//            else{
//                maxNumber = Float(tbMaximum.text!)
//               
//                //
//                filteredTakenPosts  = self.takenPosts.filter{$0.price2 < maxNumber}
                FingerClick.isHidden = false
                FingerClick.titleLabel?.text = String(filteredTakenPosts.count)
//
//    //            }
//            }
        }
        else if textField == tbSkills
        {
            //skill = tbSkills.text?.lowercased()
            FingerClick.isHidden = false
            FingerClick.titleLabel?.text = String(filteredTakenPosts.count)
        }
        
    }
}
