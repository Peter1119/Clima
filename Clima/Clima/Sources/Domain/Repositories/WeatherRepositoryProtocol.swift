//
//  WeatherRepositoryProtocol.swift
//  Clima
//
//  Created by Sh Hong on 2023/05/18.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

enum WeatherRequestMethod {
    case text(_ input: String)
    case coordinate(_ location: CLLocation)
}

extension WeatherRequestMethod {
    var toParameters: [String: Any] {
        switch self {
        case .text(let text):
            return ["q": text]
        case .coordinate(let location):
            return ["lat": "\(location.coordinate.latitude)",
                    "lon": "\(location.coordinate.longitude)"]
        }
    }
}

protocol WeatherRepositoryProtocol {
    func fetch(_ requestMethod: WeatherRequestMethod) -> Observable<Weather>
}
