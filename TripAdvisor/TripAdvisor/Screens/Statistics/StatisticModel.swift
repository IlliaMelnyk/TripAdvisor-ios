//
//  StatisticModel.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 18.06.2025.
//

import Foundation

struct Statistic: Identifiable {
    let id = UUID()
    let title: String
    let value: Double
    let date: Date
}
