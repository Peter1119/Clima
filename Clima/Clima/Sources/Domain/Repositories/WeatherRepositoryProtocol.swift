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
    // fetch는 여러 번 호출하기 때문에 single보다는 Observable이 더 맞는거 아닌가 ?
    func fetch(_ requestMethod: WeatherRequestMethod) -> Observable<Weather>
}
