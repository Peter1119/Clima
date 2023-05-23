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

class WeatherViewModel: ViewModelType {
    
    struct Input {
        let requestWeatherByCoordinator = PublishRelay<(String, String)>()
        let requestWeatherByText = PublishRelay<String>()
    }
    struct Output {
        let conditionImage: Driver<UIImage?>
        let temperature: Driver<String>
        let cityName: Driver<String>
    }

    var weatherUseCase: WeatherUseCaseProtocol?
    var disposeBag: DisposeBag = .init()
    private let weather = BehaviorRelay<Weather?>(value: nil)
    
    func transform(_ input: Input) -> Output {
        let conditionImage = BehaviorRelay<UIImage?>(value: nil)
        let temperature = BehaviorRelay<String>(value: String())
        let cityName = BehaviorRelay<String>(value: String())
        
        let requestWeather = Observable.merge(
            input.requestWeatherByText
                .map { WeatherRequestMethod.text($0) },
            input.requestWeatherByCoordinator
                .map { WeatherRequestMethod.coordinate(lat: $0.0, lon: $0.1) }
            )
        .withUnretained(self)
        .skip(1)
        .flatMap { viewModel, request in
            viewModel.weatherUseCase?.weather(request).asResult() ?? .empty()
        }.share()
        
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
            .map { UIImage(named: $0) }
            .bind(to: conditionImage)
            .disposed(by: disposeBag)
            
        weather
            .bind {
                print("@@@@@@@@@@@@@@@@")
                print($0)
                print("@@@@@@@@@@@@@@@@")
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            conditionImage: conditionImage.asDriver(),
            temperature: temperature.asDriver(),
            cityName: cityName.asDriver()
        )
    }
    
    let input = Input()
    lazy var output = transform(input)
}
