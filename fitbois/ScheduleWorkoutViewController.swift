//
//  ScheduleWorkoutViewController.swift
//  fitbois
//
//  Created by Krishna Chenna on 12/3/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//
// View controller to allow users to set a schedule specific workout routines on specific days. They are able to choose from selections of workout routines that they have created and may select the routines on the days they prefer, which then stores this information in the database. The user would then get a notification regarding the workout scheduled for that day at an alloted time.

import UIKit
import FirebaseDatabase

class ScheduleWorkoutViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // All the pickers for each day of the week.
    @IBOutlet weak var mondayPicker: UIPickerView!
    @IBOutlet weak var tuesdayPicker: UIPickerView!
    @IBOutlet weak var wednesdayPicker: UIPickerView!
    @IBOutlet weak var thursdayPicker: UIPickerView!
    @IBOutlet weak var fridayPicker: UIPickerView!
    @IBOutlet weak var saturdayPicker: UIPickerView!
    @IBOutlet weak var sundayPicker: UIPickerView!
    @IBOutlet weak var bufferingLogo: UIActivityIndicatorView!
    
    // Variables storing the selected workout
    var mondayWorkout:String = ""
    var tuesdayWorkout:String = ""
    var wednesdayWorkout:String = ""
    var thursdayWorkout:String = ""
    var fridayWorkout:String = ""
    var saturdayWorkout:String = ""
    var sundayWorkout:String = ""
    var firebaseReference: DatabaseReference!
    var workoutNames = [String]()
    var workoutList = [String]()
    let e164PhoneNumber = Storage.phoneNumberInE164 ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Schedule Workouts"
        
        workoutNames.append("No Workout")
        workoutNames.append(contentsOf: workoutList)
        
        firebaseReference = Database.database().reference()
        mondayPicker.delegate = self
        mondayPicker.dataSource = self
        tuesdayPicker.delegate = self
        tuesdayPicker.dataSource = self
        wednesdayPicker.delegate = self
        wednesdayPicker.dataSource = self
        thursdayPicker.delegate = self
        thursdayPicker.dataSource = self
        fridayPicker.delegate = self
        fridayPicker.dataSource = self
        saturdayPicker.delegate = self
        saturdayPicker.dataSource = self
        sundayPicker.delegate = self
        sundayPicker.dataSource = self
        
        pickDefaultPositions()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveSchedule))
    }
    
    @objc func saveSchedule() {
        fillEmpty()
        self.firebaseReference.child(self.e164PhoneNumber).child("History").child("Schedule").child("Monday").setValue(mondayWorkout)
        self.firebaseReference.child(self.e164PhoneNumber).child("History").child("Schedule").child("Tuesday").setValue(tuesdayWorkout)
        self.firebaseReference.child(self.e164PhoneNumber).child("History").child("Schedule").child("Wednesday").setValue(wednesdayWorkout)
        self.firebaseReference.child(self.e164PhoneNumber).child("History").child("Schedule").child("Thursday").setValue(thursdayWorkout)
        self.firebaseReference.child(self.e164PhoneNumber).child("History").child("Schedule").child("Friday").setValue(fridayWorkout)
        self.firebaseReference.child(self.e164PhoneNumber).child("History").child("Schedule").child("Saturday").setValue(saturdayWorkout)
        self.firebaseReference.child(self.e164PhoneNumber).child("History").child("Schedule").child("Sunday").setValue(sundayWorkout)
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "routinePage") as! RoutineViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return workoutNames.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return workoutNames[row]
    }
    
    
    @IBAction func setNotificationTime(_ sender: Any) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "timePage") as! TimeViewController
        popOverVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        navigationController?.present(popOverVC, animated: true)
        
    }
    
    
    func pickDefaultPositions(){
        bufferingLogo.startAnimating()
        firebaseReference.child(e164PhoneNumber).child("History").child("Schedule").observeSingleEvent(of: .value, with:{ (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                switch(snap.key){
                case "Monday":
                    let workoutStr = snap.value as? String ?? "No Workout"
                    let index = self.workoutNames.index(of: workoutStr) ?? 0
                    self.mondayPicker.selectRow(index, inComponent: 0, animated: true)
                    self.mondayWorkout = workoutStr
                    if(index == 0){
                        self.firebaseReference.child(self.e164PhoneNumber).child("History").child("Schedule").child(snap.key).setValue("No Workout")
                    }
                    break
                case "Tuesday":
                    let workoutStr = snap.value as? String ?? "No Workout"
                    let index = self.workoutNames.index(of: workoutStr) ?? 0
                    self.tuesdayPicker.selectRow(self.workoutNames.index(of: workoutStr) ?? 0, inComponent: 0, animated: true)
                    self.tuesdayWorkout = workoutStr
                    if(index == 0){
                        self.firebaseReference.child(self.e164PhoneNumber).child("History").child("Schedule").child(snap.key).setValue("No Workout")
                    }
                    break
                case "Wednesday":
                    let workoutStr = snap.value as? String ?? "No Workout"
                    let index = self.workoutNames.index(of: workoutStr) ?? 0
                    self.wednesdayPicker.selectRow(self.workoutNames.index(of: workoutStr) ?? 0, inComponent: 0, animated: true)
                    self.wednesdayWorkout = workoutStr
                    if(index == 0){
                        self.firebaseReference.child(self.e164PhoneNumber).child("History").child("Schedule").child(snap.key).setValue("No Workout")
                    }
                    break
                case "Thursday":
                    let workoutStr = snap.value as? String ?? "No Workout"
                    let index = self.workoutNames.index(of: workoutStr) ?? 0
                    self.thursdayPicker.selectRow(self.workoutNames.index(of: workoutStr) ?? 0, inComponent: 0, animated: true)
                    self.thursdayWorkout = workoutStr
                    if(index == 0){
                        self.firebaseReference.child(self.e164PhoneNumber).child("History").child("Schedule").child(snap.key).setValue("No Workout")
                    }
                    break
                case "Friday":
                    let workoutStr = snap.value as? String ?? "No Workout"
                    let index = self.workoutNames.index(of: workoutStr) ?? 0
                    self.fridayPicker.selectRow(self.workoutNames.index(of: workoutStr) ?? 0, inComponent: 0, animated: true)
                    self.fridayWorkout = workoutStr
                    if(index == 0){
                        self.firebaseReference.child(self.e164PhoneNumber).child("History").child("Schedule").child(snap.key).setValue("No Workout")
                    }
                    break
                case "Saturday":
                    let workoutStr = snap.value as? String ?? "No Workout"
                    let index = self.workoutNames.index(of: workoutStr) ?? 0
                    self.saturdayPicker.selectRow(self.workoutNames.index(of: workoutStr) ?? 0, inComponent: 0, animated: true)
                    self.saturdayWorkout = workoutStr
                    if(index == 0){
                        self.firebaseReference.child(self.e164PhoneNumber).child("History").child("Schedule").child(snap.key).setValue("No Workout")
                    }
                    break
                case "Sunday":
                    let workoutStr = snap.value as? String ?? "No Workout"
                    let index = self.workoutNames.index(of: workoutStr) ?? 0
                    self.sundayPicker.selectRow(self.workoutNames.index(of: workoutStr) ?? 0, inComponent: 0, animated: true)
                    self.sundayWorkout = workoutStr
                    if(index == 0){
                        self.firebaseReference.child(self.e164PhoneNumber).child("History").child("Schedule").child(snap.key).setValue("No Workout")
                    }
                    break
                default:
                    print("scam")
                }
            }
        })
        bufferingLogo.stopAnimating()
    }
    
    
    func fillEmpty(){
        if(mondayWorkout == ""){
            mondayWorkout = "No Workout"
        }
        if(tuesdayWorkout == ""){
            tuesdayWorkout = "No Workout"
        }
        if(wednesdayWorkout == ""){
            wednesdayWorkout = "No Workout"
        }
        if(thursdayWorkout == ""){
            thursdayWorkout = "No Workout"
        }
        if(fridayWorkout == ""){
            fridayWorkout = "No Workout"
        }
        if(saturdayWorkout == ""){
            saturdayWorkout = "No Workout"
        }
        if(sundayWorkout == ""){
            sundayWorkout = "No Workout"
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == mondayPicker {
            mondayWorkout = self.workoutNames[row]
        } else if pickerView == tuesdayPicker {
            tuesdayWorkout = self.workoutNames[row]
        } else if pickerView == wednesdayPicker {
            wednesdayWorkout = self.workoutNames[row]
        } else if pickerView == thursdayPicker {
            thursdayWorkout = self.workoutNames[row]
        } else if pickerView == fridayPicker {
            fridayWorkout = self.workoutNames[row]
        } else if pickerView == saturdayPicker {
            saturdayWorkout = self.workoutNames[row]
        } else if pickerView == sundayPicker {
            sundayWorkout = self.workoutNames[row]
        }
    }
}
