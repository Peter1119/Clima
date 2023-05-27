//
//  CLLocationDelegateProxy.swift
//  Clima
//
//  Created by Sh Hong on 2023/05/26.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

class CLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {
    
    weak private(set) var locationManager: CLLocationManager?
    private let locationSubject = PublishSubject<CLLocation>()
    private let statusSubject = PublishSubject<CLAuthorizationStatus>()
    
    init(locationManager: ParentObject) {
        self.locationManager = locationManager
        super.init(parentObject: locationManager, delegateProxy: CLLocationManagerDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { CLLocationManagerDelegateProxy(locationManager: $0) }
    }
    
    static func currentDelegate(for object: CLLocationManager) -> CLLocationManagerDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: CLLocationManagerDelegate?, to object: CLLocationManager) {
        
        object.delegate = delegate
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationSubject.onNext(location)
        _forwardToDelegate?.locationManager(manager, didUpdateLocations: locations)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationSubject.onError(error)
        _forwardToDelegate?.locationManager(manager, didFailWithError: error)
    }
    
    func requestLocation() -> Observable<CLLocation> {
        locationManager?.requestLocation()
        return locationSubject.asObservable()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if let status = locationManager?.authorizationStatus {
            statusSubject.onNext(status)
        }
    }
    
    // Observable로 변환된 이벤트를 구독할 수 있는 Observable을 반환하는 메서드입니다.
    func observeAuthorizationStatus() -> Observable<CLAuthorizationStatus> {
        return statusSubject.asObservable()
    }
}

extension Reactive where Base: CLLocationManager {
    var delegate: CLLocationManagerDelegateProxy {
        return CLLocationManagerDelegateProxy.proxy(for: base)
    }
    
    var locationUpdates: Observable<CLLocation> {
        return delegate.requestLocation()
    }
    
    var authorizationStatus: Observable<CLAuthorizationStatus> {
        return delegate.observeAuthorizationStatus()
    }
}

