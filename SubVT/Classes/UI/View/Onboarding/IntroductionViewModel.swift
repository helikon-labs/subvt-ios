//
//  IntroductionViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 11.07.2022.
//

import Combine
import SubVTData
import SwiftUI

class IntroductionViewModel: ObservableObject {
    @Published var fetchState: DataFetchState<User> = .idle
    private let service = AppService()
    private var cancellables: Set<AnyCancellable> = []
    private var fetchTimer: Timer? = nil
    private var result: Either<User, APIError>? = nil
    
    func createUser(
        onSuccess: @escaping (User) -> (),
        onError: @escaping (APIError) -> ()
    ) {
        self.fetchState = .loading
        self.result = nil
        self.fetchTimer = Timer.scheduledTimer(
            withTimeInterval: 0.75,
            repeats: false
        ) {
            [weak self] _ in
            guard let self = self else { return }
            if let result = self.result {
                switch result {
                case .left(let user):
                    self.fetchState = .success(result: user)
                    onSuccess(user)
                case .right(let error):
                    self.fetchState = .error(error: error)
                    onError(error)
                }
            }
        }
        self.service.createUser()
            .sink {
                [weak self] response in
                guard let self = self else { return }
                if let error = response.error {
                    if self.fetchTimer?.isValid ?? false {
                        self.result = .right(error)
                    } else {
                        self.fetchState = .error(error: error)
                        onError(error)
                    }
                } else {
                    if self.fetchTimer?.isValid ?? false {
                        self.result = .left(response.value!)
                    } else {
                        self.fetchState = .success(result: response.value!)
                        onSuccess(response.value!)
                    }
                }
            }
            .store(in: &self.cancellables)
    }
}
