//
//  TripAnnotationView.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 18.06.2025.
//

import SwiftUI

struct TripAnnotationView: View {
    let trip: Trip

    let pinColor = Color(
        red: .random(in: 0.3...1),
        green: .random(in: 0.3...1),
        blue: .random(in: 0.3...1)
    )

    var body: some View {
        VStack(spacing: 4) {
            // Text nad pinem
            Text(trip.name.isEmpty ? "Unnamed" : trip.name)
                .font(.caption)
                .fontWeight(.bold)
                .padding(4)
                .background(.white.opacity(0.9))
                .cornerRadius(5)
                .shadow(radius: 1)

            // Ikona pinu
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(pinColor)
                .shadow(radius: 3)
        }
    }
}
