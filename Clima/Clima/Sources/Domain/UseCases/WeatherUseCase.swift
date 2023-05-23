//
//  WeatherUseCase.swift
//  Clima
//
//  Created by Sh Hong on 2023/05/22.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RxSwift

struct WeatherUseCase: WeatherUseCaseProtocol {
    
    var weatherRepository: WeatherRepositoryProtocol?
    private var disposeBag = DisposeBag()
    
    func weather(_ input: WeatherRequestMethod) -> Observable<Weather> {
        return weatherRepository?.fetch(input) ?? .empty()
    }
    
}
