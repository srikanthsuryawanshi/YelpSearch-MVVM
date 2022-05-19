//
//  Reachability.swift
//  YelpSearch
//
//  Created by Srikanth SP on 31/03/22.
//

import Foundation
import Connectivity

protocol ReachabilityProtocol {
    func isNetworkConnected() -> Bool
    func observeNetworkChange(using closure: @escaping (Bool) -> Void)
}


class Reachability {
    
    static var shared: Reachability = {
        return Reachability()
    }()
    
    private var observations = [((Bool) -> Void)?]()
    let connectivity: Connectivity = Connectivity()
    
    private var isConnected = false {
        didSet(oldState) {
            if oldState != isConnected {
                notifyObservers()
            }
        }
    }
    
    private init() {
        
        let connectivityChanged: (Connectivity) -> Void = { [weak self] connectivity in
            guard let self = self else { return }
            self.updateConnectionStatus(connectivity.status)
        }
//        connectivity.connectivityURLs = [URL(string: "https://www.apple.com/library/test/success.html")!]

        connectivity.whenConnected = connectivityChanged
        connectivity.whenDisconnected = connectivityChanged
        connectivity.startNotifier()
    }
    
    
    private func updateConnectionStatus(_ status: Connectivity.Status) {
        
        switch status {
        case .connected:
            isConnected = true
        case .connectedViaCellular:
            isConnected = true
        case .connectedViaCellularWithoutInternet:
            isConnected = false
        case .connectedViaEthernet:
            isConnected = true
        case .connectedViaEthernetWithoutInternet:
            isConnected = false
        case .connectedViaWiFi:
            isConnected = true
        case .connectedViaWiFiWithoutInternet:
            isConnected = false
        case .determining:
            isConnected = false
        case .notConnected:
            isConnected = false
        }
        
    }
    
    private func notifyObservers() {
        observations.forEach { closure in
            closure?(isConnected)
        }
    }
}

extension Reachability: ReachabilityProtocol {
    func observeNetworkChange(using closure: @escaping (Bool) -> Void) {
            observations.append(closure)
        }
    
    func isNetworkConnected() -> Bool {
        return isConnected
    }

    
}
