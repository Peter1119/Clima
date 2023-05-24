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
import SnapKit

class WeatherViewController: UIViewController, ViewModelBindable {
    
    var viewModel : WeatherViewModel!
    var disposeBag: DisposeBag = .init()
    
    enum Metric {
        enum CurrentLocationButton {
            static let width = 40
            static let height = 40
        }
        
        enum SearchButton {
            static let width = 40
            static let height = 40
        }
        
        enum SearchStackView {
            static let horizontalMargin = 5
        }
        
        enum WeatherImageView {
            static let width = 120
            static let height = 120
        }

        enum CenterStackView {
            static let horizontalMargin = 10
            static let topMargin = 10
        }
    }

    private let backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "background")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let currentLocationButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(
            systemName: "location.circle.fill",
            withConfiguration: largeConfig
        )
        button.setImage(
            image,
            for: .normal
        )
        button.contentMode = .scaleToFill
        button.imageView?.tintColor = .black

        return button
    }()
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "도시를 검색해보세요."
        textField.font = .systemFont(ofSize: 25)
        textField.backgroundColor = .systemFill
        textField.textAlignment = .left
        textField.returnKeyType = .go
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(
            systemName: "magnifyingglass",
            withConfiguration: largeConfig
        )
        button.setImage(
            image,
            for: .normal
        )
        button.contentMode = .scaleAspectFill
        button.imageView?.tintColor = .black
        return button
    }()
    
    private lazy var searchStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            currentLocationButton,
            searchTextField,
            searchButton
        ])
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = 10
        
        return stack
    }()

    private let conditionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "sun.max")
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100)
        label.textColor = .black
        label.text = "21"
        return label
    }()
    
    private let unitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100)
        label.textColor = .black
        label.text = "°C"
        return label
    }()
    
    private lazy var temperatureStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            temperatureLabel,
            unitLabel
        ])
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30)
        label.text = "London"
        return label
    }()
    
    private lazy var centerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            conditionImageView,
            temperatureStack,
            cityLabel
        ])
        stackView.axis = .vertical
        stackView.alignment = .trailing
        stackView.spacing = 10
        return stackView
    }()
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        layout()
    }
    
    func bindViewModel() {
        
//        viewModel.output.cityName
//            .drive(cityLabel.rx.text)
//            .disposed(by: disposeBag)
//
//        viewModel.output.conditionImage
//            .drive(conditionImageView.rx.image)
//            .disposed(by: disposeBag)
//
//        viewModel.output.temperature
//            .drive(temperatureLabel.rx.text)
//            .disposed(by: disposeBag)
    }
    
    // MARK: - Layout
    private func layout() {
        self.view.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.view.addSubview(searchStackView)
        currentLocationButton.snp.makeConstraints { make in
            make.width.height.equalTo(Metric.CurrentLocationButton.width)
        }
        
        searchButton.snp.makeConstraints { make in
            make.width.height.equalTo(Metric.SearchButton.width)
        }
        
        searchStackView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
                .inset(Metric.SearchStackView.horizontalMargin)
        }
        
        self.view.addSubview(centerStackView)
        centerStackView.snp.makeConstraints { make in
            make.top.equalTo(searchStackView.snp.bottom).offset(Metric.CenterStackView.topMargin)
            make.left.right.equalToSuperview()
                .inset(Metric.CenterStackView.horizontalMargin)
        }
        
        conditionImageView.snp.makeConstraints { make in
            make.width.height.equalTo(
                Metric.WeatherImageView.width
            )
        }
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
