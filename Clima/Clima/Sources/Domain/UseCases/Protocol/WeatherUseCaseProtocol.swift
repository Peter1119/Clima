//
//  WeatherUseCaseProtocol.swift
//  Clima
//
//  Created by Sh Hong on 2023/05/22.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RxSwift

protocol WeatherUseCaseProtocol {
    func weather(_ input: WeatherRequestMethod) -> Observable<Weather>
}
