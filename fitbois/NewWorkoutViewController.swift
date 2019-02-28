//
//  newWorkoutViewController.swift
//  fitbois
//
//  Created by Krishna Chenna on 11/20/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//
//  This View Controller allows the user to either create a new workout or edit an existing workout. It prompts the user with an option to add new workouts, which they are allowed to select. by adding a new workout. They may alter the name of the workout by pressing the edit button or cancel the creation/editing of the workout by pressing the cancel button. They are prompted with a save button to save the list of workouts to the Database under their phone number.
//

import UIKit
import FirebaseDatabase

class NewWorkoutViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var workoutTable: UITableView!
    @IBOutlet weak var workoutNameLabel: UILabel!
    @IBOutlet weak var bufferingLogo: UIActivityIndicatorView!
    @IBOutlet weak var saveButton: UIButton!
    
    var firebaseReference: DatabaseReference!
    let defaults = UserDefaults.standard
    var workoutName: String = ""
    var exercises = [Exercise]()
    var routines = [Routine]()
    var workoutNames = [String]()
    var type:String = ""
    
    
    struct Exercise {
        var name: String
        var sets: Int
        var reps: Int
        var weight: Int
        var isChecked: Bool
    }
    
    
    struct Routine {
        var name: String
        var exercises = [Exercise]()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        workoutTable.delegate = self
        workoutTable.dataSource = self
        workoutTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        workoutTable.reloadData()
        workoutTable.tableFooterView = UIView(frame: CGRect.zero)
        let e164PhoneNumber = Storage.phoneNumberInE164 ?? ""
        firebaseReference = Database.database().reference()
        
        // Check if user is editing current workout or creating a new workout
        if(type == "Edit"){
            bufferingLogo.startAnimating()
            firebaseReference.child(e164PhoneNumber).child("Workouts").child(workoutName).observeSingleEvent(of: .value, with: { (snapshot) in
                
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    var newExercise: NewWorkoutViewController.Exercise
                    guard let dict = snap.value as? [String: Any] else{
                        print("scam")
                        return
                    }
                    let key = snap.key
                    newExercise = NewWorkoutViewController.Exercise.init(name: key, sets: dict["Sets"] as! Int, reps: dict["Reps"] as! Int, weight: dict["Weight"] as! Int, isChecked: false)
                    self.exercises.append(newExercise)
                    self.workoutTable.reloadData()
                }
                self.bufferingLogo.stopAnimating()
            })
            workoutNameLabel.text = workoutName
            self.defaults.set(workoutName, forKey: "workoutName")
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editWorkout(_:)))
            if let workoutName = defaults.string(forKey: "workoutName") {
                workoutNameLabel.text = workoutName
            }
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelWorkoutCreation(_ :)))
    }
    
    
    // List total number of required rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        workoutTable.layoutIfNeeded()
        workoutTable.heightAnchor.constraint(equalToConstant: tableView.contentSize.height).isActive = true
        return exercises.count
    }
    
    
    // Populate table with set exercises
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = exercises[indexPath.row].name
        let details = "Sets: " + String(self.exercises[indexPath.row].sets) + " Reps: " + String(self.exercises[indexPath.row].reps) + " Weight: " + String(self.exercises[indexPath.row].weight) + "lbs"
        cell.detailTextLabel?.text = details
        return cell
    }
    
    
    // Allow user to delete added exercise
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            exercises.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    
    @IBAction func addNewExercise(_ sender: Any) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "workoutPage") as! WorkoutViewController
        vc.exerciseArr = exercises
        vc.workoutName = self.workoutName
        vc.workoutNames = self.workoutNames
        self.navigationController?.pushViewController(vc, animated: true)
    }


    @IBAction func cancelWorkoutCreation(_ sender: Any) {
        let alert = UIAlertController(title: "Would you like to Cancel \(workoutNameLabel.text!)?", message: "Deletes the current workout being created!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "routinePage") as! RoutineViewController
            self.navigationController?.pushViewController(vc, animated: false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    

    @IBAction func saveWorkout(_ sender: Any) {
        let workoutName = self.workoutNameLabel.text ?? ""
        let e164PhoneNumber = Storage.phoneNumberInE164 ?? ""
        if(exercises.count > 0 && !workoutNames.contains(workoutName)){
            let routineToAdd = Routine.init(name: workoutName , exercises: self.exercises)
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "routinePage") as! RoutineViewController
            vc.routines.append(routineToAdd)
            firebaseReference.child(e164PhoneNumber).child("Workouts").child(workoutName).removeValue()
            for exer in self.exercises {
                firebaseReference.child(e164PhoneNumber).child("Workouts").child(workoutName).child(exer.name).child("Sets").setValue(exer.sets)
                firebaseReference.child(e164PhoneNumber).child("Workouts").child(workoutName).child(exer.name).child("Reps").setValue(exer.reps)
                firebaseReference.child(e164PhoneNumber).child("Workouts").child(workoutName).child(exer.name).child("Weight").setValue(exer.weight)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        } else if(workoutNames.contains(workoutName)){
            let alert = UIAlertController(title: "\(workoutNameLabel.text!) already exists!", message: "Please make sure the name of the workout is unique!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            }))
            self.present(alert, animated: true, completion: nil)
        } else if(exercises.count == 0){
            let alert = UIAlertController(title: "Please add exercises for \(workoutNameLabel.text!)", message: "At least one exercise is required!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    

    @IBAction func editWorkout(_ sender: Any) {
        var workoutName:String = ""
        let alert = UIAlertController(title: "Enter Workout Name", message: "Please Enter Name of Workout!", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))")
            workoutName = textField?.text ?? ""
            if(workoutName != ""){
                self.workoutNameLabel.text = workoutName
                self.defaults.set(workoutName, forKey: "workoutName")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
    }
}
