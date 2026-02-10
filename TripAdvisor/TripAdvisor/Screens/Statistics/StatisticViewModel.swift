    //
//  StatisticViewModel.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 18.06.2025.
//

import Foundation
import Combine
import CoreLocation

@Observable
class StatisticViewModel: ObservableObject {

    private var dataManager: DataManaging
    var state: StatisticViewState
    
    init() {
        dataManager = DIContainer.shared.resolve()
        state = StatisticViewState()
        fetchTrips()
    }

    
}

extension StatisticViewModel {

    
    func fetchTrips() {
        let tripEntities: [TripEntity] = dataManager.fetchTrips()

        state.trips = tripEntities.map { tripEntity in
            let tips: [TripTip] = (tripEntity.tripTips?.allObjects as? [TripTipEntity])?.map { tipEntity in
                TripTip(
                    id: tipEntity.id ?? UUID(),
                    title: tipEntity.title ?? "No title",
                    description: tipEntity.desc ?? "",
                    imageURL: URL(string: tipEntity.imageURL ?? ""),
                    isCompleted: tipEntity.isCompleted,
                    coordinates: CLLocationCoordinate2D(latitude: tipEntity.latitude, longitude: tipEntity.longitude)
                )
            } ?? []

            print("Trip '\(tripEntity.name ?? "no name")' has \(tips.count) tips.")

            return Trip(
                id: tripEntity.id ?? UUID(),
                name: tripEntity.name ?? "No name",
                startDate: tripEntity.startDate ?? Date(),
                endDate: tripEntity.endDate ?? Date(),
                locationName: tripEntity.locationName ?? "Unknown location",
                coordinates: CLLocationCoordinate2D(latitude: tripEntity.latitude, longitude: tripEntity.longitude),
                tripTips: tips
            )
        }
    }
    
    func updateSelectedTripTips() {
        if let selected = state.selectedTrip,
           let updatedTrip = state.trips.first(where: { $0.id == selected.id }) {
            state.selectedTrip = updatedTrip
            state.editableTips = updatedTrip.tripTips
        }
    }
    
    func selectTrip(trip: Trip) {
        state.selectedTrip = trip
        state.editableTips = trip.tripTips
    }
    
    
    
    
}
