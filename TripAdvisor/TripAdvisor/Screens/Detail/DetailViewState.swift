

import Observation
import MapKit
import SwiftUI

@Observable
final class DetailViewState {
    var trip: Trip
    var selectedTips: [TripTip] = []
    
    init(trip: Trip) {
        self.trip = trip
    }
}
