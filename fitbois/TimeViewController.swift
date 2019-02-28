//
//  TimeViewController.swift
//  fitbois
//
//  Created by Krishna Chenna on 12/6/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//

import UIKit
import FirebaseDatabase

class TimeViewController: UIViewController {
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var currentTime: UILabel!
    
    var hour = Storage.hour ?? 0
    var minute = Storage.minute ?? 0
    var firebaseReference: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timePicker.datePickerMode = .time
        timePicker.locale = Locale(identifier: "en_GB")
        setTime()
        firebaseReference = Database.database().reference()
        showCurrentTime()
    }
    

    @IBAction func onTimeChanged(_ sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = DateFormatter.Style.short
        timeFormatter.dateFormat = "HH:mm"
        
        let timeFormatter2 = DateFormatter()
        timeFormatter2.timeStyle = DateFormatter.Style.short
        timeFormatter2.dateFormat = "HH:mm a"
        
        let strTime = timeFormatter.string(from: timePicker.date)
        
        if let date12 = timeFormatter.date(from: strTime) {
            timeFormatter.dateFormat = "h:mm a"
            let date22 = timeFormatter.string(from: date12)
            timeLbl.text = date22
        } else {
            self.timeLbl.text = ""
            print("scam happened")
        }
        let strTimeArr = strTime.components(separatedBy: ":")
        print(strTimeArr[0])
        hour = Int(strTimeArr[0]) ?? 0
        minute = Int(strTimeArr[1]) ?? 0
    }
    
    
    @IBAction func saveTime(_ sender: Any) {
        let phoneNum = Storage.phoneNumberInE164 ?? ""
        self.firebaseReference.child(phoneNum).child("History").child("Notification").child("Hour").setValue(Int(hour))
        self.firebaseReference.child(phoneNum).child("History").child("Notification").child("Minute").setValue(Int(minute))
        Storage.hour = Int(hour)
        Storage.minute = Int(minute)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func setTime(){
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = DateFormatter.Style.short
        timeFormatter.dateFormat = "H:mm"
        let strTime = timeFormatter.string(from: timePicker.date)
        print(strTime)
        if let date12 = timeFormatter.date(from: strTime) {
            timeFormatter.dateFormat = "h:mm a"
            let date22 = timeFormatter.string(from: date12)
            timeLbl.text = date22
        } else {
            self.timeLbl.text = ""
            print("scam happened")
        }
    }
    
    
    func showCurrentTime(){
        let phoneNum = Storage.phoneNumberInE164 ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "H:mm"
        
        firebaseReference.child(phoneNum).child("History").child("Notification").observeSingleEvent(of: .value, with:{ (snapshot) in
            var strTime = ""
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                print(snap)
                let timeStr = snap.value as? Int ?? 0
                if(snap.key == "Minute"){
                    strTime += ":"
                }
                strTime.append(contentsOf: String(timeStr))
            }
            if let date12 = dateFormatter.date(from: strTime) {
                dateFormatter.dateFormat = "h:mm a"
                let date22 = dateFormatter.string(from: date12)
                self.currentTime.text = date22
            } else {
                self.currentTime.text = ""
                print("scam happened")
            }
        })
    }
}
