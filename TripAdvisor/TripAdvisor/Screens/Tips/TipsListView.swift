//
//  TipsList.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 16.06.2025.
//

import Foundation
import MapKit
import SwiftUI

struct TipsListView: View {
    @ObservedObject var viewModel: TipsListViewModel
    @Binding var selectedTips: [TripTip]
    @Binding var path: NavigationPath
    @Binding var isViewPresented: Bool
    @ObservedObject var homeViewModel: HomeViewModel
    @State private var savedTrip: Trip? = nil

    let tripName: String
    let startDate: Date
    let endDate: Date
    let locationName: String
    let tripId: UUID
    let tripLocation: CLLocationCoordinate2D

    @State private var selectedTip: TripTip? = nil

    var body: some View {
        Group {
            if viewModel.state.isLoading {
                ProgressView("Loading tips...")
            } else {
                List {
                    ForEach(viewModel.state.tips, id: \.id) { tip in
                        TipRow(
                            tip: tip,
                            isSelected: selectedTips.contains(where: { $0.id == tip.id }),
                            onToggleSelection: {
                                if let index = selectedTips.firstIndex(where: { $0.id == tip.id }) {
                                    selectedTips.remove(at: index)
                                } else {
                                    selectedTips.append(tip)
                                }
                            },
                            onTapTitle: {
                                selectedTip = tip
                            }
                        )
                    }
                }
                .listStyle(.plain)
            }
        }
        .onChange(of: isViewPresented) { isPresented in
            print("📌 isViewPresented changed to \(isPresented)")
            if !isPresented, let trip = savedTrip {
                print("🌍 Appending trip to path: \(trip.name) with \(trip.tripTips.count) tips")
                path.append(trip)
                savedTrip = nil
            } else if isPresented {
                print("🖥️ TipsListView is presented")
            }
        }
        .navigationTitle("Tips for trip")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let newTrip = Trip(
                        id: tripId,
                        name: tripName,
                        startDate: startDate,
                        endDate: endDate,
                        locationName: locationName,
                        coordinates: tripLocation,
                        tripTips: selectedTips
                    )
                    let saved = homeViewModel.addTrip(trip: newTrip)
                    
                    isViewPresented = false // ← zavře sheet a vrátí uživatele na HomeView
                }
            }
        }
        .onAppear {
            print("🖥️ TipsListView onAppear triggered")
            if viewModel.state.tips.isEmpty {
                print("🖥️ Fetching tips because tips array is empty")
                viewModel.fetchTips()
            } else {
                print("🖥️ Tips array already has \(viewModel.state.tips.count) tips")
            }
        }
        .navigationDestination(item: $selectedTip) { tip in
            TipDetailView(viewModel: TipDetailViewModel(tip: tip))
        }
    }
}

