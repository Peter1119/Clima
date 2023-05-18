//
//  Protocol.swift
//  Clima
//
//  Created by Sh Hong on 2021/09/11.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    var input: Input { get }
    var output: Output { get }
}

protocol ViewModelBindable {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get set }
    
    func bindViewModel()
}

extension ViewModelBindable where Self: UIViewController {
    mutating func bind(viewModel: ViewModelType) {
        self.viewModel = viewModel
        loadViewIfNeeded()
        bindViewModel()
    }
}

protocol FetchAble {
    associatedtype ClassType
    associatedtype CustomeError: Error
    func fetchNow(onCompleted: @escaping (Result<ClassType, CustomeError>) -> Void)
    
    func fetchWeather(cityName: String)
    
    func fetchWeather(latitude: String, lognitude: String)
}
