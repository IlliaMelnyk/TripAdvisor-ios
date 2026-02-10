//
//  MapViewState.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 13.06.2025.
//

import Foundation

import Observation
import MapKit
import SwiftUI

@Observable
final class MapViewState {
    var trips: [Trip] = []
    
   // var selectedPlace: MapPlace?
    
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
