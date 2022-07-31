//
//  ValidatorListViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 18.07.2022.
//

import Combine
import SubVTData
import SwiftUI

class ValidatorListViewModel: ObservableObject {
    enum SortOption: String {
        case identity
        case stakeDescending
        case nominationDescending
    }
    
    enum FilterOption: String {
        case hasIdentity
        case isOneKV
    }
    
    @Published private(set) var serviceStatus: RPCSubscriptionServiceStatus = .idle
    @Published private(set) var validators: [ValidatorSummary] = []
    @Published var sortOption: SortOption? = nil
    @Published var filterOptions = Set<FilterOption>()
    @Published var searchText: String = ""
    @Published var isLoading = false
    
    private var mode: ValidatorListView.Mode = .active
    private var serviceStatusSubscription: AnyCancellable? = nil
    private var serviceSubscription: AnyCancellable? = nil
    private(set) var subscriptionIsInProgress = false
    private var service: SubVTData.ValidatorListService! = nil
    private var network: Network! = nil
    private var innerValidators: [ValidatorSummary] = []
    private var cancellables = Set<AnyCancellable>()
    private let lock = NSLock()
    
    init() {
        Publishers.CombineLatest3(
            self.$searchText,
            self.$filterOptions,
            self.$sortOption
        )
        .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
        .sink(receiveValue: { (searchText, filterOptions, sortOption) in
            self.filterAndSortValidators(
                searchText: searchText,
                filterOptions: filterOptions,
                sortOption: sortOption
            )
        })
        .store(in: &cancellables)
    }
    
    private func initService() {
        if let rpcHost = (self.mode == .active)
            ? self.network?.activeValidatorListServiceHost
            : self.network?.inactiveValidatorListServiceHost,
           let rpcPort = (self.mode == .active)
            ? self.network?.activeValidatorListServicePort
            : self.network?.inactiveValidatorListServicePort {
            self.service = SubVTData.ValidatorListService(
                rpcHost: rpcHost,
                rpcPort: rpcPort
            )
        } else {
            self.service = SubVTData.ValidatorListService(active: self.mode == .active)
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
                self.subscribeToValidatorList(network: self.network, mode: self.mode)
            }
        @unknown default:
            fatalError("Unknown scene phase: \(scenePhase)")
        }
    }
    
    func subscribeToValidatorList(
        network: Network,
        mode: ValidatorListView.Mode
    ) {
        switch self.serviceStatus {
        case .subscribed(_):
            return
        default:
            break
        }
        self.mode = mode
        self.subscriptionIsInProgress = true
        self.isLoading = true
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
            .subscribe()
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self]
                (completion) in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    print("validator list service finished.")
                    self.subscriptionIsInProgress = false
                    self.isLoading = false
                case .failure(let rpcError):
                    print("validator list service error: \(rpcError)")
                    self.subscriptionIsInProgress = false
                    self.isLoading = false
                }
            } receiveValue: {
                [weak self]
                (event) in
                guard let self = self else { return }
                switch event {
                case .subscribed(_):
                    self.subscriptionIsInProgress = false
                    print("validator list subscribed")
                case .update(let update):
                    self.isLoading = false
                    print("validator list update block #\(update.finalizedBlockNumber ?? 0)")
                    print("insert \(update.insert.count) validators")
                    print("update \(update.update.count) validators")
                    print("remove \(update.removeIds.count) validators")
                    self.lock.lock()
                    for validator in update.insert {
                        let index = self.innerValidators.firstIndex { existingValidator in
                            validator.accountId == existingValidator.accountId
                        }
                        if index == nil {
                            self.innerValidators.append(validator)
                        }
                    }
                    for removeAccountIdHex in update.removeIds {
                        let accountId = AccountId(hex: removeAccountIdHex)
                        self.innerValidators.removeAll { validator in
                            validator.accountId == accountId
                        }
                    }
                    for validatorDiff in update.update {
                        let index = self.innerValidators.firstIndex { validator in
                            validator.accountId == validatorDiff.accountId
                        }
                        if let index = index {
                            self.innerValidators[index].apply(diff: validatorDiff)
                        }
                    }
                    self.lock.unlock()
                    self.filterAndSortValidators(
                        searchText: self.searchText,
                        filterOptions: self.filterOptions,
                        sortOption: self.sortOption
                    )
                case .unsubscribed:
                    self.subscriptionIsInProgress = false
                    self.isLoading = false
                    print("validator list unsubscribed")
                }
            }
    }
    
    func filterAndSortValidators(
        searchText: String,
        filterOptions: Set<FilterOption>,
        sortOption: SortOption?
    ) {
        self.lock.lock()
        self.validators = self.innerValidators
            .filter { searchText.isEmpty || $0.filter(searchText) }
            .filter { !filterOptions.contains(.hasIdentity) || $0.hasIdentity() }
            .filter { !filterOptions.contains(.isOneKV) || $0.isEnrolledIn1Kv }
            .sorted {
                guard let sortOption = sortOption else {
                    return true
                }
                return $0.compare(sortOption: sortOption, $1)
            }
        self.lock.unlock()
    }
}
