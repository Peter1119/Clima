//
//  WeatherRepository.swift
//  Clima
//
//  Created by Sh Hong on 2023/05/18.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation

import RxSwift

struct WeatherRepository: WeatherRepositoryProtocol {

    var weatherDataSource: WeatherDataSourceProtocol?
    
    func fetch(_ requestMethod: WeatherRequestMethod) -> Observable<Weather> {
        return weatherDataSource?.fetch(requestMethod)
            .map { $0.toDomain() } ?? .empty()
    }
}
