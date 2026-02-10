//
//  TripTip.swift
//  TripAdvisor
//
//  Created by Illia Melnyk on 11.06.2025.
//

import UIKit
import CoreLocation
import SwiftUICore

struct TripTip: Identifiable, Equatable, Hashable {
    let id: UUID
    let title: String
    let description: String
    var imageURL: URL?
    var isCompleted: Bool
    let coordinates: CLLocationCoordinate2D

    static func == (lhs: TripTip, rhs: TripTip) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
