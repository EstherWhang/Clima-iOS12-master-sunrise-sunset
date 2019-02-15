//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

//got the sunset data, now have to convert it to the proper timezone
//after that, get it to display on the screen with the switch

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import LatLongToTimezone

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityAndSunStuffDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "059eb3f99e3dba761fccb4f14da9b189"

    //TODO: Declare instance variables here
    //review previous module
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    //CHALLENGE
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    

    

    //delegate and protocols!!!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: [String: String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess{
                print("Success! Got the weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issue"
            }
            
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON){
        if let tempResult = json["main"]["temp"].double {
            print("\(json)")
         
            weatherDataModel.temperature = Int(tempResult - 273.15)

            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            
            //gets the timezone from the lat/long values of the city,
            let cityLat = json["coord"]["lat"].doubleValue
            let cityLong = json["coord"]["lon"].doubleValue
            // Get correct time zone from lat/long & put in WeatherDateModel
            weatherDataModel.timeZone = timeZoneConvertor(latitude: cityLat, longitude: cityLong)
            
             //sunrise, sunset, swiftly flow the days~~~
            let sunrise = json["sys"]["sunrise"].doubleValue
            let sunset = json["sys"]["sunset"].doubleValue
            weatherDataModel.sunrise = convertUnixtoHumanTime(timeResult: sunrise)
            weatherDataModel.sunset = convertUnixtoHumanTime(timeResult: sunset)
            
           
            
            updateUIWithWeatherData()
        }
        else {
            cityLabel.text = "Weather Unavailable"
        }
    }

   
    
    //takes lat/long and returns the timezone for that coordinate
    func timeZoneConvertor(latitude: Double, longitude: Double) -> TimeZone! {
        //got this bit of code from https://stackoverflow.com/questions/9188871/how-to-identify-timezone-from-longitude-and-latitude-in-ios
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let timeZone = TimezoneMapper.latLngToTimezone(location)
        
        return timeZone
    }

    //the sunrise/sunset times are only given in Unix, so this function converts it to human time (using the time zone found in timeZoneConvertor
    //from https://stackoverflow.com/questions/26849237/swift-convert-unix-time-to-date-and-time
    func convertUnixtoHumanTime(timeResult: Double) -> String {
        let date = Date(timeIntervalSince1970: timeResult)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        
        //timeZones
        dateFormatter.timeZone = weatherDataModel.timeZone
        
        let timeOfLocation = dateFormatter.string(from: date)
        return timeOfLocation
     }
    
 
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        sunriseLabel.text = "Sunrise: \(weatherDataModel.sunrise)"
        sunsetLabel.text = "Sunset: \(weatherDataModel.sunset)"
        
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "location unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        let params: [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    

    func userDecidedSunriseSunset(showOrNo: Bool) {
        //shows the sunrise/sunset times depending on whether the switch is on or not
        sunriseLabel.isHidden = !showOrNo
        sunsetLabel.isHidden = !showOrNo
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }
    
    
    
}
