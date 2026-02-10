//
//  StatisticView.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 18.06.2025.
//

import Foundation
import SwiftUI
import Charts

struct StatisticView: View {
    @State private var viewModel: StatisticViewModel
    
    
    init(viewModel: StatisticViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                
                Text("Trips completed")
                    .font(.headline)
                
                
                
                Menu("Select Trip") {
                    ForEach(viewModel.state.trips) { trip in
                        Button(trip.name) {
                            viewModel.selectTrip(trip: trip)
                        }
                    }
                }
            
                Text("Selected: \(viewModel.state.selectedTrip?.name ?? "None")")
                    .font(.headline)
                
                if let trip = viewModel.state.selectedTrip {
                    if !trip.tripTips.isEmpty {
                        DonutChartView(tips: viewModel.state.editableTips)
                            .frame(height: 250)
                            .padding()
                    } else {
                        Text("There are no tips in \(trip.name)")
                            .foregroundColor(.gray)
                            .italic()
                    }
                } else {
                    Text("No trip selected")
                        .foregroundColor(.gray)
                        .italic()
                }
                
            }
            .padding()
            .navigationTitle("Your Statistics")
        }.onAppear {
            viewModel.fetchTrips()
            viewModel.updateSelectedTripTips()
        }
        .onChange(of: viewModel.state.selectedTrip) { _ in
        
            viewModel.updateSelectedTripTips()
        }
    }
}





