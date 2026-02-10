//
//  DataManaging.swift
//  CityGuide
//
//  Created by Illia Melnyk on 19.03.2025.
//
import CoreData
import UIKit

protocol DataManaging {
    var context: NSManagedObjectContext { get }


    func saveTrip(trip: TripEntity)
    func deleteTrip(trip: TripEntity)
    func fetchTrips() -> [TripEntity]
    func getTrip(by id: UUID) -> TripEntity?


    func saveTip(ip: TripTipEntity, to trip: Trip)
    func updateTip(tip: TripTip)
    func deleteTip(tip: TripTipEntity)
    func getTip(by id: UUID) -> TripTipEntity?
    func addTipToTrip(_ tip: TripTip, tripId: UUID)
}
