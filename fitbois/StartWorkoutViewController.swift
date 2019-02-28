//
//  StartWorkoutViewController.swift
//  fitbois
//
//  Created by Krishna Chenna on 11/22/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//
//  This View controller is the workout routine, while in action. The user is able to start the workout and select all the completed workouts while in the process of working out. A timer goes off in the middle of said workout and keeps track of the time of the workout. The user is able to start and stop the timer as they please and select the workouts completed out of the list of set workouts within the routine. Once completed, the workout is saved in the database.

import UIKit
import FirebaseDatabase

class StartWorkoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var bufferingLogo: UIActivityIndicatorView!
    @IBOutlet weak var exercisesTable: UITableView!
    @IBOutlet weak var timerLabel: UILabel!
    
    var workoutName: String = ""
    var firebaseReference: DatabaseReference!
    var exercises = [NewWorkoutViewController.Exercise]()
    var startTime: Double = 0
    var time: Double = 0
    var elapsed: Double = 0
    var status: Bool = false
    let e164PhoneNumber = Storage.phoneNumberInE164 ?? ""
    weak var timer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        firebaseReference = Database.database().reference()
        exercisesTable.delegate = self
        exercisesTable.dataSource = self
        exercisesTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelWorkout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finishWorkout))
        navigationItem.title = workoutName
        startButton.layer.cornerRadius = startButton.frame.height / 2
        bufferingLogo.startAnimating()
        // Populates the table view with all the workouts for the selected routine.
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
                self.exercisesTable.reloadData()
                self.bufferingLogo.stopAnimating()
            }
        })
    }
    
    // Number of rows in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    
    // Populate the view controller with the exercises and the number of sets and reps that user has set
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = self.exercises[indexPath.row].name
        let details = "Sets: " + String(self.exercises[indexPath.row].sets) + " Reps: " + String(self.exercises[indexPath.row].reps) + " Weight: " + String(self.exercises[indexPath.row].weight) + "lbs"
        cell.detailTextLabel?.text = details
        return cell
    }
    
    
    // Allows user tap an exercise to signify completion
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if(cell.isSelected && cell.accessoryType == .checkmark){
                cell.accessoryType = .none
                self.exercises[indexPath.row].isChecked = false
            } else if cell.isSelected {
                cell.accessoryType = .checkmark
                self.exercises[indexPath.row].isChecked = true
            }
            
        }
    }
    
    
    @IBAction func startWorkoutTimer(_ sender: Any) {
        if(startButton.titleLabel?.text == "Start"){
            start()
            startButton.backgroundColor = UIColor.red
            startButton.setTitle("Stop", for: .normal)
        } else {
            stop()
            startButton.backgroundColor = UIColor.green
            startButton.setTitle("Start", for: .normal)
        }
    }
    
    
    @objc func cancelWorkout(){
        let alert = UIAlertController(title: "Exit Workout?", message: "Are you sure you would like to exit your workout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // Saves content of workout to database if at least one exercise is marked as done
    @objc func finishWorkout(){
        if(!testChecks()){
            let alert = UIAlertController(title: "Please mark the completed exercises!", message: "There are no exercises marked as completed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let workoutDuration = findTime(timeElapsed: elapsed)
        let date = Date()
        let currentMonth = Calendar.current.component(.month, from: date)
        let currentDay = Calendar.current.component(.day, from: date)
        let currentYear = Calendar.current.component(.year, from: date)
        let workoutDate = "\(currentMonth)-\(currentDay)-\(currentYear)"
        
        let alert = UIAlertController(title: "Workout Completed!", message: "Are you sure you would like to end your workout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            for exer in self.exercises{
                if(exer.isChecked){
                    print(exer)
                    self.firebaseReference.child(self.e164PhoneNumber).child("History").child(workoutDate).child(self.workoutName).child(exer.name).child("Sets").setValue(exer.sets)
                    self.firebaseReference.child(self.e164PhoneNumber).child("History").child(workoutDate).child(self.workoutName).child(exer.name).child("Reps").setValue(exer.reps)
                    self.firebaseReference.child(self.e164PhoneNumber).child("History").child(workoutDate).child(self.workoutName).child(exer.name).child("Weight").setValue(exer.weight)
                    
                }
            }
            self.firebaseReference.child(self.e164PhoneNumber).child("History").child(workoutDate).child(self.workoutName).child("Workout Time").setValue(workoutDuration)
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // Returns false unless an exercise in the current workout is checked
    func testChecks() -> Bool{
        for exer in self.exercises{
            if(exer.isChecked){
                return true
            }
        }
        return false
    }
    
    
    // Function to start the timer.
    func start() {
        startTime = Date().timeIntervalSinceReferenceDate - elapsed
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        status = true
    }
    
    
    // Function to end the timer.
    func stop() {
        elapsed = Date().timeIntervalSinceReferenceDate - startTime
        timer?.invalidate()
        status = false
    }
    
    
    // Function to consistently keep the timer updated.
    @objc func updateCounter() {
        time = Date().timeIntervalSinceReferenceDate - startTime
        timerLabel.text = findTime(timeElapsed: time)
    }
    
    
    // Return the time in terms of hours, minutes and seconds.
    func findTime(timeElapsed: Double) -> (String){
        var time = timeElapsed
        let hours = UInt8(time/3600.0)
        time -= (TimeInterval(hours) * 60)
        let minutes = UInt8(time / 60.0)
        time -= (TimeInterval(minutes) * 60)
        let seconds = UInt8(time)
        time -= TimeInterval(seconds)
        let strHours = String(format: "%02d", hours)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        
        return strHours + ":" + strMinutes + ":" + strSeconds
    }
}
    

