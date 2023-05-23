//
//  SceneDelegate.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        var weatherVC = WeatherViewController()
        let viewModel = WeatherViewModel()
        var useCase = WeatherUseCase()
        let repository = WeatherRepository(weatherDataSource: WeatherDataSource())
        useCase.weatherRepository = repository
        viewModel.weatherUseCase = useCase
        weatherVC.bind(viewModel: viewModel)
        window?.rootViewController = weatherVC
        window?.makeKeyAndVisible()
        
    }
}

