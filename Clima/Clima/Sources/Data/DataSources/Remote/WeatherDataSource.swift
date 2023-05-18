//
//  WeatherDataSource.swift
//  Clima
//
//  Created by Sh Hong on 2023/05/18.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation

import RxSwift
import Alamofire

struct WeatherDataSource: WeatherDataSourceProtocol {
    
    var baseURL = Network.baseURLString + "appid=\(Network.appID)"
    
    func fetch(_ requestMethod: WeatherRequestMethod) -> Observable<WeatherTotalDTO> {
            return Observable<WeatherTotalDTO>.create { observer -> Disposable in
                let task = AF.request(
                    baseURL,
                    method: .get,
                    parameters: requestMethod.toParameters
                )
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: WeatherTotalDTO.self) { (response) in
                    switch response.result {
                    case .failure(let error):
                        observer.onError(error)
                    case .success(let value):
                        observer.onNext(value)
                        observer.onCompleted()
                    }
                }
                return Disposables.create(with: {
                    task.cancel()
                })
            }
        }
}
