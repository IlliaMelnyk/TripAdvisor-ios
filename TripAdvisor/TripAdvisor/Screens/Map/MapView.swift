//
//  MapView.swift
//  CityGuide
//
// Created by Artsiom Halachkin on 13.06.2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var viewModel: MapViewModel
    @State private var selectedTrip: Trip? = nil
    @State private var isDetailPresented = false
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            Map(position: $viewModel.state.mapCameraPosition, interactionModes: [.all]) {
                ForEach(viewModel.state.trips) { trip in
                    Annotation("", coordinate: trip.coordinates) {
                        TripAnnotationView(trip: trip)
                            .onTapGesture {
                                selectedTrip = trip
                                isDetailPresented = true
                            }
                            .accessibilityHidden(true)
                    }
                }
            }
            .sheet(item: $selectedTrip, onDismiss: {
                viewModel.fetchTripPlaces()
            }) { trip in
                SheetDetailWrapper(trip: trip)
            }
            .navigationTitle("Map of Trips")
            .onAppear {
                viewModel.fetchTripPlaces()
            }
        }
    }
}


#Preview {
    //MapView(viewModel: MapPlacesViewModel())
}
