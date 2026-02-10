//
//  MapPlacesViewModel.swift
//  TripAdvisor
//
//  Created by Illia Melnyk on 13.06.2025.
//


import SwiftUI
import CoreLocation
import Combine

@Observable
class HomeViewModel: ObservableObject {
    var state: HomeViewState = HomeViewState()
    
    private var dataManager: DataManaging
    private var locationManager: LocationManaging
    private var periodicUpdatesRunning = false
    
   // @Published var tip: String = ""
   // @Published var isLoading: Bool = false
   // @Published var errorMessage: String?

    private let service = GoogleAIStudioService()

    
    init() {
        dataManager = DIContainer.shared.resolve()
        locationManager = DIContainer.shared.resolve()
    }
}

extension HomeViewModel {
    
    func addTrip(trip: Trip)-> Trip {
        print("Saving trip '\(trip.name)' with \(trip.tripTips.count) tips")
        
        let context = (dataManager as! CoreDataManager).context
        let tripEntity = TripEntity(context: context)
        tripEntity.id = trip.id
        tripEntity.name = trip.name
        tripEntity.startDate = trip.startDate
        tripEntity.endDate = trip.endDate
        tripEntity.locationName = trip.locationName
        tripEntity.latitude = trip.coordinates.latitude
        tripEntity.longitude = trip.coordinates.longitude

        for tip in trip.tripTips {
            let tipEntity = TripTipEntity(context: context)
            tipEntity.id = tip.id
            tipEntity.title = tip.title
            tipEntity.desc = tip.description
            tipEntity.imageURL = tip.imageURL?.absoluteString
            tipEntity.isCompleted = tip.isCompleted
            tipEntity.latitude = tip.coordinates.latitude
            tipEntity.longitude = tip.coordinates.longitude

            tipEntity.trip = tripEntity
            tripEntity.addToTripTips(tipEntity)

            print("  → Adding tip: \(tip.title)")
        }

        dataManager.saveTrip(trip: tripEntity)
        fetchTrips()
        return trip
    }
    
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
    
    
    func fetchSampleData() {
        fetchTrips()
    }
    
    func removeTrip(trip: Trip) {
        if let entity = dataManager.getTrip(by: trip.id) {
            dataManager.deleteTrip(trip: entity)
            fetchTrips()
        } else {
            print("Cannot fetch TripEntity with given id")
        }
    }
    
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
    func addTipsToTrip(tips: [TripTip], tripId: UUID) {
        guard let tripEntity = dataManager.getTrip(by: tripId) else {
            print("❌ Trip not found for ID: \(tripId)")
            return
        }

        let existingTipIDs: Set<UUID> = Set(
            (tripEntity.tripTips?.allObjects as? [TripTipEntity])?.compactMap { $0.id } ?? []
        )

        let context = (dataManager as! CoreDataManager).context

        for tip in tips where !existingTipIDs.contains(tip.id) {
            let tipEntity = TripTipEntity(context: context)
            tipEntity.id = tip.id
            tipEntity.title = tip.title
            tipEntity.desc = tip.description
            tipEntity.imageURL = tip.imageURL?.absoluteString
            tipEntity.isCompleted = tip.isCompleted
            tipEntity.latitude = tip.coordinates.latitude
            tipEntity.longitude = tip.coordinates.longitude
            tipEntity.trip = tripEntity

            tripEntity.addToTripTips(tipEntity)

            print("➕ Added new tip '\(tip.title)' to trip '\(tripEntity.name ?? "Unnamed")'")
        }

        dataManager.saveTrip(trip: tripEntity)
        fetchTrips()
    }
}
