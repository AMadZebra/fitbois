//
//  ExercisesViewController.swift
//  fitbois
//
//  Created by Krishna Chenna on 11/13/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//
//  This View controller provides the user with a list of exercises that are specific to the muscle group selected and add that exercise to the list of exercises that the user is saving in the database.

import UIKit
import Darwin

class ExercisesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var selectLbl: UILabel!
    @IBOutlet weak var exerciseTable: UITableView!
    
    var bodyPart:String = ""
    var workoutName = ""
    var exerciseArr = [NewWorkoutViewController.Exercise]()
    var bodyPartExercises = [NewWorkoutViewController.Exercise]()
    var exercises = [String]()
    var chosenExercise: String = ""
    var workoutNames = [String]()
	let exerciseLibrary = [
		"Abs": ["Ab wheel rollout", "Crunch", "Elbow to knee", "Flutter kick", "Landmine", "Leg raise", "Plank", 
				"Russian twist", "Sit up", "Swiss ball crunch"],
		"Biceps": ["Bicep curl (barbell)", "Bicep curl (dumbbell)", "Cable curl", "Concentration curl", "Hammer curl", "Incline curl (dumbbell)", "Incline curl (barbell)", "Preacher curl"],
        "Triceps": ["Skullcrusher (dumbbell)", "Skullcrusher (EZ bar)", "Tricep pushdown","Close grip bench press", "Diamond push up", "Parallel bar dip"],
		"Back": ["Barbell row", "Deadlift", "Deficit deadlift", "Dumbbell row", "Lat pulldown", "Pause deadlift",
				 "Pull up", "Romanian deadlift", "Seated cable row", "T-bar row"],
		"Chest": ["Bench press (barbell)", "Bench press (dumbbell)", "Cable fly",
				  "Decline bench press (barbell)", "Decline bench press (dumbbell)", "Dumbbell fly",
				  "Incline bench press (barbell)", "Incline bench press (dumbbell)", "Push up", "Spoto press"],
		"Forearms": ["Dumbbell wrist flexion", "Dumbbell wrist extension","Dumbbell reverse curl","Farmer walks", 
					 "Pull-up bar hang"],
		"Legs": ["Back extension", "Box squat", "Dumbbell step up", "Front squat", "Farmer's walk", "Glute bridge",
				 "Glute-ham raise", "Goblet squat", "Good morning", "Hack squat", "Leg curl", "Leg extension", 
				 "Leg press", "Leg raise", "Lunge (dumbbell)", "Pause squat", "Power clean", "Squat"],
		"Shoulders": ["Arnold press", "Face pull", "Front raise", "Incline shoulder press (barbell)",
					  "Incline shoulder press (dumbbell)", "Reverse fly", "Seated shoulder press (barbell)", 
					  "Seated shoulder press (dumbbell)", "Seated EZ-bar French press", "Side lateral raise", 
					  "Standing military press (barbell)", "Standing military press (dumbbell)", 
					  "Upright row (barbell)", "Upright row (dumbbell)"]
	]
    
    struct Exercise {
        var name: String
        var sets: Int
        var reps: Int
        var weight: Int
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = workoutName
        selectLbl.text = "Select " + bodyPart + " Exercise"
        exerciseTable.delegate = self
        exerciseTable.dataSource = self
        exerciseTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        exerciseTable.tableFooterView = UIView(frame: CGRect.zero)
        loadExercises(bodyPart: bodyPart)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bodyPartExercises.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.bodyPartExercises[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        cell.accessoryType = .detailButton
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "setDetailsPage") as! ExerciseDetailsViewController
        vc.selectedExercise = self.bodyPartExercises[indexPath.row].name
        vc.exerciseArr = self.exerciseArr
        vc.workoutName = workoutName
        vc.workoutNames = self.workoutNames
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // Opens a google search for the exercise in the row the information icon is pressed
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let urlString = "https://www.google.com/search?q=" + self.bodyPartExercises[indexPath.row].name.replacingOccurrences(of: " ", with: "+") + "+exercise"
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
        print("Accessory btn tapped")
    }
    
    
    // Loads exercises for a given muscle group on click
    func loadExercises(bodyPart: String){
        let exerciseNames = exerciseLibrary[bodyPart] ?? [""]
        
        for exercise in exerciseNames{
            let exercise = NewWorkoutViewController.Exercise(name: exercise, sets: 3, reps: 10, weight: 45, isChecked: false)
            bodyPartExercises.append(exercise)
        }
        exerciseTable.reloadData()
    }
}
