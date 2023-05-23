//
//  WeatherRepositoryProtocol.swift
//  Clima
//
//  Created by Sh Hong on 2023/05/18.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation

import RxSwift

enum WeatherRequestMethod {
    case text(_ input: String)
    case coordinate(lat: String, lon: String)
}

extension WeatherRequestMethod {
    var toParameters: [String: Any] {
        switch self {
        case .text(let text):
            return ["q": text]
        case .coordinate(let lat, let lon):
            return ["lat": lat,
                    "lon": lon]
        }
    }
}
protocol WeatherRepositoryProtocol {
    func fetch(_ requestMethod: WeatherRequestMethod) -> Observable<Weather>
}
