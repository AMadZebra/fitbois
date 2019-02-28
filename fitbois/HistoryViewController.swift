//
//  HistoryViewController.swift
//  fitbois
//
//  Created by Luc Nglankong on 11/20/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//

import UIKit
import JTAppleCalendar
import FirebaseDatabase

class HistoryViewController: UIViewController {
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    // Set containing list of future dates that the user has planned workouts on
    var futureDates = NSMutableSet()
    
    // Set containing list of past dates that the user has done workouts on
    var savedDates = NSMutableSet()
    
    // Date object of the date that the user just tapped on
    var lastSelectedDate = Date()
    
    // Contains all the user's created workouts, assigned when HistoryViewController is segued to
    var workoutNames = [String]()
    
    // The user's phone number
    let e164PhoneNumber = Storage.phoneNumberInE164 ?? ""
    
    // Gold color for UI design purposes
    let outMonthColor = UIColor(red: 0.635, green: 0.584, blue: 0, alpha: 1.0)
    
    // White color for UI design purposes
    let inMonthColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    let dateFormatter = DateFormatter()
    
    
    // Any initial calendar setup
    func setupCalendarView(){
        
        /* remove spacing restrictions so that when a cell
         is highlighted, it doesn't get cut off */
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        // Setup month and year labels
        calendarView.visibleDates{ visibleDates in
            self.handleMonthYearLabels(visibleDates: self.calendarView.visibleDates())
        }
        
        // Scroll calendar to today's date
        calendarView.scrollToDate(Date(), animateScroll: false)
        
        // refresh the calendar
        calendarView.reloadData()
        
    }
    
    
    // Handles the text color of days according to the month
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState){
        
        // get cell
        guard let validCell = view as? CollectionViewCell else{ return }
        
        // hide the planned dates and past dates highlighters
        validCell.plannedView.isHidden = true
        validCell.savedView.isHidden = true
        
        
        if cellState.isSelected{
            // set date text to white when selected
            validCell.dateLabel.textColor = self.inMonthColor
        }else{
            if cellState.dateBelongsTo == .thisMonth{
                // set date text to white if date is within the month
                validCell.dateLabel.textColor = self.inMonthColor
            }else{
                // set date text to gold if the date is outside of the month
                validCell.dateLabel.textColor = self.outMonthColor
            }
        }
    }
    
    
    // Handles whether or not to reveal cell highlighting when selecteed
    func handleCellSelected(cell: JTAppleCell?, cellState: CellState){
        
        // get cell
        guard let validCell = cell as? CollectionViewCell else{return}
        
        // If a cell gets selected, highlight it, or else remove highlighting
        if cellState.isSelected{
            // un-hide selectedView highlighter
            validCell.selectedView.isHidden = false
        }else{
            // hide selectedView highlighter
            validCell.selectedView.isHidden = true
        }
        
    }
    
    
    // Changes month and year labels to current month and year
    func handleMonthYearLabels(visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        
        // Change year label
        dateFormatter.dateFormat = "yyyy"
        yearLabel.text = dateFormatter.string(from: date)
        
        // Change month label
        dateFormatter.dateFormat = "MMMM"
        monthLabel.text = dateFormatter.string(from: date)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Prepare calendar view
        setupCalendarView()
        
        // Get past dates that have workouts saved
        scanSavedDates()
        
        // Get future dates that have workouts planned
        scanFutureDates()
        
        // Add "Schedule" button on the top right of navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleWorkout))
    }

    
    // Handles segue to ScheduleWorkoutViewController when button "Schedule" is tapped
    @objc func scheduleWorkout(){
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "schedulePage") as! ScheduleWorkoutViewController
        vc.workoutList = self.workoutNames
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    // Handle segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
        // handle segue to DateViewController
        if segue.identifier == "DateSegue"{
            let vc = segue.destination as! DateViewController
            vc.date = self.lastSelectedDate
        }
    
        // handle segue to FutureViewController
        if segue.identifier == "future"{
            let vc = segue.destination as! FutureViewController
            vc.date = self.lastSelectedDate
        }
    
    }
}


