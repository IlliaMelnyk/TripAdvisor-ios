//
//  DonutChartView.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 19.06.2025.
//

import Foundation
import SwiftUI
import Charts


struct DonutChartView: View {
    let tips: [TripTip]
    
    var body: some View {
        let completedCount = tips.filter { $0.isCompleted }.count
        let incompleteCount = tips.count - completedCount
        
        let data: [ChartData] = [
            ChartData(status: "Completed", count: completedCount, color: .green),
            ChartData(status: "Incomplete", count: incompleteCount, color: .red)
        ]
        
        Chart(data) { item in
            SectorMark(
                angle: .value("Count", item.count),
                innerRadius: .ratio(0.6), 
                angularInset: 1.5
            )
            .foregroundStyle(item.color)
            .annotation(position: .overlay) {
                if item.count > 0 {
                    Text("\(item.count)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .bold()
                }
            }
        }
        .chartLegend(.visible)
    }
}
