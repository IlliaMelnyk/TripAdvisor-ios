//
//  TipDetailViewState.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 16.06.2025.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class TipDetailViewState {
    var tip: TripTip

    init(tip: TripTip) {
        self.tip = tip
    }
}
