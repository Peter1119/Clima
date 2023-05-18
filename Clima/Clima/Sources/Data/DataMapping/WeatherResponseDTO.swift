//
//  WeatherResponseDTO.swift
//  Clima
//
//  Created by Sh Hong on 2023/05/18.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation

struct WeatherTotalDTO: Codable {
    let cityName: String
    let weather: [WeatherDTO]
    let main: MainInformationDTO
    
    enum CodingKeys: String, CodingKey {
        case cityName = "name"
        case weather, main
    }
    
    func toDomain() -> Weather {
        guard let weather = weather.first else {
            return Weather(
                conditionID: 200,
                cityName: "Seoul",
                temperature: 0.0
            )
        }
        return Weather(
            conditionID: weather.id,
            cityName: cityName,
            temperature: main.temperature
        )
    }
}

struct MainInformationDTO: Codable {
    let temperature : Double
    
    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
    }
}

struct WeatherDTO: Codable {
    let id: Int
    let currentWeather: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case id, description
        case currentWeather = "main"
    }
}
