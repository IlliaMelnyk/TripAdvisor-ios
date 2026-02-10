//
//  NewMapPlaceView.swift
//  CityGuide
//
//  Created by David Procházka on 09.04.2025.
//

import CoreLocation
import MapKit
import SwiftUI

struct LocationMarker: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct NewTripView: View {
    @Binding var isViewPresented: Bool
    @ObservedObject var viewModel: HomeViewModel
    @Binding var path: NavigationPath
    
    @State private var selectedTips: [TripTip] = []

    @State private var tripName: String = ""
    @State private var locationName: String = ""
    @State private var tripLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.1951, longitude: 16.6068),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    @State private var showTipsList = false

    private let tripId = UUID()
    private let geocoder = CLGeocoder()

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Details") {
                    TextField("Trip name", text: $tripName)
                }

                Section("Date Interval") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                    DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: [.date])
                }

                Section("Destination on Map") {
                    TextField("Location name", text: $locationName)
                        .disabled(true)

                    Map(coordinateRegion: $region, interactionModes: .all, annotationItems: [LocationMarker(coordinate: tripLocation)]) { marker in
                        MapMarker(coordinate: marker.coordinate, tint: .blue)
                    }
                    .frame(height: 200)
                    .onTapGesture {
                        tripLocation = region.center
                        reverseGeocode(coordinate: tripLocation)
                    }

                    HStack {
                        Text("Latitude: \(tripLocation.latitude, specifier: "%.4f")")
                        Spacer()
                        Text("Longitude: \(tripLocation.longitude, specifier: "%.4f")")
                    }
                    .font(.caption)
                }

                Section {
                    Button("Pick Tips") {
                        showTipsList = true
                    }
                    .navigationDestination(isPresented: $showTipsList) {
                        TipsListView(
                            viewModel: TipsListViewModel(destination: locationName, tripId: tripId),
                            selectedTips: $selectedTips,
                            path: $path,
                            isViewPresented: $isViewPresented,
                            homeViewModel: viewModel,
                            tripName: tripName,
                            startDate: startDate,
                            endDate: endDate,
                            locationName: locationName,
                            tripId: tripId,
                            tripLocation: tripLocation
                        )
                    }
                }
            }
            .navigationTitle("New Trip")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isViewPresented.toggle()
                    }
                }
            }
            .onAppear {
                viewModel.syncLocation()
                if let loc = viewModel.state.currentLocation {
                    tripLocation = loc
                    region.center = loc
                    reverseGeocode(coordinate: loc)
                }
            }
        }
    }

    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let place = placemarks?.first {
                locationName = place.locality ?? place.name ?? "Unknown location"
            } else {
                locationName = "Unknown location"
            }
        }
    }
}
