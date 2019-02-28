//
//  SetDetailsViewController.swift
//  fitbois
//
//  Created by Krishna Chenna on 12/2/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//

import UIKit

class ExerciseDetailsViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    @IBOutlet weak var exerciseLabel: UILabel!
    @IBOutlet weak var setsPicker: UIPickerView!
    @IBOutlet weak var repsPicker: UIPickerView!
    @IBOutlet weak var weightPicker: UIPickerView!
    
    var exerciseArr = [NewWorkoutViewController.Exercise]()
    var selectedExercise:String = ""
    var workoutNames = [String]()
    var setsOptions = [String]()
    var repsOptions = [String]()
    var weightOptions = [String]()
    var selectedSets: Int = 0
    var selectedReps: Int = 0
    var selectedWeight: Int = 0
    var workoutName = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exerciseLabel.text = selectedExercise
        self.loadPickers()
        self.navigationItem.title = workoutName
        
        self.setsPicker.delegate = self
        self.setsPicker.dataSource = self
        self.repsPicker.delegate = self
        self.repsPicker.dataSource = self
        self.weightPicker.delegate = self
        self.weightPicker.dataSource = self
        self.setsPicker.selectRow(2, inComponent: 0, animated: false)
        selectedSets = Int(setsOptions[2]) ?? 3
        self.repsPicker.selectRow(9, inComponent: 0, animated: false)
        selectedReps = Int(repsOptions[9]) ?? 10
        self.weightPicker.selectRow(9, inComponent: 0, animated: false)
        selectedWeight = Int(weightOptions[9]) ?? 45
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var countrows : Int = setsOptions.count
        if pickerView == repsPicker{
            countrows = repsOptions.count
        } else if pickerView == weightPicker{
            countrows = weightOptions.count
        }
        return countrows
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == setsPicker {
            let titleRow = setsOptions[row]
            return titleRow
        } else if pickerView == repsPicker {
            let titleRow = repsOptions[row]
            return titleRow
        } else if pickerView == weightPicker {
            let titleRow = weightOptions[row]
            return titleRow
        }
        return ""
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == setsPicker {
            selectedSets = Int(self.setsOptions[row]) ?? selectedSets
        } else if pickerView == repsPicker {
            selectedReps = Int(self.repsOptions[row]) ?? selectedReps
        } else if pickerView == weightPicker {
            selectedWeight = Int(self.weightOptions[row]) ?? selectedWeight
        }
    }
    

    func loadPickers(){
        for i in stride(from: 1, through: 10, by: 1) {
            setsOptions.append(String(i))
        }
        for j in stride(from: 1, through: 20, by: 1) {
            repsOptions.append(String(j))
        }
        for k in stride(from: 0, through: 100, by: 5) {
            weightOptions.append(String(k))
        }
    }
    
    
    @IBAction func selectExercise(_ sender: Any) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "newWorkoutPage") as! NewWorkoutViewController
        let exercise = NewWorkoutViewController.Exercise(name: selectedExercise, sets: selectedSets, reps: selectedReps, weight: selectedWeight, isChecked: false)
        exerciseArr.append(exercise)
        vc.exercises = self.exerciseArr
        vc.workoutNames = self.workoutNames
        vc.workoutName = workoutName
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
