//
//  TipsListViewModel.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 16.06.2025.
//

import Foundation
import Combine
import Observation
import MapKit

class TipsListViewModel: ObservableObject {
    
    @Published var errorMessage: String?
    @Published var addedTipIDs: Set<UUID> = []
    var state: TipsListViewState
    private let service = GoogleAIStudioService()
    private let service2 = UnsplashService()
    private var dataManager: DataManaging
    
    init(destination: String, tripId: UUID) {
        dataManager = DIContainer.shared.resolve()
        state = TipsListViewState(destination: destination, tripId: tripId)
    }


}

extension TipsListViewModel {
    
    func fetchTips() {
        guard !state.isLoading else { return }  // Prevent multiple fetches at the same time
        
        state.isLoading = true
        errorMessage = nil

        service.generateTips(prompt: state.prompt) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let tipText):
                    let parsedTips = self.parseTripTips(from: tipText)
                    print("🔍 Parsed \(parsedTips.count) tips")
                    if parsedTips.isEmpty {
                        self.errorMessage = "No tips found. Please try again."
                    } else {
                        self.state.tips = parsedTips
                        print("🔍 Updated state.tips with \(self.state.tips.count) tips")
                    }
                    self.state.isLoading = false

                    self.state.tips.indices.forEach { index in
                        let fullTitle = self.state.tips[index].title
                        let trimmedTitle = fullTitle.components(separatedBy: ";").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? fullTitle
                        self.fetchImageForTipTitle(trimmedTitle, index: index)
                    }

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.state.isLoading = false
                }
            }
        }
    }
    
    func parseTripTips(from rawText: String) -> [TripTip] {
        var entries = rawText.components(separatedBy: "\ntitle: ").filter { !$0.isEmpty }

        if entries.first?.starts(with: "title: ") == true {
            entries[0] = String(entries[0].dropFirst("title: ".count))
        }
        var tips: [TripTip] = []
        print("📜 Found \(entries.count) entries")

        for (index, entry) in entries.enumerated() {
            print("📜 Parsing entry \(index): \(entry.prefix(100))...")

            // Find ranges for each field
            guard let descriptionRange = entry.range(of: "description:\n"),
                  let longitudeRange = entry.range(of: "longitude: "),
                  let latitudeRange = entry.range(of: "latitude: ") else {
                print("⚠️ Failed to find ranges for entry \(index)")
                continue
            }

            // Extract title (from start to description:)
            let titleEndIndex = descriptionRange.lowerBound
            let rawTitle = String(entry[..<titleEndIndex])
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: ",", with: "")
            print("📜 Parsed title: \(rawTitle)")

            // Extract description (between "description:\n" and "longitude: ")
            let descriptionStartIndex = descriptionRange.upperBound
            let descriptionEndIndex = longitudeRange.lowerBound
            let rawDescription = String(entry[descriptionStartIndex..<descriptionEndIndex])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            print("📜 Parsed description: \(rawDescription.prefix(50))...")

            // Extract longitude (between "longitude: " and "latitude: ")
            let longitudeEndIndex = latitudeRange.lowerBound
            let longitudeStr = String(entry[longitudeRange.upperBound..<longitudeEndIndex])
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: ",", with: "") // Remove trailing comma
            guard let longitude = Double(longitudeStr) else {
                print("⚠️ Invalid longitude '\(longitudeStr)' for entry \(index)")
                continue
            }
            print("📜 Parsed longitude: \(longitude)")

            // Extract latitude (after "latitude: ")
            let latitudeStr = String(entry[latitudeRange.upperBound...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard let latitude = Double(latitudeStr) else {
                print("⚠️ Invalid latitude '\(latitudeStr)' for entry \(index)")
                continue
            }
            print("📜 Parsed latitude: \(latitude)")

            // Create TripTip
            let tip = TripTip(
                id: UUID(),
                title: rawTitle,
                description: rawDescription,
                imageURL: nil,
                isCompleted: false,
                coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            )
            tips.append(tip)
            print("✅ Added tip: \(tip.title)")
        }

        print("📜 Total tips parsed: \(tips.count)")
        return tips
    }
    
    private func fetchImageForTipTitle(_ title: String, index: Int) {
        service2.searchImageURLs(query: title) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let urls):
                    if let urlString = urls.first, let url = URL(string: urlString) {
                        // Safely update the correct tip
                        self?.state.tips[index].imageURL = url
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}



