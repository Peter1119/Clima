//
//  Extension.swift
//  Clima
//
//  Created by Sh Hong on 2023/05/22.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum AlertStyle {
    case onlyConfirm
    case withCancel
}

enum ActionType {
    case confirm
    case cancel
}

extension Reactive where Base: UIViewController {
    func presentAlert(
        title : String? = nil,
        message: String? = nil,
        style: AlertStyle = .onlyConfirm) -> Observable<ActionType> {
        return Observable.create { observer in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                observer.onNext(.confirm)
                observer.onCompleted()
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .destructive) { _ in
                observer.onNext(.cancel)
                observer.onCompleted()
            }
            
            switch style {
            case .onlyConfirm:
                alertController.addAction(okAction)
            case .withCancel:
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
            }
            
            base.present(alertController, animated: true, completion: nil)
            
            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    var presentErrorAlert: Binder<String> {
        return Binder(base) { base, message in
            let alertController = UIAlertController(title: "문제가 발생했어요.", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
            
            alertController.addAction(action)
            
            base.present(alertController, animated: true, completion: nil)
        }
    }
}

extension ObservableType {
    func asResult() -> Observable<Result<Element, Error>> {
        return self.map { .success($0) }
            .catch { .just(.failure($0)) }
    }
}

public extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }
    
    var viewWillAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    var viewDidAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    var viewWillDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    var viewDidDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
}
