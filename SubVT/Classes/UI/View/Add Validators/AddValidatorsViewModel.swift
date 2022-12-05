//
//  AddValidatorsViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 21.09.2022.
//

import Combine
import Foundation
import SubVTData

class AddValidatorsViewModel: ObservableObject {
    @Published private(set) var userValidatorsFetchState: DataFetchState<String> = .idle
    @Published private(set) var userValidators: [UserValidator] = []
    @Published private(set) var networkValidatorsFetchState: DataFetchState<String> = .idle
    @Published private(set) var validators: [ValidatorSearchSummary] = []
    @Published var searchText: String = ""
    @Published var network = PreviewData.kusama
    @Published private(set) var addValidatorStatuses: [AccountId: DataFetchState<String>] = [:]
    private var searchCancellable: AnyCancellable? = nil
    
    private var appService = SubVTData.AppService()
    private var cancellables: Set<AnyCancellable> = []
    private var query = ""
    
    init() {
        self.$searchText
            .debounce(for: .seconds(0.25), scheduler: DispatchQueue.main)
            .sink {
                [weak self] searchText in
                guard let self = self else { return }
                self.searchValidators(query: searchText)
            }
            .store(in: &cancellables)
    }
    
    func fetchUserValidators(
        onSuccess: (() -> ())?,
        onError: @escaping (Error) -> ()
    ) {
        switch self.userValidatorsFetchState {
        case .loading:
            return
        case .success(_):
            onSuccess?()
            return
        default:
            break
        }
        self.userValidatorsFetchState = .loading
        self.appService.getUserValidators()
            .sink {
                [weak self] response in
                guard let self = self else { return }
                if let error = response.error {
                    self.userValidatorsFetchState = .error(error: error)
                    onError(error)
                } else {
                    self.userValidatorsFetchState = .success(result: "")
                    self.userValidators = response.value!
                    onSuccess?()
                }
            }
            .store(in: &cancellables)
    }
    
    func searchValidators(query: String) {
        guard query != self.query,
              let host = self.network.reportServiceHost,
              let port = self.network.reportServicePort else {
            return
        }
        self.searchCancellable?.cancel()
        let query = query.trimmingCharacters(in: .whitespaces)
        self.query = query
        guard !query.isEmpty else {
            self.networkValidatorsFetchState = .success(result: "")
            self.validators.removeAll()
            return
        }
        self.networkValidatorsFetchState = .loading
        let reportService = SubVTData.ReportService(host: host, port: port)
        self.searchCancellable = reportService.searchValidators(query: query)
            .sink {
                [weak self] response in
                guard let self = self else { return }
                if let error = response.error {
                    self.networkValidatorsFetchState = .error(error: error)
                } else {
                    self.networkValidatorsFetchState = .success(result: "")
                    self.validators = response.value!
                }
            }
    }
    
    func isUserValidator(address: String) -> Bool {
        return self.userValidators.contains { userValidator in
            let otherAddress = try! userValidator.validatorAccountId.toSS58Check(
                prefix: UInt16(self.network.ss58Prefix)
            )
            return otherAddress == address
        }
    }
    
    func addValidator(accountId: AccountId) {
        if let status = addValidatorStatuses[accountId], status == .loading {
            return
        }
        addValidatorStatuses[accountId] = .loading
        self.appService.createUserValidator(
            validator: NewUserValidator(
                networkId: network.id,
                validatorAccountId: accountId
            )
        ).sink {
            [weak self] response in
            guard let self = self else { return }
            self.addValidatorStatuses[accountId] = nil
            if let userValidator = response.value, response.error == nil {
                Event.validatorAdded.post(nil)
                self.userValidators.append(userValidator)
            }
        }
        .store(in: &cancellables)
    }
}
