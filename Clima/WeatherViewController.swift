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
    var stateOfTheSun = true
    

    //delegate and protocols!!!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        //SunriseSunsetLabel view
        
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
                //print(weatherJSON)
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
            
            
            //TIMEZONE
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

   
    func timeZoneConvertor(latitude: Double, longitude: Double) -> TimeZone! {
        //https://stackoverflow.com/questions/9188871/how-to-identify-timezone-from-longitude-and-latitude-in-ios
        //let location = CLLocation(latitude: weatherDataModel.cityLat, longitude: weatherDataModel.cityLat)
        //let geoCoder = CLGeocoder()
    
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let timeZone = TimezoneMapper.latLngToTimezone(location)
        print("iadsfasdfs:\(timeZone!)")
        return timeZone


    }

    func convertUnixtoHumanTime(timeResult: Double) -> String {
        let date = Date(timeIntervalSince1970: timeResult)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        
        //timeZones
        dateFormatter.timeZone = weatherDataModel.timeZone
        
        let timeOfLocation = dateFormatter.string(from: date)
        return timeOfLocation
     }
     //https://stackoverflow.com/questions/26849237/swift-convert-unix-time-to-date-and-time
    //https://stackoverflow.com/questions/47494222/getting-the-city-country-list-in-ios-time-zone
    
 
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        print("updateUI \(weatherDataModel.timeZone)")
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        sunriseLabel.text = "Sunrise: \(weatherDataModel.sunrise)"
        sunsetLabel.text = "Sunset: \(weatherDataModel.sunset)"
        print("Sunrise: \(weatherDataModel.sunrise) and Sunset: \(weatherDataModel.sunset)")
        
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
            //print("Latitutude: \(latitude) and Longitude: \(longitude)")
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
        if showOrNo {
            //how to refresh
            sunriseLabel.isHidden = false
            sunsetLabel.isHidden = false
        }
        else {
            sunriseLabel.isHidden = true
            sunsetLabel.isHidden = true
        }
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }
    
    
    
}


/*
 let thisTakesUpTooMuchTimeButDoYouHaveABetterIdea = TimeZone.knownTimeZoneIdentifiers
 for identifier in thisTakesUpTooMuchTimeButDoYouHaveABetterIdea {
 if identifier.split(separator: "/").last! == cityName {
 return TimeZone(identifier: identifier)!
 
 }
 }
 
 print("Oops you screwed up time zones") //THIS PRINTS WITH CITIES THAT AREN'T IN THAT FREAKING ARRAY
 return TimeZone.current
 
 
 //from the internet: https://stackoverflow.com/questions/30003280/swift-get-value-using-async-method
 func getPlaceFromCoordinate(location: CLLocation, completionHandler: @escaping (CLPlacemark?, NSError?) -> ()) {
 CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
 if error != nil {
 print("Reverse geocoding error: \(String(describing: error))")
 } else if placemarks?.count == 0 {
 print("no placemarks")
 }
 
 completionHandler(placemarks?.first as? CLPlacemark, error as? NSError)
 }
 }
 */

/*
 var tempTimeZone = TimeZone(identifier: "America/Chicago")
 geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
 if let placemark = placemarks?[0] {
 // Update timezone
 print("instead of this:\(placemark.timeZone)")
 tempTimeZone = placemark.timeZone
 }
 }
 print("iadsfasdfs:\(tempTimeZone!)")
 
 return tempTimeZone
 */
