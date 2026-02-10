//
//  TipDetailViewModel.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 16.06.2025.
//

import Foundation
import SwiftUI
import CoreLocation

@Observable
class TipDetailViewModel: ObservableObject {
    var state: TipDetailViewState
    private var dataManager: DataManaging

    init(tip: TripTip) {
        dataManager = DIContainer.shared.resolve()
        state = TipDetailViewState(tip: tip)
    }
    
    
}
