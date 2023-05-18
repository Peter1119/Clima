//
//  WeatherDataSourceProtocol.swift
//  Clima
//
//  Created by Sh Hong on 2023/05/18.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation

import RxSwift

protocol WeatherDataSourceProtocol {
    func fetch(_ requestMethod: WeatherRequestMethod) -> Observable<WeatherTotalDTO>
}
