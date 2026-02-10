//
//  Secrets.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 20.06.2025.
//

import Foundation


struct Secrets {
    static func get(_ key: String) -> String? {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) else {
            return nil
        }
        return dict[key] as? String
    }
}
