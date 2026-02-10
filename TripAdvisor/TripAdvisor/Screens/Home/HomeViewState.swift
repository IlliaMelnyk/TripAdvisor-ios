//
//  MapPlacesViewState.swift
//  TripAdvisor
//
//  Created by Illia Melnyk on 13.06.2025.
//


import Observation
import MapKit
import SwiftUI

@Observable
final class HomeViewState {
    var trips: [Trip] = []
    
    var selectedTrip: Trip?
    
    var currentLocation: CLLocationCoordinate2D?
    
    var mapCameraPosition: MapCameraPosition = .camera(
        .init(
            centerCoordinate: .init(
                latitude: 49.21044343932761,
                longitude: 16.6157301199077
            ),
            distance: 3000
        )
    )
}
