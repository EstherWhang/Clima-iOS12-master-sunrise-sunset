//
//  ChangeCityViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit


//Write the protocol declaration here:
protocol ChangeCityAndSunStuffDelegate {
    func  userEnteredANewCityName(city: String)
    func  userDecidedSunriseSunset(showOrNo: Bool)
}


class ChangeCityViewController: UIViewController {
    
    //Declare the delegate variable here:
    var delegate : ChangeCityAndSunStuffDelegate?
    
    var buttonState: Bool = false
    //This is the pre-linked IBOutlets to the text field:
    @IBOutlet weak var changeCityTextField: UITextField!
    
    @IBOutlet weak var sunriseSunsetSwitchOutlet: UISwitch!
    
    
    //the override func idea is from https://stackoverflow.com/questions/28555255/how-do-i-keep-uiswitch-state-when-changing-viewcontrollers?noredirect=1&lq=1
    override func viewDidLoad() {
        super.viewDidLoad()
        //makes sure that the switch stays what I made it (stays on, stays off)
        sunriseSunsetSwitchOutlet.isOn =  UserDefaults.standard.bool(forKey: "switchState")
    }
    
    @IBAction func sunriseSunsetSwitch(_ sender: UISwitch) {
        //user default stuff from the previous link
        UserDefaults.standard.set(sender.isOn, forKey: "switchState")
        //hides or shows the sunset labels depending on the state of the sunset switch
        delegate?.userDecidedSunriseSunset(showOrNo: sunriseSunsetSwitchOutlet.isOn)

    }
    
    
    //This is the IBAction that gets called when the user taps on the "Get Weather" button:
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        
        //1 Get the city name the user entered in the text field
        let cityName = changeCityTextField.text!
        
    
        //2 If we have a delegate set, call the method userEnteredANewCityName
        delegate?.userEnteredANewCityName(city: cityName)
        
        //3 dismiss the Change City View Controller to go back to the WeatherViewController
        self.dismiss(animated: true, completion: nil)
        
    }
    
    

    //This is the IBAction that gets called when the user taps the back button. It dismisses the ChangeCityViewController.
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
