//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import CoreLocation

class WeatherViewController: UIViewController, ViewModelBindable {
    
    var viewModel : WeatherViewModel!
    var disposeBag: DisposeBag = .init()
    
    enum Metric {
        enum CurrentLocationButton {
            static let width = 40
            static let height = 40
        }
        
        enum SearchButton {
            static let width = 40
            static let height = 40
        }
        
        enum SearchStackView {
            static let topMargin = 10
            static let horizontalMargin = 5
        }
        
        enum WeatherImageView {
            static let width = 120
            static let height = 120
        }

        enum CenterStackView {
            static let horizontalMargin = 10
            static let topMargin = 20
        }
    }

    private let backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "background")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let currentLocationButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(
            systemName: "location.circle.fill",
            withConfiguration: largeConfig
        )
        button.setImage(
            image,
            for: .normal
        )
        button.contentMode = .scaleToFill
        button.imageView?.tintColor = .black

        return button
    }()
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "도시를 검색해보세요."
        textField.font = .systemFont(ofSize: 25)
        textField.backgroundColor = .systemFill
        textField.textAlignment = .left
        textField.returnKeyType = .go
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(
            systemName: "magnifyingglass",
            withConfiguration: largeConfig
        )
        button.setImage(
            image,
            for: .normal
        )
        button.contentMode = .scaleAspectFill
        button.imageView?.tintColor = .black
        return button
    }()
    
    private lazy var searchStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            currentLocationButton,
            searchTextField,
            searchButton
        ])
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = 10
        
        return stack
    }()

    private let conditionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "sun.max")
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100)
        label.textColor = .black
        label.text = "21"
        return label
    }()
    
    private let unitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100)
        label.textColor = .black
        label.text = "°C"
        return label
    }()
    
    private lazy var temperatureStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            temperatureLabel,
            unitLabel
        ])
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30)
        label.text = "London"
        return label
    }()
    
    private lazy var centerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            conditionImageView,
            temperatureStack,
            cityLabel
        ])
        stackView.axis = .vertical
        stackView.alignment = .trailing
        stackView.spacing = 10
        return stackView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(frame: .zero)
        activityIndicator.style = .large
        activityIndicator.tintColor = .white
        activityIndicator.backgroundColor = .black.withAlphaComponent(0.5)
        activityIndicator.isHidden = true 
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        layout()
    }
    
    func bindViewModel() {
        self.rx.viewWillAppear
            .map { _ in Void() }
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
        
        currentLocationButton.rx.tap
            .bind(to: viewModel.input.requestCoordinatorButtonTap)
            .disposed(by: disposeBag)
        
        currentLocationButton.rx.tap
            .withUnretained(self)
            .bind { weakSelf, _ in
                weakSelf.searchTextField.text = String()
                weakSelf.searchTextField.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        searchButton.rx.tap
            .do(onNext: { [weak self] _ in
                self?.searchTextField.endEditing(true)
            })
            .withLatestFrom(searchTextField.rx.text.orEmpty)
            .filter { $0.isEmpty == false }
            .bind(to: viewModel.input.requestWeatherByText)
            .disposed(by: disposeBag)
        
        viewModel.output.cityName
            .drive(cityLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.conditionImage
            .drive(conditionImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.output.temperature
            .drive(temperatureLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.showMoveToSettingAlert
            .asObservable()
            .flatMap { [weak self] _ in
                self?.rx.presentAlert(
                    title: "위치 권한 설정",
                    message: "위치 정보 접근 권한 설정을 해주세요.",
                    style: .withCancel
                ) ?? .empty()
            }
            .do(onNext: { [weak self] _ in 
                self?.activityIndicator.isHidden = true
                self?.activityIndicator.stopAnimating()
            })
            .filter { $0 == .confirm }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.showLoadingView
            .drive(onNext: { [weak self] _ in
                self?.activityIndicator.isHidden = false
                self?.activityIndicator.startAnimating()
            })
            .disposed(by: disposeBag)
        
        viewModel.output.dismissLoadingView
            .drive(onNext: { [weak self] _ in
                self?.activityIndicator.isHidden = true
                self?.activityIndicator.stopAnimating()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Layout
    private func layout() {
        self.view.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.view.addSubview(searchStackView)
        currentLocationButton.snp.makeConstraints { make in
            make.width.height.equalTo(Metric.CurrentLocationButton.width)
        }
        
        searchButton.snp.makeConstraints { make in
            make.width.height.equalTo(Metric.SearchButton.width)
        }
        
        searchStackView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(Metric.SearchStackView.topMargin)
            make.left.right.equalToSuperview()
                .inset(Metric.SearchStackView.horizontalMargin)
        }
        
        self.view.addSubview(centerStackView)
        centerStackView.snp.makeConstraints { make in
            make.top.equalTo(searchStackView.snp.bottom).offset(Metric.CenterStackView.topMargin)
            make.left.right.equalToSuperview()
                .inset(Metric.CenterStackView.horizontalMargin)
        }
        
        conditionImageView.snp.makeConstraints { make in
            make.width.height.equalTo(
                Metric.WeatherImageView.width
            )
        }
        
        self.view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

