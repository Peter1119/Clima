//
//  ClimaTests.swift
//  ClimaTests
//
//  Created by Sh Hong on 2023/05/18.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import XCTest
import RxSwift

@testable import Clima

final class ClimaTests: XCTestCase {
    
    var weatherDataSource: WeatherDataSourceProtocol?
    var weatherRepository: WeatherRepositoryProtocol?
    var disposeBag = DisposeBag()
    
    override func setUpWithError() throws {
        weatherDataSource = WeatherDataSource()
        weatherRepository = WeatherRepository(weatherDataSource: weatherDataSource)
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        
        weatherDataSource = nil
        weatherRepository = nil
    }
    
    func test_위치값이_london일_경우_london으로_나온다_DataSource() throws {
        // given
        let promise = expectation(description: "It makes correct value") // expectation
        
        // when
        weatherDataSource?.fetch(.text("london"))
            .map(\.cityName.localizedLowercase)
            .subscribe(onNext: { result in
                print(result)
                // then
                XCTAssertEqual(result, "london")
                promise.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [promise], timeout: 10)
    }
    
    func test_위치값이_london일_경우_london으로_나온다_repository() throws {
        // given
        let promise = expectation(description: "It makes correct value") // expectation
        
        // when
        weatherRepository?.fetch(.text("london"))
            .map(\.cityName.localizedLowercase)
            .subscribe(onNext: { result in
                print(result)
                // then
                XCTAssertEqual(result, "london")
                promise.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [promise], timeout: 10)
    }
    
    func test_lon_lat값이_서울일_경우_seoul로_나온다_DataSource() throws {
        // given
        let promise = expectation(description: "It makes correct value") // expectation
        
        // when
        weatherDataSource?.fetch(.coordinate(lat: "37.5683", lon: "126.9778"))
            .map(\.cityName.localizedLowercase)
            .subscribe(onNext: { result in
                print(result)
                // then
                XCTAssertEqual(result, "seoul")
                promise.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [promise], timeout: 10)
    }
    
    func test_lon_lat값이_서울일_경우_seoul로_나온다_repository() throws {
        // given
        let promise = expectation(description: "It makes correct value") // expectation
        
        // when
        weatherRepository?.fetch(.coordinate(lat: "37.5683", lon: "126.9778"))
            .map(\.cityName.localizedLowercase)
            .subscribe(onNext: { result in
                print(result)
                // then
                XCTAssertEqual(result, "seoul")
                promise.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [promise], timeout: 10)
    }
}
