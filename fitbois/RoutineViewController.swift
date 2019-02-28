//
//  RoutineViewController.swift
//  fitbois
//
//  Created by Krishna Chenna on 11/13/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//
//  This View Controller is the home page of the application. This page shows all the routines saved by the user and they can be accessible by the user to start a workout. They will also be able to add new workout routines, edit current routines, delete current routines, logout of their account as well as traverse to the calendar view. Accessing the saved Workout routines is the basis of the application, which is why it acts as the home page of this application.
//  There is also an added functionality of the user receiveing a notification when near a gymnasium so that they may be prompted to start a workout.

import UIKit
import FirebaseDatabase
import CoreLocation
import UserNotifications

class RoutineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet weak var routineTable: UITableView!
    @IBOutlet weak var bufferingLogo: UIActivityIndicatorView!
    
    var routines = [NewWorkoutViewController.Routine]()
    var workoutNames = [String]()
    var firebaseReference: DatabaseReference!
    let locationManager = CLLocationManager()
    var scheduledWorkout: String = ""
    let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutUser(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Calendar", style: .plain, target: self, action: #selector(loadCalendar(_:)))
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {didAllow, error in })
        
        self.notifyUserIfNearGym()
        self.navigationItem.hidesBackButton = true
        firebaseReference = Database.database().reference()
        
        concurrentQueue.sync {
            displayScheduledWorkout()
            getWorkoutNames()
            getNotificationTime()
        }
        
        routineTable.delegate = self
        routineTable.dataSource = self
        routineTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    
    @IBAction func loadCalendar(_: Any){
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "calendarPage") as! HistoryViewController
        vc.workoutNames = self.workoutNames
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    
    func notifyUserIfNearGym(){
        let center = CLLocationCoordinate2D(latitude: 38.5449, longitude: 121.7405)
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            // Make sure region monitoring is supported.
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                // Register the region.
                let maxDistance = locationManager.maximumRegionMonitoringDistance
                print(maxDistance)
                if(maxDistance >= 5000.0){
                    showNotification()
                }
                let region = CLCircularRegion(center: center,
                                              radius: 5000.0, identifier: "YourRegionID")
                region.notifyOnEntry = true
                region.notifyOnExit = false
                locationManager.startMonitoring(for: region)
            }
        }
    }
    
    
    @IBAction func userPressedAddNewWorkout(_ sender: Any) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "newWorkoutPage") as! NewWorkoutViewController
        vc.workoutNames = self.workoutNames
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func notifyScheduledWorkout(workoutName: String){
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge], completionHandler: {userDidAllow, error in })
        let notificationBody = "The workout you have scheduled for today: \n" + workoutName
        var notificationTime = DateComponents()
        
        notificationTime.hour = Storage.hour
        notificationTime.minute = Storage.minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationTime, repeats: true)
        
        let notification = UNMutableNotificationContent()
        notification.title = "You have a workout scheduled today!"
        notification.body = notificationBody
        
        let request = UNNotificationRequest(
            identifier: "timerDone", content: notification, trigger: trigger
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
    func getNotificationTime(){
        firebaseReference.child(Storage.phoneNumberInE164!).child("History").child("Notification").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if(snap.key == "Hour"){
                    Storage.hour = (snap.value as! Int)
                } else if(snap.key == "Minute"){
                    Storage.minute = (snap.value as! Int)
                }
            }
        })
    }
    
    
    func showNotification(){
        let content = UNMutableNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
        
        content.title = "Would you like to start a Workout?"
        content.body = "Start any Workout now that you're at the gym!"
        content.badge = 1
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
    // Set number of rows in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutNames.count
    }
    
    
    // Populate tableView with routines
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = workoutNames[indexPath.row]
        return cell
    }
    
    
    // Send user to start workout page when they select a workout
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "startWorkoutPage") as! StartWorkoutViewController
        vc.workoutName = self.workoutNames[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // Function to edit and remove workout routine from list of routines
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let e164PhoneNumber = Storage.phoneNumberInE164 ?? ""
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            self.firebaseReference.child(e164PhoneNumber).child("Workouts").child(self.workoutNames[indexPath.row]).removeValue()
            self.workoutNames.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        delete.backgroundColor = .red
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "newWorkoutPage") as! NewWorkoutViewController
            vc.workoutName = self.workoutNames[indexPath.row]
            vc.type = "Edit"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        edit.backgroundColor = .blue
        return [delete, edit]
    }
    
    
    // Allows all rows to be edittable
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    // Gets list of workouts from the Firebase Database to list out on table
    func getWorkoutNames(){
        let e164PhoneNumber = Storage.phoneNumberInE164 ?? ""
        bufferingLogo.startAnimating()
        firebaseReference.child(e164PhoneNumber).child("Workouts").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                self.workoutNames.append(key)
                self.routineTable.reloadData()
            }
            self.bufferingLogo.stopAnimating()
        })
    }
    
    
    func displayScheduledWorkout(){
        let weekDay:String = getWeekDay()
        let e164PhoneNumber = Storage.phoneNumberInE164 ?? ""
        var scheduledWorkout: String = ""
        firebaseReference.child(e164PhoneNumber).child("History").child("Schedule").child(weekDay).observeSingleEvent(of: .value, with:{ (snapshot) in
            guard let workout = snapshot.value else {
                print("Scammmm")
                return
            }
            scheduledWorkout = workout as? String ?? "Nil"
            print("Scheduled Workout: " + scheduledWorkout)
            if(scheduledWorkout != "No Workout" && scheduledWorkout != "Nil"){
                self.notifyScheduledWorkout(workoutName: scheduledWorkout)
            }
        })
    }
    
    
    // Return name of current day
    func getWeekDay() -> String{
        let currentTime = Date()
        let todayIndex = Calendar.current.component(.weekday, from: currentTime)
        var indexToDayMap = [1: "Sunday", 2: "Monday", 3: "Tuesday", 4: "Wednesday", 5: "Thursday", 6: "Friday", 7: "Saturday"]
        return indexToDayMap[todayIndex]!
    }
    
    
    //Called when a notification is delivered to a foreground app.
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        completionHandler([.sound, .alert, .badge])
    }
    
    
    //Called to let your app know which action was selected by the user for a given notification.
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        completionHandler()
    }
    
    
    // Function to log the user out of their account and send them to the login screen
    @IBAction func logoutUser(_ sender: Any) {
        let alert = UIAlertController(title: "Logging Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
        
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (_) in
             self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
