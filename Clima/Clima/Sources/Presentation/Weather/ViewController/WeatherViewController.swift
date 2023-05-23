//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa

class WeatherViewController: UIViewController, ViewModelBindable {
    
    var viewModel : WeatherViewModel!
    var disposeBag: DisposeBag = .init()
    
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
        
        viewModel.output.cityName
            .drive(cityLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.conditionImage
            .drive(conditionImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.output.temperature
            .drive(temperatureLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

// MARK: - CLLocationManagerDelegate

extension WeatherViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        let latString = "\(location.coordinate.latitude)"
        let lonString = "\(location.coordinate.longitude)"
        
        viewModel.input.requestWeatherByCoordinator.accept((latString, lonString))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
