//
//  ExperienceLevelViewController.swift
//  fitbois
//
//  Created by Ibrahim Elsakka on 12/3/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ExperienceLevelViewController: UIViewController {
    @IBOutlet weak var beginnerButton: UIButton!
    @IBOutlet weak var intermediateButton: UIButton!
    @IBOutlet weak var advancedButton: UIButton!
    
    var firebaseReference: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Exerience Level"
        firebaseReference = Database.database().reference()
        beginnerButton.layer.cornerRadius = beginnerButton.frame.height / 2
        intermediateButton.layer.cornerRadius = intermediateButton.frame.height / 2
        advancedButton.layer.cornerRadius = advancedButton.frame.height / 2
    }
    
    
    @IBAction func userPressedExperienceLevel(_ sender: UIButton) {
        let e164PhoneNumber = Storage.phoneNumberInE164 ?? ""
        let experienceLevel = sender.titleLabel!.text!
        
        firebaseReference.child("Preset workouts").child(experienceLevel).observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let routine = child as! DataSnapshot
                for child in routine.children {
                    let exercise = child as! DataSnapshot
                    for child in exercise.children {
                        let details = child as! DataSnapshot
                        self.firebaseReference.child(e164PhoneNumber).child("Workouts").child(routine.key).child(exercise.key).child(details.key).setValue(details.value)
                    }
                }
            }
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "routinePage") as! RoutineViewController
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    
    @IBAction func userPressedSkip(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "routinePage") as! RoutineViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
