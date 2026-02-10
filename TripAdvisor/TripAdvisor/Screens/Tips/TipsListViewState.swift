//
//  TipsListViewState.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 16.06.2025.
//

import Foundation

import Observation
import SwiftUI

@Observable
class TipsListViewState {
    
    var tips: [TripTip] = []
    var prompt: String {
        """
        Write a list of 10 tips to visit in \(destination).
        Follow these rules strictly, do not write introductory text like 'Here are 10 tips'.
        Each tip should be on a new line and include:

        title: title of tip; temperature in Celsius, 
        description: a list of short bullet points describing the place with emojis write smart amount information to each, 
        longitude: number, latitude: number

        Format example:

        title: Golden Gate Bridge; 16°C, description:
        - 🕒 You will need about 2 hours here.
        - 📸 Best visited in the morning for photos. 
        - 🚴 Great for biking and walking.
        longitude: -122.4783, latitude: 37.8199

        Make sure each bullet point starts with "- " and may include emojis.
        """
    }
    
    var tip: String = ""
    var tripId: UUID = UUID()
    var destination: String = ""
    var isLoading: Bool = false
    
    init(destination: String, tripId: UUID) {
        self.destination = destination
        self.tripId = tripId
    }
    
}
