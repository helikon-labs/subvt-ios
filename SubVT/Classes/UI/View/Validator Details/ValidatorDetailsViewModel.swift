//
//  ValidatorDetailsViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 28.07.2022.
//

import Combine
import CoreMotion
import Foundation
import SubVTData
import SwiftUI
import SceneKit

class ValidatorDetailsViewModel: ObservableObject {
    @Published private(set) var serviceStatus: RPCSubscriptionServiceStatus = .idle
    @Published private(set) var validatorDetails: ValidatorDetails? = nil
    
    private let motion = CMMotionManager()
    private let queue = OperationQueue()
    @Published private(set) var deviceRotation = SCNVector3(0.0, 0.0, 0.0)
    
    private var service: SubVTData.ValidatorDetailsService! = nil
    private var serviceStatusSubscription: AnyCancellable? = nil
    private var serviceSubscription: AnyCancellable? = nil
    private var network: Network! = nil
    private var accountId: AccountId! = nil
    private(set) var subscriptionIsInProgress = false
    
    private func initService() {
        if let rpcHost = self.network?.validatorDetailsServiceHost,
           let rpcPort = self.network?.validatorDetailsServicePort {
            self.service = SubVTData.ValidatorDetailsService(
                rpcHost: rpcHost,
                rpcPort: rpcPort
            )
        } else {
            self.service = SubVTData.ValidatorDetailsService()
        }
    }
    
    func unsubscribe() {
        self.service.unsubscribe()
        self.subscriptionIsInProgress = false
    }
    
    func onScenePhaseChange(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .background:
            break
        case .inactive:
            self.service.unsubscribe()
            self.subscriptionIsInProgress = false
        case .active:
            if !self.subscriptionIsInProgress {
                self.subscribeToValidatorDetails(network: self.network, accountId: accountId)
            }
        @unknown default:
            fatalError("Unknown scene phase: \(scenePhase)")
        }
    }
    
    func subscribeToValidatorDetails(
        network: Network,
        accountId: AccountId
    ) {
        switch self.serviceStatus {
        case .subscribed(_):
            return
        default:
            break
        }
        self.subscriptionIsInProgress = true
        self.network = network
        if self.service == nil {
            self.initService()
        }
        if self.serviceStatusSubscription == nil {
            self.serviceStatusSubscription = self.service.$status
                .receive(on: DispatchQueue.main)
                .sink {
                    [weak self]
                    (status) in
                    self?.serviceStatus = status
                }
        }
        self.serviceSubscription?.cancel()
        self.serviceSubscription = self.service
            .subscribe(parameter: accountId.toHex())
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self]
                (completion) in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    print("validator details service finished.")
                    self.subscriptionIsInProgress = false
                case .failure(let rpcError):
                    print("validator details service error: \(rpcError)")
                    self.subscriptionIsInProgress = false
                }
            } receiveValue: {
                [weak self]
                (event) in
                guard let self = self else { return }
                switch event {
                case .subscribed(_):
                    self.subscriptionIsInProgress = false
                    print("validator details subscribed")
                case .update(let update):
                    if let validatorDetails = update.validatorDetails {
                        self.validatorDetails = validatorDetails
                    } else if let update = update.validatorDetailsUpdate {
                        self.validatorDetails?.apply(diff: update)
                    }
                case .unsubscribed:
                    self.subscriptionIsInProgress = false
                    print("validator details unsubscribed")
                }
            }
    }
    
    func startDeviceMotion() {
        if self.motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 1.0 / 30.0
            self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
            
            self.motion.startDeviceMotionUpdates(
                using: .xMagneticNorthZVertical,
                to: self.queue
            ) { motion, _ in
                if let motion = motion {
                    DispatchQueue.main.async {
                        // Get the attitude relative to the magnetic north reference frame.
                        self.deviceRotation.x += Float(motion.rotationRate.x) / 80
                        self.deviceRotation.y += Float(motion.rotationRate.y) / 56
                        // ignore z rotation for the 3D model
                        self.deviceRotation.z += 0
                    }
                }
            }
        }
    }
    
    func stopDeviceMotion() {
        print("stop")
        self.queue.cancelAllOperations()
        self.motion.stopDeviceMotionUpdates()
    }
}
