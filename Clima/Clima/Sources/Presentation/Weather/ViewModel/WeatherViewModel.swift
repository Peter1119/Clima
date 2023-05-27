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
        let showLoadingView: Driver<Void>
        let dismissLoadingView: Driver<Void>
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
    }
    
    func transform(_ input: Input) -> Output {
        let conditionImage = PublishRelay<UIImage>()
        let temperature = PublishRelay<String>()
        let cityName = PublishRelay<String>()
        let showMoveToSettingAlert = PublishRelay<Void>()
        let showLoadingView = PublishRelay<Void>()
        let dismissLoadingView = PublishRelay<Void>()
        
        input.viewWillAppear
            .withUnretained(self)
            .bind { viewModel, _ in
                viewModel.locationManager.requestWhenInUseAuthorization()
            }
            .disposed(by: disposeBag)
    
        let requestWeatherViewWillAppear = input.viewWillAppear
            .withUnretained(self)
            .flatMap { viewModel, _ -> Observable<CLLocation> in
                viewModel.locationManager.rx.locationUpdates
            }
            .map(WeatherRequestMethod.coordinate)
            .withUnretained(self)
            .flatMap { viewModel, request in
                viewModel.weatherUseCase?.weather(request).asResult() ?? .empty()
            }
            .share()
        
        let requestWeatherByCurrentLocation = input.requestCoordinatorButtonTap
            .withUnretained(self)
            .flatMap { viewModel, _ -> Observable<CLLocation> in
                viewModel.locationManager.rx.locationUpdates
            }
            .map(WeatherRequestMethod.coordinate)
            .withUnretained(self)
            .flatMap { viewModel, request in
                viewModel.weatherUseCase?.weather(request).asResult() ?? .empty()
            }
            .share()
        
        Observable.merge(
            requestWeatherViewWillAppear,
            requestWeatherByCurrentLocation
        )
            .compactMap { result -> Weather? in
                guard case let .success(weather) = result else { return nil }
                return weather
            }
            .bind(to: weather)
            .disposed(by: disposeBag)
        
        input.requestWeatherByText
            .map { location in
                WeatherRequestMethod.text(location)
            }
            .withUnretained(self)
            .flatMap { viewModel, request in
                viewModel.weatherUseCase?.weather(request).asResult() ?? .empty()
            }
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
        
        // LoadingView
//        let showLoadingView = Observable.merge(
//            input.viewWillAppear.asObservable(),
//            input.requestCoordinatorButtonTap.asObservable(),
//            input.requestWeatherByText.map { _ in () }.asObservable()
//        )
//
//        let dismissLoadingView = Observable.merge(
//            viewWillAppearSuccess,
//            requestWeatherSuccess
//        ).map { _ in () }
        
        return Output(
            conditionImage: conditionImage.asDriver { _ in  .empty() },
            temperature: temperature.asDriver { _ in  .empty() },
            cityName: cityName.asDriver{ _ in  .empty() },
            showMoveToSettingAlert: showMoveToSettingAlert.asDriver(onErrorJustReturn: ()),
            showLoadingView: showLoadingView.asDriver(onErrorJustReturn: ()),
            dismissLoadingView: dismissLoadingView.asDriver(onErrorJustReturn: ())
        )
    }
    
    let input = Input()
    lazy var output = transform(input)
}
