//
//  Trip.swift
//  TripAdvisor
//
//  Created by Illia Melnyk on 11.06.2025.
//

import UIKit
import CoreLocation
import SwiftUICore

struct Trip: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let startDate: Date
    let endDate: Date
    let locationName: String
    let coordinates: CLLocationCoordinate2D
    var tripTips: [TripTip]

    static func == (lhs: Trip, rhs: Trip) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
