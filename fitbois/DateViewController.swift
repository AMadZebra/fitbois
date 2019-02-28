//
//  DateViewController.swift
//  fitbois
//
//  Created by Luc Nglankong on 11/21/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//

import UIKit
import FirebaseDatabase

// View controller for past workout data
class DateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ExpandableHeaderViewDelegate {
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var currentDate: UILabel!
    
    let goldColor = UIColor(red: 0.635, green: 0.584, blue: 0, alpha: 1.0)
    let whiteColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var workoutsArray = [workoutDetails]()
    var date = Date()
    var firebaseReference: DatabaseReference!
    var givenDate: String?
    
    struct workoutDetails {
        var workoutName : String!
        var time : String!
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
        
        // get the month, day, and year of user's selected date
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        let year = Calendar.current.component(.year, from: date)
        
        // set the tableview delegate and datasource
        historyTableView.delegate = self
        historyTableView.dataSource = self

        // Show date selected
        currentDate.text = "Workout History For: \(month)-\(day)-\(year)"
        
        // Save date selected
        self.givenDate = "\(month)-\(day)-\(year)"
        guard let givenDate = self.givenDate else{
            print("ERROR: Unable to find selected date in database")
            return
        }
        
        firebaseReference = Database.database().reference()
        
        let phoneNumber = Storage.phoneNumberInE164 ?? ""
        
        // Query for user's phone number -> "Workouts" -> chosen date
        firebaseReference.child(phoneNumber).child("History").child(givenDate).observeSingleEvent(of: .value, with: { (snapshot) in
            
            var workoutsCounter = 0
            var firstWorkout = true
            
            // iterate through all workouts on this day
            for workouts in snapshot.children {
                
                // create a new workout
                var currentWorkout = workoutDetails()
                
                // create a new list of exercises for current workout
                var exercisesArray = [exerciseDetails]()
                
                let workoutsChild = workouts as! DataSnapshot
                
                let workoutKey = workoutsChild.key
                
                // iterate through all exercises in current workout
                for child in workoutsChild.children {
                    
                    let snap = child as! DataSnapshot
                    
                    let exerciseKey = snap.key
                    
                    // handle when encountering "Workout Time"
                    if(exerciseKey != "Workout Time"){
                        // save exercise
                        guard let dict = snap.value as? [String: Any] else{
                            print("ERROR: cannot read dict from database")
                            return
                        }
                        
                        var currentExercise = exerciseDetails()
                        
                        // set exercise data
                        currentExercise.exerciseName = exerciseKey
                        currentExercise.sets = (dict["Sets"] as! Int)
                        currentExercise.reps = (dict["Reps"] as! Int)
                        currentExercise.weight = (dict["Weight"] as! Int)
                        exercisesArray.append(currentExercise)
                    }
                    
                    // refresh tableview
                    self.historyTableView.reloadData()
                }
                
                // Get firebase workout data
                guard let workoutsDict = workoutsChild.value as? [String: Any] else{
                    print("ERROR: cannot read workoutsDict from database")
                    return
                }
                
                // upon reading the first workout, expand it immediately in the table view
                if(firstWorkout == true){
                    currentWorkout.expanded = true
                    firstWorkout = false
                }
                
                // set workout data
                currentWorkout.exercisesArray = exercisesArray
                currentWorkout.workoutName = workoutKey
                currentWorkout.time = (workoutsDict["Workout Time"] as! String)

                // Append current workout to list of workouts
                self.workoutsArray.append(currentWorkout)
                workoutsCounter = workoutsCounter+1
                
            }
            //reload tableview
            self.historyTableView.reloadData()
        })
        
        // reload tableview
        self.historyTableView.reloadData()
    }
    
    
    // set number of sections in tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        // number of sections is the number of workouts
        return self.workoutsArray.count
    }
    
    
    // set number of rows in section for tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // number of rows is the number of exercises per section
        let size = self.workoutsArray[section].exercisesArray.count
        return size
    }
    
    
    // set height of cell header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    
    // set height of cell footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // empty footer will be used to show space in between cells
        return 10
    }
    
    
    // set cell footer color to gold
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footerView = view as? UITableViewHeaderFooterView {
            footerView.contentView.backgroundColor = self.goldColor
        }
    }

    
    // set height of cell row to be 150 when expanded, and 0 when not expanded
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.workoutsArray[indexPath.section].expanded{
            return 150
        }else{
            return 0
        }
    }
    
    
    // setup cell section header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // prepare cell header to make it expandable
        let header = ExpandableHeaderView()
        header.customInit(title: self.workoutsArray[section].workoutName, section: section, time: self.workoutsArray[section].time, delegate: self)
       
        return header
    }
    
    
    // setup cell row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "exercises", for: indexPath) as? ExerciseTableCellTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ExerciseTableCellTableViewCell.")
        }
            
        //set cell row to exercise data
        cell.cellExerciseLabel.text = "\(self.workoutsArray[indexPath.section].exercisesArray[indexPath.row].exerciseName!)"
        cell.cellSetsLabel.text = "\(self.workoutsArray[indexPath.section].exercisesArray[indexPath.row].sets!)"
        cell.cellRepsLabel.text = "\(self.workoutsArray[indexPath.section].exercisesArray[indexPath.row].reps!)"
        cell.cellWeightLabel.text = "\(self.workoutsArray[indexPath.section].exercisesArray[indexPath.row].weight!)"
        
        return cell
    }
    
    
    // called when user selects cell row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
    // handles header expansion
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        // set header to expanded if not expanded and vice versa
        self.workoutsArray[section].expanded = !self.workoutsArray[section].expanded
        
        // reload rows in section
        self.historyTableView.beginUpdates()
        for i in 0 ..< self.workoutsArray[section].exercisesArray.count{
            self.historyTableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        self.historyTableView.endUpdates()
    }
}