// Handle JTAppleCalendarViewDelegate required for the calendar
extension HistoryViewController: JTAppleCalendarViewDelegate {
    
    // Called when a date is selected
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        // prevent random cells from highlighting
        handleCellSelected(cell: cell, cellState: cellState)
        
        // change date text colors
        handleCellTextColor(view: cell, cellState: cellState)
        
        // save the date the user just tapped
        lastSelectedDate = date
        
        //get today's date
        let currentDate = getCurrentDate()
        
        // refresh calendar
        calendar.reloadData()
        
        // get the weekday name of the date selected as a string
        dateFormatter.dateFormat = "MM-d-yyyy"
        let dateAsString = dateFormatter.string(from: date)
        let dayOfWeekAsInt = getDayOfWeek(dateAsString) // will return an int for weekday
        let dayOfWeekAsString = getNameOfDay(weekDay: dayOfWeekAsInt) // will convert int weekday to string
        guard let weekDay = dayOfWeekAsString else{
            print("ERROR: Could not determine day of week")
            return
        }
        
        // check if selected date is one of the planned dates in the future
        let selectedDateContainsPlannedWorkout = futureDates.contains(weekDay) && date > getCurrentDate()
        
        // check if selected date is one of the user's past workout dates
        let selectedDateContainsPastWorkout = self.savedDates.contains(dateAsString)
        
