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
    @Published private(set) var networkValidatorsFetchState: DataFetchState<[ValidatorSummary]> = .idle
    @Published private(set) var validators: [ValidatorSummary] = []
    @Published var searchText: String = ""
    @Published var network = PreviewData.kusama
    
    private var appService = SubVTData.AppService()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.$searchText
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
            .sink { searchText in
                self.filterAndSortValidators(searchText: searchText)
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
    
    func fetchNetworkValidators(
        onSuccess: (() -> ())?,
        onError: @escaping (Error) -> ()
    ) {
        guard let host = self.network.reportServiceHost,
              let port = self.network.reportServicePort,
              self.networkValidatorsFetchState != .loading else {
            return
        }
        switch self.networkValidatorsFetchState {
        case .loading:
            return
        default:
            break
        }
        self.networkValidatorsFetchState = .loading
        let reportService = SubVTData.ReportService(baseURL: "https://\(host):\(port)")
        reportService.getValidatorListReport()
            .sink {
                [weak self] response in
                guard let self = self else { return }
                if let error = response.error {
                    self.networkValidatorsFetchState = .error(error: error)
                    onError(error)
                } else {
                    self.networkValidatorsFetchState = .success(result: response.value!.validators)
                    onSuccess?()
                }
            }
            .store(in: &cancellables)
    }
    
    func filterAndSortValidators(
        searchText: String
    ) {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            self.validators.removeAll()
            return
        }
        switch self.networkValidatorsFetchState {
        case .success(let validators):
            self.validators = validators
                .filter { searchText.isEmpty || $0.filter(searchText) }
                .sorted {
                    return $0.compare(sortOption: .identity, $1)
                }
        default:
            break
        }
    }
}
