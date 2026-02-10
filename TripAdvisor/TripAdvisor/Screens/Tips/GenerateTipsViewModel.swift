//
//  GenerateTipsViewModel.swift
//  TripAdvisor
//
//  Created by Illia Melnyk on 19.06.2025.
//

import Foundation
import Combine
import Observation
import MapKit

class GenerateTipsViewModel: ObservableObject {
    @Published var generatedTips: [TripTip] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = GoogleAIStudioService()
    private let service2 = UnsplashService()

    let destination: String
    let existingTips: [TripTip]

    init(destination: String, existingTips: [TripTip]) {
        self.destination = destination
        self.existingTips = existingTips
    }

    func fetchNewTips() {
        isLoading = true
        errorMessage = nil
        print("📝 Sending prompt: \(prompt)")

        service.generateTips(prompt: prompt) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let rawTips):
                    let tips = self.parseTripTips(from: rawTips).filter { newTip in
                        let newTitle = newTip.title.components(separatedBy: ";").first!.lowercased()
                        return !self.existingTips.contains { existing in
                            let existingTitle = existing.title.components(separatedBy: ";").first!.lowercased()
                            return newTitle.contains(existingTitle) || existingTitle.contains(newTitle)
                        }
                    }
                    self.generatedTips = tips
                    print("🔍 Parsed \(tips.count) new tips: \(tips.map { $0.title }.joined(separator: ", "))")
                    self.fetchImagesForTips()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("⚠️ Failed to fetch tips: \(error.localizedDescription)")
                }
            }
        }
    }

    private func fetchImagesForTips() {
        for index in generatedTips.indices {
            let title = generatedTips[index].title
            fetchImageForTipTitle(title, index: index)
        }
    }

    private func fetchImageForTipTitle(_ title: String, index: Int) {
        // Clean title: remove temperature and summary
        let trimmedTitle = title.components(separatedBy: ";")
            .first?
            .components(separatedBy: ":")
            .last?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? title
        print("🔍 Fetching image for title: \(trimmedTitle)")
        service2.searchImageURLs(query: trimmedTitle) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let urls):
                    if let urlString = urls.first, let url = URL(string: urlString) {
                        self.generatedTips[index].imageURL = url
                        print("✅ Set image URL for \(trimmedTitle)")
                    } else {
                        print("⚠️ No valid URL found for \(trimmedTitle)")
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("⚠️ Failed to fetch image for \(trimmedTitle): \(error.localizedDescription)")
                }
            }
        }
    }

    private var prompt: String {
        let existingTitles = existingTips.map {
            $0.title.components(separatedBy: ";").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? $0.title
        }.joined(separator: ", ")
        let exclusionText = existingTitles.isEmpty ? "" : "\nStrictly exclude the following locations and any variations of their names (e.g., do not include 'Lombard Street (eastern segment)' if 'Lombard Street' is listed, or 'Explore Alcatraz' if 'Alcatraz Island' is listed, or 'Conservatory of Flowers' if 'Japanese Tea Garden' is listed): \(existingTitles)."
        return """
        Write a list of 10 unique tips to visit in \(destination).
        Follow these rules strictly, do not write introductory text like 'Here are 10 tips'.
        Each tip must be for a different location not included in the excluded list below.
        Each tip ends with a new line and follows this exact format:
        
        title: title of location; temperature in Celsius°C, description:
        - First description point with emoji.
        - Second description point with emoji.
        - Third description point with emoji.
        longitude: number, latitude: number
        
        Use real coordinates for each place.
        Titles must be the specific name of the location or attraction, without verbs like 'Explore', 'Visit', or 'Ride'.
        Do not include any summary text after the temperature; the title must only contain the location name and temperature (e.g., 'Lands End; 14°C').
        Ensure temperatures are realistic for San Francisco (12-24°C).
        \(exclusionText)
        """
    }

    func parseTripTips(from rawText: String) -> [TripTip] {
        let entries = rawText.components(separatedBy: "\n\n").filter { !$0.isEmpty }
        var tips: [TripTip] = []
        print("📜 Found \(entries.count) entries")

        for (index, entry) in entries.enumerated() {
            print("📜 Parsing entry \(index): \(entry.prefix(100))...")

            // Find ranges for each field
            guard let descriptionRange = entry.range(of: ":\n"),
                  let longitudeRange = entry.range(of: "longitude: "),
                  let latitudeRange = entry.range(of: "latitude: ") else {
                print("⚠️ Failed to find ranges for entry \(index): \(entry)")
                continue
            }

            // Extract title (from start to first colon before description)
            let titleEndIndex = descriptionRange.lowerBound
            let rawTitleParts = String(entry[..<titleEndIndex])
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: ";")
            guard let titleBase = rawTitleParts.first?.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespacesAndNewlines),
                  rawTitleParts.count > 1,
                  let tempPart = rawTitleParts[1].components(separatedBy: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                print("⚠️ Invalid title format for entry \(index)")
                continue
            }
            let rawTitle = "\(titleBase); \(tempPart)°C"
            print("📜 Parsed title: \(rawTitle)")

            // Extract description (between ":\n" and "longitude: ")
            let descriptionStartIndex = descriptionRange.upperBound
            let descriptionEndIndex = longitudeRange.lowerBound
            let rawDescription = String(entry[descriptionStartIndex..<descriptionEndIndex])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            print("📜 Parsed description: \(rawDescription.prefix(50))...")

            // Extract longitude (between "longitude: " and "latitude: ")
            let longitudeEndIndex = latitudeRange.lowerBound
            let longitudeStr = String(entry[longitudeRange.upperBound..<longitudeEndIndex])
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: ",", with: "")
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
}
