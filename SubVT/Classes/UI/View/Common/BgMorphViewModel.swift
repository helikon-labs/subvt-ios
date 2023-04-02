//
//  BgMorphViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 31.07.2022.
//

import Foundation

class BgMorphViewModel: ObservableObject {
    enum Step {
        case start
        case mid
        case end
        
        var next: Step {
            switch self {
            case .start:
                return .mid
            case .mid:
                return .end
            case .end:
                return .start
            }
        }
    }
    
    @Published private(set) var step: Step = .start
    private var morphTimer: Timer? = nil
    
    func startTimer() {
        self.step = self.step.next
        self.morphTimer = Timer.scheduledTimer(
            withTimeInterval: 3,
            repeats: true
        ) {
            [weak self] _ in
            guard let self else { return }
            self.step = self.step.next
        }
    }
}
