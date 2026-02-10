//
//  MapViewModel.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 13.06.2025.
//

import Foundation

import SwiftUI
import CoreLocation
import Foundation

@Observable
class MapViewModel: ObservableObject {
    var state: MapViewState = MapViewState()

    private var dataManager: DataManaging
    private var locationManager: LocationManaging
    private var periodicUpdatesRunning = false

    init() {
        dataManager = DIContainer.shared.resolve()
        locationManager = DIContainer.shared.resolve()
        //state = MapViewState(tips: tips, palces: palces) todo
    }
}

extension MapViewModel {
    func fetchTripPlaces() {
        let trip: [TripEntity] = dataManager.fetchTrips()

        state.trips = trip.map { tripEntity in
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

            return Trip(
                id: tripEntity.id ?? UUID(),
                name: tripEntity.name ?? "no name",
                startDate: tripEntity.startDate ?? Date(),
                endDate: tripEntity.endDate ?? Date(),
                locationName: tripEntity.locationName ?? "no loc name",
                coordinates: CLLocationCoordinate2D(latitude: tripEntity.latitude, longitude: tripEntity.longitude),
                tripTips: tips
            )
        }
    }
    /*
    func removePlace(place: MapPlace) {
        if let poi = dataManager.fetchPlaceWithId(id: place.id) {
            dataManager.removePlace(place: poi)
            fetchMapPlaces()
        } else {
            print("Cannot fetch PointOfInterest with given id")
        }
    }
     */

    func syncLocation() {
        state.mapCameraPosition = locationManager.cameraPosition
        state.currentLocation = locationManager.currentLocation
    }

    func startPeriodicLocationUpdate() async {
        if !periodicUpdatesRunning {
            periodicUpdatesRunning.toggle()

            while true {
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                syncLocation()
            }
        }
    }
}
