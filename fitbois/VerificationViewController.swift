//
//  VerificationViewController2.swift
//  cryptoWallet
//
//  Created by Krishna Chenna on 10/16/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//

import UIKit
import FirebaseDatabase

class VerificationViewController: UIViewController {
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel! // label variable to display to either success or error messages after entering
    
    var e164PhoneNumber: String = ""
    var firebaseReference: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.verificationCodeTextField.keyboardType = UIKeyboardType.numberPad
        firebaseReference = Database.database().reference()
        submitButton.layer.cornerRadius = submitButton.frame.height / 2
    }
    
    
    func setErrorLabel(code: String){
        switch(code){
        case "invalid_phone_number":
            self.errorLabel.text = "Your phone number is invalid"
            break
        case "incorrect_code":
            self.errorLabel.text = "Incorrect verification code"
        case "code_expired":
            self.errorLabel.text = "Your code expired"
        default:
            self.errorLabel.text = ""
        }
        self.errorLabel.textColor = UIColor.red
    }
    
    
    @IBAction func submitCode(_ sender: Any) {
        let verificationCode = verificationCodeTextField.text ?? ""
        Api.verifyCode(phoneNumber: e164PhoneNumber, code: verificationCode) { response, error in
            let apiResponse = response ?? nil
            let apiError = error ?? nil
            Storage.authToken = response?["auth_token"] as? String
            Storage.phoneNumberInE164 = self.e164PhoneNumber
            
            if(apiResponse != nil){
                self.errorLabel.text = "Verified"
                self.errorLabel.textColor = UIColor.green
                self.firebaseReference.observeSingleEvent(of: .value, with: { (snapshot) in
                    // If the user isn't in the database, prompt for experience level
                    if !snapshot.hasChild(self.e164PhoneNumber) {
                        self.firebaseReference.child(self.e164PhoneNumber).child("History").child("Notification").child("Hour").setValue(12)
                        self.firebaseReference.child(self.e164PhoneNumber).child("History").child("Notification").child("Minute").setValue(0)
                        Storage.hour = 12
                        Storage.minute = 00
                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "experienceView") as! ExperienceLevelViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "routinePage") as! RoutineViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            } else if(apiError != nil){
                self.setErrorLabel(code: error?.code ?? "")
            }
        }
    }
}
