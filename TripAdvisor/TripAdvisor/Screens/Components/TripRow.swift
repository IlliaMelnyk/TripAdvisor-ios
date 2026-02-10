//
//  TripRow.swift
//  TripAdvisor
//
//  Created by Illia Melnyk on 13.06.2025.
//

import SwiftUI

struct TripRow: View {
    let trip: Trip

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(trip.name)
                    .font(.headline)
                Text(trip.locationName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            NavigationLink(destination: DetailView(viewModel: DetailViewModel(trip: trip),homeViewModel: HomeViewModel())) {
                Image(systemName: "mappin.circle")
                    .imageScale(.large)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}
