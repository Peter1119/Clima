//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, ViewModelBindable {
    
    var viewModel : WeatherViewModel!
    
    private var conditionImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private var temperatureLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private var cityLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private var searchTextField: UITextField = {
        let textField = UITextField()
        return textField
    }()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .yellow

        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func bindViewModel() {

    }
}

// MARK: - UITextFieldDelagate

//extension WeatherViewController: UITextFieldDelegate {
//    @IBAction func searchPressed(_ sender: UIButton) {
//        searchTextField.endEditing(true)
//        print(searchTextField.text!)
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        searchTextField.endEditing(true)
//        print(searchTextField.text!)
//        return true
//    }
//
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        if textField.text != "" {
//            return true
//        } else {
//            textField.placeholder = "Type somegthing"
//            return false
//        }
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if let city = searchTextField.text {
//            viewModel.fetchWeather(cityName: city)
//        }
//        searchTextField.text = ""
//    }
//}
//
//// MARK: - WeatherManagerDelegate
//
//extension WeatherViewController: WeatherManagerDelegate {
//    @IBAction func fetchCurrentLocationWeatherPressed(_ sender: UIButton) {
//        locationManager.requestLocation()
//    }
//
//    func didUpdateWeather(_ weather: WeatherModel) {
//    }
//
//    func didFailWithError(error: Error) {
//        print(error)
//    }
//}
//
//// MARK: - CLLocationManagerDelegate
//
extension WeatherViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
//        viewModel.fetchWeather(latitude: "\(lat)", lognitude: "\(lon)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
