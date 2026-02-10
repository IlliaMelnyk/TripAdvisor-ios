//
//  StatisticViewState.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 18.06.2025.
//

import Foundation



@Observable
class StatisticViewState {
    var statistics: [Statistic] = []
    var trips: [Trip] = []
    var selectedTrip: Trip?
    var editableTips: [TripTip] = []
}
