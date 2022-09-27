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
    @Published private(set) var userValidatorsFetchState: DataFetchState<[UserValidator]> = .idle
    @Published private(set) var networkValidatorsFetchState: DataFetchState<[ValidatorSearchSummary]> = .idle
    @Published private(set) var validators: [ValidatorSearchSummary] = []
    @Published var searchText: String = ""
    @Published var network = PreviewData.kusama
    private var searchCancellable: AnyCancellable? = nil
    
    private var appService = SubVTData.AppService()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.$searchText
            .debounce(for: .seconds(0.25), scheduler: DispatchQueue.main)
            .sink { searchText in
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
                    self.userValidatorsFetchState = .success(result: response.value!)
                    onSuccess?()
                }
            }
            .store(in: &cancellables)
    }
    
    func searchValidators(query: String) {
        guard let host = self.network.reportServiceHost,
              let port = self.network.reportServicePort,
              self.networkValidatorsFetchState != .loading else {
            return
        }
        self.searchCancellable?.cancel()
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else {
            self.networkValidatorsFetchState = .success(result: [])
            self.validators.removeAll()
            return
        }
        self.networkValidatorsFetchState = .loading
        let reportService = SubVTData.ReportService(baseURL: "https://\(host):\(port)")
        self.searchCancellable = reportService.searchValidators(query: query)
            .sink {
                [weak self] response in
                guard let self = self else { return }
                if let error = response.error {
                    self.networkValidatorsFetchState = .error(error: error)
                } else {
                    self.networkValidatorsFetchState = .success(result: response.value!)
                    self.validators = response.value!
                }
            }
    }
}
