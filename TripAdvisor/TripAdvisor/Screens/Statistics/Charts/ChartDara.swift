//
//  ChartDara.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 19.06.2025.
//

import Foundation
import SwiftUI

struct ChartData: Identifiable {
    let id = UUID()
    let status: String
    let count: Int
    let color: Color
}
