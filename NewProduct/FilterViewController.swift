//
//  FilterViewController.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-07-04.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//
import UIKit

class FilterViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

 
    @IBOutlet weak var tbSkills: UITextField!
    @IBOutlet weak var tbMaximum: UITextField!
     @IBOutlet weak var FingerClick: UIButton!
    @IBOutlet weak var RegionPicker: UIPickerView!
    
    var takenPosts = [postStruct2]()
    var filteredTakenPosts = [postStruct2]()
    //var newarray = [postStruct2]()
    let step: Float = 5
    var skill: String!
    var loc: String!
    var maxNumber: Float!
     var pickerData = ["All of Ontario", "Barrie", "Belleville Area", "Brantford", "Brockville", "Chatham-Kent", "Cornwall","Guelph", "Hamilton", "Kapuskasing", "Kenora", "Kingston Area", "Kitchener Area", "Leamington", "London", "Muskoka", "Norfolk Country", "North Bay", "Ottawa Area", "Owen Sound", "Peterborough", "Renfrew County", "Sarnia", "Saugeen Shores", "Sault Ste. Marie", "St.Catharines", "Sudbury", "Thunder Bay", "Timmins", "Toronto (GTA)", "Windsor", "Woodstock"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbMaximum.delegate = self
        tbSkills.delegate = self
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        tbSkills.inputAccessoryView = toolbar
        tbMaximum.inputAccessoryView = toolbar

        
        //print(takenPosts)
        // Do any additional setup after loading the view.
    }
    func doneClicked(){
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
  
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        loc = pickerData[row].lowercased()
        FingerClick.isHidden = false
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
            
          
            maxNumber = Float(tbMaximum.text!)
            
            if loc != "All of Ontario"{
    
             filteredTakenPosts  = self.takenPosts.filter{$0.location.lowercased().contains(loc!)}
            }
            
             filteredTakenPosts  = self.filteredTakenPosts.filter{$0.skills.lowercased().contains(skill!)}
            
            
            filteredTakenPosts  = self.filteredTakenPosts.filter{$0.price2 < maxNumber}
            
            
           
        }
        
        else if tbMaximum.text != "" && tbSkills.text == ""{
            
            
            maxNumber = Float(tbMaximum.text!)
            
            if loc != "All of Ontario"{
                filteredTakenPosts  = self.takenPosts.filter{$0.location.lowercased().contains(loc!)}
            }
            
            filteredTakenPosts  = self.filteredTakenPosts.filter{$0.price2 < maxNumber}
    
        }
        else if tbMaximum.text == "" && tbSkills.text != ""{
            
            
            skill = tbSkills.text?.lowercased()
            
          
            if loc != "All of Ontario"{
                
                filteredTakenPosts  = self.takenPosts.filter{$0.location.lowercased().contains(loc!)}
            }
   
            self.filteredTakenPosts  = self.filteredTakenPosts.filter{$0.skills.lowercased().contains(self.skill!)}
            print(self.filteredTakenPosts)
            
            
        }
        else if tbMaximum.text == "" && tbSkills.text == ""{
            if loc != "All of Ontario"{
                
                filteredTakenPosts  = self.takenPosts.filter{$0.location.lowercased().contains(loc!)}
            }
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
