//
//  CoreDataManager.swift
//  CityGuide
//
//  Created by Artsiom Halachkin on 09.04.2025.
//
import CoreData
import CoreData

final class CoreDataManager: DataManaging {
    
    func getTip(by id: UUID) -> TripTipEntity? {
        let request = NSFetchRequest<TripTipEntity>(entityName: "TripTipEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        var tips: [TripTipEntity] = []
        
        do {
            tips = try context.fetch(request)
        } catch {
            print("Cannot fetch data: \(error.localizedDescription)")
        }
        
        return tips.first
    }
    
    private let container = NSPersistentContainer(name: "TripData")

    var context: NSManagedObjectContext {
        container.viewContext
    }

    init() {
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Cannot create persistent store: \(error.localizedDescription)")
            }
        }
    }

    func saveTrip(trip: TripEntity) {
        save()
    }

    func deleteTrip(trip: TripEntity) {
        context.delete(trip)
        save()
    }

    func fetchTrips() -> [TripEntity] {
        let request = NSFetchRequest<TripEntity>(entityName: "TripEntity")
        request.relationshipKeyPathsForPrefetching = ["tripTips"]
        var trips: [TripEntity] = []
        
        do {
            trips = try context.fetch(request)
        } catch {
            print("Cannot fetch data: \(error.localizedDescription)")
        }
        return trips
    }

    func getTrip(by id: UUID) -> TripEntity? {
        let request = NSFetchRequest<TripEntity>(entityName: "TripEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        var trips: [TripEntity] = []
        
        do {
            trips = try context.fetch(request)
        } catch {
            print("Cannot fetch data: \(error.localizedDescription)")
        }
        
        return trips.first
    }


    func saveTip(ip tip: TripTipEntity, to trip: Trip) {
        guard let tripEntity = getTrip(by: trip.id) else {
            print("Trip entity not found")
            return
        }
        
        let tipEntity = TripTipEntity(context: context)
        tipEntity.id = tip.id
        tipEntity.title = tip.title
        tipEntity.desc = tip.description  
        tipEntity.imageURL = tip.imageURL
        tipEntity.isCompleted = tip.isCompleted
        tipEntity.latitude = tip.latitude
        tipEntity.longitude = tip.longitude
        
        tipEntity.trip = tripEntity
        
        save()
    }

    func updateTip(tip: TripTip) {
        
        let request = NSFetchRequest<TripTipEntity>(entityName: "TripTipEntity")
        request.predicate = NSPredicate(format: "id ==%@", tip.id as CVarArg)
        
        if let result = try? context.fetch(request), let entity = result.first {
            entity.title = tip.title
            entity.desc = tip.description
            entity.imageURL = tip.imageURL?.absoluteString
            entity.isCompleted = tip.isCompleted
            entity.latitude = tip.coordinates.latitude
            entity.longitude = tip.coordinates.longitude
            save()
        }
    }

    func deleteTip(tip: TripTipEntity) {
        context.delete(tip)
        save()
    }
    
    func addTipToTrip(_ tip: TripTip, tripId: UUID) {
        guard let tripEntity = getTrip(by: tripId) else {
            print("Trip entity not found")
            return
        }
        
        let tipEntity = TripTipEntity(context: context)
        tipEntity.id = tip.id
        tipEntity.title = tip.title
        tipEntity.desc = tip.description
        tipEntity.imageURL = tip.imageURL?.absoluteString
        tipEntity.isCompleted = tip.isCompleted
        tipEntity.latitude = tip.coordinates.latitude
        tipEntity.longitude = tip.coordinates.longitude
        tipEntity.trip = tripEntity
        
        save()
    }
}


private extension CoreDataManager {
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
