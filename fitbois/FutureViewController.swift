//
//  FutureViewController.swift
//  fitbois
//
//  Created by Luc Nglankong on 12/5/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//

import UIKit
import FirebaseDatabase

// View controller for future planned workout data
class FutureViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ExpandableHeaderViewDelegate{
    @IBOutlet weak var futureTableView: UITableView!
    @IBOutlet weak var currentDate: UILabel!
    
    let goldColor = UIColor(red: 0.635, green: 0.584, blue: 0, alpha: 1.0)
    let e164PhoneNumber = Storage.phoneNumberInE164 ?? ""
    var workoutsArray = [workoutDetails]()
    var currentIndexRow: Int?
    var currentIndexSection: Int?
    var date = Date()
    var firebaseReference: DatabaseReference!
    var selectedIndexPath: IndexPath?
    var givenDate: String?
    
    struct workoutDetails {
        var workoutName : String!
        var expanded = false
        var exercisesArray = [exerciseDetails]()
    }
    
    struct exerciseDetails {
        var exerciseName: String!
        var sets : Int!
        var reps : Int!
        var weight : Int!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        let year = Calendar.current.component(.year, from: date)
        
        futureTableView.delegate = self
        futureTableView.dataSource = self
        
        
        // Show date selected
        currentDate.text = "\(month)-\(day)-\(year) Workout Plan:"
        self.givenDate = "\(month)-\(day)-\(year)"
        let dayOfWeekAsInt = self.getDayOfWeek("\(year)-\(month)-\(day)")
        let dayOfWeekAsName = self.getNameOfDay(weekDay: dayOfWeekAsInt)
        
        firebaseReference = Database.database().reference()
        
        // Query for user's phone number -> "History" -> "Schedule" -> Day of week
        firebaseReference.child(self.e164PhoneNumber).child("History").child("Schedule").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dayDict = snapshot.value as? [String: Any] else{
                print("ERROR: cannot read days of week from database")
                return
            }
            
            guard let selectedDay = dayOfWeekAsName else{
                print("ERROR: Cannot unwrap day of week")
                return
            }
            
            let scheduledWorkoutName = (dayDict["\(selectedDay)"] as! String)
            
            // Store workout information for day of week
            self.getWorkoutData(workoutName: scheduledWorkoutName)
        
            self.futureTableView.reloadData()
            
        })
        // reload tableview
        self.futureTableView.reloadData()
    }
    
    
    // Get name of date selected ("Sat" - "Sun") but in format 1-7, 1=sunday and 7=saturday
    func getDayOfWeek(_ today:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: today) else {
            print("ERROR: Could not determine today's date")
            return nil
            
        }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)

        return weekDay
    }
    
    
    // convert numeric representation of weekday (1-7) to name of weekday (sunday-saturday)
    func getNameOfDay(weekDay: Int?) -> String?{
        guard let weekDay = weekDay else{
            print("ERROR: Could not determine weekday")
            return ""
        }
        
        var nameOfDay: String?
        
        switch weekDay {
        case 1:
            nameOfDay = "Sunday"
        case 2:
            nameOfDay = "Monday"
        case 3:
            nameOfDay = "Tuesday"
        case 4:
            nameOfDay = "Wednesday"
        case 5:
            nameOfDay = "Thursday"
        case 6:
            nameOfDay = "Friday"
        default:
            nameOfDay = "Saturday"
        }
        return nameOfDay
    }
    
    
    func getWorkoutData(workoutName: String){
        firebaseReference.child(self.e164PhoneNumber).child("Workouts").child(workoutName).observeSingleEvent(of: .value, with: { (snapshot) in
            // create a new workout routine
            var currentWorkout = workoutDetails()
            
            // create a new list of exercises
            var exercisesArray = [exerciseDetails]()
            
            for exercises in snapshot.children {
                // iterate through all specific exercises in current workout
                
                let exerciseSnap = exercises as! DataSnapshot
                let exerciseKey = exerciseSnap.key
                
                var currentExercise = exerciseDetails()
                
                
                guard let exerciseDict = exerciseSnap.value as? [String: Any] else{
                    print("NOTE: cannot read dict from database")
                    return
                }
                
                // Save exercise details
                currentExercise.exerciseName = exerciseKey
                currentExercise.sets = (exerciseDict["Sets"] as! Int)
                currentExercise.reps = (exerciseDict["Reps"] as! Int)
                currentExercise.weight = (exerciseDict["Weight"] as! Int)
                exercisesArray.append(currentExercise)
                
            }
            
            // Save workout details
            currentWorkout.expanded = true
            currentWorkout.exercisesArray = exercisesArray
            currentWorkout.workoutName = workoutName
            
            // Append workout routine to list of workouts
            self.workoutsArray.append(currentWorkout)
            
            self.futureTableView.reloadData()
        })
        self.futureTableView.reloadData()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.workoutsArray.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let size = self.workoutsArray[section].exercisesArray.count
        return size
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // show space in between cells
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.workoutsArray[indexPath.section].expanded{
            return 150
        }else{
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footerView = view as? UITableViewHeaderFooterView {
            footerView.contentView.backgroundColor = self.goldColor
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandableHeaderView()
        header.customInit(title: self.workoutsArray[section].workoutName, section: section, time: "", delegate: self)
        
        // set header to workout name
        return header
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "exercises", for: indexPath) as? FutureViewCell  else {
            fatalError("The dequeued cell is not an instance of FutureViewCell.")
        }
        //set text information here
        cell.cellExerciseLabel.text = "\(self.workoutsArray[indexPath.section].exercisesArray[indexPath.row].exerciseName!)"
        cell.cellSetsLabel.text = "\(self.workoutsArray[indexPath.section].exercisesArray[indexPath.row].sets!)"
        cell.cellRepsLabel.text = "\(self.workoutsArray[indexPath.section].exercisesArray[indexPath.row].reps!)"
        cell.cellWeightLabel.text = "\(self.workoutsArray[indexPath.section].exercisesArray[indexPath.row].weight!)"
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        self.workoutsArray[section].expanded = !self.workoutsArray[section].expanded
        self.futureTableView.beginUpdates()
        for i in 0 ..< self.workoutsArray[section].exercisesArray.count{
            self.futureTableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        self.futureTableView.endUpdates()
    }
}
