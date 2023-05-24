//
//  WeatherViewModel.swift
//  Clima
//
//  Created by Sh Hong on 2021/09/03.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation


final class WeatherViewModel: NSObject, ViewModelType {
    
    struct Input {
        let viewWillAppear = PublishRelay<Void>()
        let requestCoordinatorButtonTap = PublishRelay<Void>()
        let requestWeatherByText = PublishRelay<String>()
    }
    struct Output {
        let conditionImage: Driver<UIImage>
        let temperature: Driver<String>
        let cityName: Driver<String>
        let showMoveToSettingAlert: Driver<Void>
    }
    
    var weatherUseCase: WeatherUseCaseProtocol?
    var disposeBag: DisposeBag = .init()
    private let weather = BehaviorRelay<Weather?>(value: nil)
    private let requestWeatherByCoordinator = PublishRelay<(String, String)>()
    
    private let locationManager: CLLocationManager
    private var authorizationIsDenied: Bool {
        return CLLocationManager.authorizationStatus() == .denied
    }
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        
        self.locationManager.delegate = self
    }
    
    func transform(_ input: Input) -> Output {
        let conditionImage = PublishRelay<UIImage>()
        let temperature = PublishRelay<String>()
        let cityName = PublishRelay<String>()
        
        input.viewWillAppear
            .withUnretained(self)
            .bind { viewModel, _ in
                viewModel.locationManager.requestWhenInUseAuthorization()
            }
            .disposed(by: disposeBag)
        
        Observable.merge(
            input.viewWillAppear.asObservable(),
            input.requestCoordinatorButtonTap.asObservable()
        )
        .withUnretained(self)
        .bind { viewModel, _ in
            viewModel.locationManager.requestLocation()
        }
        .disposed(by: disposeBag)
        
        let authorizationIsDenied = Observable.merge(
            input.requestWeatherByText.map { _ in () }.asObservable(),
            input.requestCoordinatorButtonTap.asObservable()
        )
            .withUnretained(self)
            .map { viewModel, _ -> Bool in
                return viewModel.authorizationIsDenied
            }
        
        let requestWeather = authorizationIsDenied
            .filter { $0 == false }
            .withLatestFrom(
                Observable.merge(
                    input.requestWeatherByText.map { WeatherRequestMethod.text($0)
                    },
                    requestWeatherByCoordinator.map {
                        WeatherRequestMethod.coordinate(lat: $0.0, lon: $0.1)
                    }
                )
            )
            .withUnretained(self)
            .flatMap { viewModel, request in
                viewModel.weatherUseCase?.weather(request).asResult() ?? .empty()
            }
            .share()
        
        requestWeather
            .compactMap { result -> Weather? in
                guard case let .success(weather) = result else { return nil }
                return weather
            }
            .bind(to: weather)
            .disposed(by: disposeBag)
        
        weather
            .compactMap(\.?.cityName)
            .bind(to: cityName)
            .disposed(by: disposeBag)
        
        weather
            .compactMap(\.?.temperature)
            .map { String(format: "%.1f", $0) }
            .bind(to: temperature)
            .disposed(by: disposeBag)
        
        weather
            .compactMap(\.?.conditionName)
            .compactMap { UIImage(systemName: $0) }
            .bind(to: conditionImage)
            .disposed(by: disposeBag)
        
        return Output(
            conditionImage: conditionImage.asDriver { _ in  .empty() },
            temperature: temperature.asDriver { _ in  .empty() },
            cityName: cityName.asDriver{ _ in  .empty() },
            showMoveToSettingAlert: authorizationIsDenied
                .filter { $0 == true }
                .map { _ in () }
                .asDriver(onErrorJustReturn: ())
        )
    }
    
    let input = Input()
    lazy var output = transform(input)
}

// MARK: - CLLocationManagerDelegate

extension WeatherViewModel : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        let latString = "\(location.coordinate.latitude)"
        let lonString = "\(location.coordinate.longitude)"
        
        requestWeatherByCoordinator.accept((latString, lonString))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
