//
//  Protocol.swift
//  Clima
//
//  Created by Sh Hong on 2021/09/11.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    var disposeBag: DisposeBag { get set }
    func transform(_ input: Input) -> Output
}

protocol ViewModelBindable {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get set }
    var disposeBag: DisposeBag { get set }
    
    func bindViewModel()
}

extension ViewModelBindable where Self: UIViewController {
    mutating func bind(viewModel: ViewModelType) {
        self.viewModel = viewModel
        loadViewIfNeeded()
        bindViewModel()
    }
}
