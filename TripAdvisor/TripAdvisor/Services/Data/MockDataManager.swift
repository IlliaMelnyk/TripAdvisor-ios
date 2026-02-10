//
//  MockDataManager.swift
//  CityGuide
//
//  Created by Illia Melnyk on 19.03.2025.
//
import Foundation
import CoreData
import UIKit

final class MockDataManager: DataManaging {
    
    var trips: [TripEntity] = []
    var tips: [TripTipEntity] = []

    var context: NSManagedObjectContext {
        NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    }

    func saveTrip(trip: TripEntity) {
        if !trips.contains(where: { $0.id == trip.id }) {
            trips.append(trip)
        }
    }
    
    func addTipToTrip(_ tip: TripTip, tripId: UUID) {
        //
    }
    
    
    func getTip(by id: UUID) -> TripTipEntity? {
        return tips.first { $0.id == id }
    }
    

    func deleteTrip(trip: TripEntity) {
        trips.removeAll { $0.id == trip.id }
        tips.removeAll {$0.trip == trip }
    }

    func fetchTrips() -> [TripEntity] {
        return trips
    }

    func getTrip(by id: UUID) -> TripEntity? {
        return trips.first { $0.id == id }
    }
    

    func saveTip(ip tip: TripTipEntity, to trip: Trip) {
        guard let tripEntity = getTrip(by: trip.id) else {
            print("Trip entity not found")
            return
        }
        let newTip = tip
        newTip.trip = tripEntity
        tips.append(newTip)
    }

    func updateTip(tip: TripTip) {
        guard let tripEntity = getTip(by: tip.id) else {
            print("Trip entity not found")
            return
        }
        
        if let index = tips.firstIndex(where: { $0.id == tip.id }) {
            tips[index] = tripEntity
        }
    }

    func deleteTip(tip: TripTipEntity) {
        tips.removeAll { $0.id == tip.id }
    }
}


