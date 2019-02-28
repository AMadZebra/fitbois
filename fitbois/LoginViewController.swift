
//
//  LoginViewController.swift
//  cryptoWallet
//
//  Created by Krishna Chenna on 10/6/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//

import UIKit
import libPhoneNumber_iOS

class LoginViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    var selectedRegion: String = "US"
    var pickerData: [String] = [String]()
    var phoneNumberFormatter: NBAsYouTypeFormatter = NBAsYouTypeFormatter(regionCode: "US")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.locationPicker.delegate = self
        self.locationPicker.dataSource = self
        self.phoneNumberTextField.keyboardType = UIKeyboardType.numberPad
        phoneNumberTextField.delegate = self
        pickerData = ["US", "IN", "UK"]
        let phoneUtil = NBPhoneNumberUtil()
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        
        if(Storage.authToken != nil){
            var number:String = Storage.phoneNumberInE164 ?? ""
            
            number.removeFirst(2)
            print(number)
            do {
                let phoneNumber: NBPhoneNumber = try phoneUtil.parse(number, defaultRegion: selectedRegion)
                let formattedNumber: String = try phoneUtil.format(phoneNumber, numberFormat: .NATIONAL)
                phoneNumberTextField.text = formattedNumber
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "routinePage") as! RoutineViewController
                self.navigationController?.pushViewController(vc, animated: true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    //Textfield Function that formats the phone number appropriately
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length == 0 {
            phoneNumberTextField.text = phoneNumberFormatter.inputDigit(string)
        } else {
            phoneNumberTextField.text = phoneNumberFormatter.removeLastDigit()
        }
        return false
    }
    
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        phoneNumberFormatter = NBAsYouTypeFormatter(regionCode: selectedRegion)
        return true
    }
    
    
    // Components for the picker storing the countries
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // Initializes picker to have one item
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    // Sets number of values that will be in the picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
    // Sets name of each element in the picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    
    // Sets selected region to option in locationicker
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedRegion = pickerData[pickerView.selectedRow(inComponent: 0)]
        let phoneUtil = NBPhoneNumberUtil()
        let countryCode: String? =  phoneUtil.getCountryCode(forRegion: selectedRegion)?.stringValue ?? "1"
        
        if let code = countryCode {
            countryCodeLabel.text = "+" + code
        } else {
            print("error")
        }
    }
    
    
    func isValid(phoneNum: String) -> Bool{
        let phoneUtil = NBPhoneNumberUtil()
        
        // Check if the number entered is blank
        if(phoneNum == ""){
            print("scam")
            setErrorMessageLabel(errorNumber: 2)
            return false
        } else {
            setErrorMessageLabel(errorNumber: 0)
        }
        do {
            // Checks if the phone number is valid
            let phoneNumber: NBPhoneNumber = try phoneUtil.parse(phoneNum, defaultRegion: selectedRegion)
            let validity: Bool = phoneUtil.isValidNumber(phoneNumber)
            if(!validity){
                setErrorMessageLabel(errorNumber: 1)
                return false
            }
        } catch let error as NSError {
                print(error.localizedDescription)
        }
        return true
    }
    
    
    func setErrorMessageLabel(errorNumber: Int){
        switch errorNumber {
        case 1:
            errorLabel.text="*Please Enter Valid Phone Number"
        case 2:
            errorLabel.text="*Please Enter a Value"
        default:
            errorLabel.text = ""
        }
        errorLabel.textColor = UIColor.red
    }

    
    @IBAction func userPressedHelp(_ sender: Any) {
        let alert = UIAlertController(title: "Help", message: "Please Enter your Phone Number to Login!", preferredStyle: .alert)
        let dismissAlertAction = UIAlertAction(title: "Got It!", style: .default, handler: { (action) in alert.dismiss(animated: true, completion: nil)})
        
        alert.addAction(dismissAlertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "verificationPage"){
            let secondViewController = segue.destination as! VerificationViewController
            let duration = sender as! String
            secondViewController.e164PhoneNumber = duration
        }
    }
    
    
    @IBAction func userPressedLoginButton(_ sender: Any) {
        let phoneUtil = NBPhoneNumberUtil()
        let fullPhoneNumber: String = phoneNumberTextField.text ?? ""
        
        if(isValid(phoneNum: fullPhoneNumber)){
            do{
                let phoneNumber: NBPhoneNumber = try phoneUtil.parse(fullPhoneNumber, defaultRegion: selectedRegion)
                let formattedString: String = try phoneUtil.format(phoneNumber, numberFormat: .E164)
                
                if(Storage.authToken != nil && Storage.phoneNumberInE164 == formattedString){
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "routinePage") as! RoutineViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    // Send Verification Code
                    Api.sendVerificationCode(phoneNumber: formattedString) { response, error in
                        // Handle the response and error here
                        // segue is performed to transition to verification page
                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "verificationPage") as! VerificationViewController
                        vc.e164PhoneNumber = formattedString
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
