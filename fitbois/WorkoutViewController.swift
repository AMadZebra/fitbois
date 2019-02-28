//
//  ViewController.swift
//  asdf
//
//  Created by Krishna Chenna on 11/12/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//
// This View controller provides the user with a list of options, which each signify a muscle group. This muscle group push to another view controller, which has an list of exercises specific to the muscle group.

import UIKit

class WorkoutViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var exerciseArr = [NewWorkoutViewController.Exercise]()
    var bodyParts = [String]()
    var workoutNames = [String]()
    var workoutName = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMuscleGroups()
        self.navigationItem.title = workoutName
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    func loadMuscleGroups(){
        bodyParts.append("Chest")
        bodyParts.append("Back")
        bodyParts.append("Biceps")
        bodyParts.append("Triceps")
        bodyParts.append("Forearms")
        bodyParts.append("Legs")
        bodyParts.append("Shoulders")
        bodyParts.append("Abs")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bodyParts.count
    }
    
    
    // Populate table with muscle groups
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = bodyParts[indexPath.row]
        return cell
    }
    
    
    // Send user to another view controller with specific set of exercises based on the muscle group selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "exercisesPage") as! ExercisesViewController
        vc.bodyPart = bodyParts[indexPath.row]
        vc.exerciseArr = self.exerciseArr
        vc.workoutNames = self.workoutNames
        vc.workoutName = workoutName
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