        // segue to appropriate view controller
        if(selectedDateContainsPastWorkout || selectedDateContainsPlannedWorkout){
            // if selected date has a planned workout, segue to FutureViewController
            if(date > currentDate){
                performSegue(withIdentifier: "future", sender: self)
            }else{ // if selected date has a past workout, segue to DateViewController
                performSegue(withIdentifier: "DateSegue", sender: self)
            }
        // if selected date has no planned or past data, send alert to user
        }else{
            // warn the user that the selected cell has no workout data
            let alert = UIAlertController(title: "No Workout Records", message: "This date has no Workout records!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // Called when a date is deselected
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        // prevent random cells from highlighting
        handleCellSelected(cell: cell, cellState: cellState)
        
        // change date text colors
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    
    // Display the cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        // get the cell
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CollectionViewCell
        cell.dateLabel.text = cellState.text
        
        // prevent random cells from highlighting
        handleCellSelected(cell: cell, cellState: cellState)
        
        // change date text colors
        handleCellTextColor(view: cell, cellState: cellState)
        
        // Highlight today's date
        let calendar = NSCalendar.current
        if calendar.isDateInToday(date) {
            cell.todaysView.isHidden = false
        }else{
            cell.todaysView.isHidden = true
        }
        
        //Highlight previous dates with saved workout data
        dateFormatter.dateFormat = "MM-d-yyyy"
        let dateAsString = dateFormatter.string(from: date)
        if(savedDates.contains(dateAsString)){
            cell.savedView.isHidden = false
        }else{
            cell.savedView.isHidden = true
        }
        
        //Get cell's weekday name as string
        let dayOfWeekAsInt = getDayOfWeek(dateAsString)
        let dayOfWeekAsString = getNameOfDay(weekDay: dayOfWeekAsInt)
        guard let weekDay = dayOfWeekAsString else{
            print("ERROR: Could not determine day of week")
            return cell
        }
        
        //Highlight dates with planned workouts
        if(futureDates.contains(weekDay) && date > getCurrentDate()){
            cell.plannedView.isHidden = false
        }else{
            cell.plannedView.isHidden = true
        }
        
        return cell
    }
    
    
    // Called before displaying cell.  According to JTAppleCalendar documentation, this function should be nearly identical to 'cellForItemAt' delegate function
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
        //get cell
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CollectionViewCell
        cell.dateLabel.text = cellState.text
        
        // prevent random cells from highlighting
        handleCellSelected(cell: cell, cellState: cellState)
        
        // change date text colors
        handleCellTextColor(view: cell, cellState: cellState)
        
        //Highlight dates with saved workout data
        dateFormatter.dateFormat = "MM-d-yyyy"
        let dateAsString = dateFormatter.string(from: date)
        if(savedDates.contains(dateAsString)){
            cell.savedView.isHidden = false
        }else{
            cell.savedView.isHidden = true
        }
    }
    
    
    // Called when user scrolls to a new month
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        // Change month and year labels when scrolling to a new month
        handleMonthYearLabels(visibleDates: visibleDates)
        
    }
    
    
    // convert numeric representation of weekday (1-7) to name of weekday (sunday-saturday)
    func getNameOfDay(weekDay: Int?) -> String?{
        
        guard let weekDay = weekDay else{
            print("ERROR: Could not determine weekday")
            return ""
        }
        
        var nameOfDay: String?
        
        // convert to appropriate weekday
        switch weekDay {
        case 1: //Sunday
            nameOfDay = "Sunday"
        case 2: //Monday
            nameOfDay = "Monday"
        case 3: //Tuesday
            nameOfDay = "Tuesday"
        case 4: //Wednesday
            nameOfDay = "Wednesday"
        case 5: //Thursday
            nameOfDay = "Thursday"
        case 6: //Friday
            nameOfDay = "Friday"
        default: //Saturday
            nameOfDay = "Saturday"
        }
        
        return nameOfDay
    }
    
    
    // Get name of date selected ("Sat" - "Sun") but in format 1-7, 1=sunday and 7=saturday
    func getDayOfWeek(_ today:String) -> Int? {
        
        // format given date
        let formatter  = DateFormatter()
        formatter.dateFormat = "MM-d-yyyy"
        guard let todayDate = formatter.date(from: today) else {
            print("ERROR: Could not determine today's date")
            return nil
        }
        let myCalendar = Calendar(identifier: .gregorian)
        
        // get weekday from date
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        
        return weekDay
    }
    
    
    // get today's date
    func getCurrentDate() -> Date{
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let currentDateString = formatter.string(from: date)
        let currentDate = formatter.date(from: currentDateString)
        guard let today = currentDate else{
            print("ERROR: Could not obtain current date")
            return Date()
        }
        return today
    }
    
    
    // get list of dates from database that have past workout data
    func scanSavedDates(){
        
        // Firebase setup
        let firebaseReference = Database.database().reference()
        
        // Query for all dates that the user has saved workouts on
        firebaseReference.child(self.e164PhoneNumber).child("History").observeSingleEvent(of: .value, with: { (snapshot) in
            //add all dates containing workout history to set of saved dates
            var dateCounter=0
            for dates in snapshot.children { //iterate through History branch
                let datesChild = dates as! DataSnapshot
                let key = datesChild.key
                self.savedDates.add(key) //store saved date
                dateCounter = dateCounter + 1
            }
        })
    }
    
    
    // get list of dates from database that have planned workouts
    func scanFutureDates(){
        // Firebase setup
        let firebaseReference = Database.database().reference()
        
        // Query for all dates that the user has saved workouts on
        firebaseReference.child(self.e164PhoneNumber).child("History").child("Schedule").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // populate set of week days that the user has planned workouts for ("Sunday"-"Saturday")
            for weekDays in snapshot.children {
                let weekDaysChild = weekDays as! DataSnapshot
                let key = weekDaysChild.key
                
                guard let dict = snapshot.value as? [String: Any] else{
                    print("ERROR: cannot read dict from database")
                    return
                }
                
                // save weekday name that contains future data
                let value = (dict[key] as! String)
                
                // if current weekday contains workout data, save weekday
                if(value != "No Workout"){
                    self.futureDates.add(key)
                }
            }
        })
    }
}


// handle required JTAppleCalendarViewDataSource functions
extension HistoryViewController: JTAppleCalendarViewDataSource{
    // configures the calendar
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters  {
        dateFormatter.dateFormat = "yyyy MM dd"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        let startDate = dateFormatter.date(from: "2018 01 01")!
        let endDate = dateFormatter.date(from: "2030 12 31")!
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
}
