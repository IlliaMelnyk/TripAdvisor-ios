//
//  DetailView.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 16.06.2025.
//

import SwiftUI

struct TipDetailView: View {
    @State private var viewModel: TipDetailViewModel
    
    init(viewModel: TipDetailViewModel) {
        self.viewModel = viewModel
    }
    
    // Rozděl description na řádky podle nových řádků
    private var descriptionLines: [String] {
        viewModel.state.tip.description
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                if let imageURL = viewModel.state.tip.imageURL,
                   imageURL.scheme?.hasPrefix("http") == true,
                   !imageURL.absoluteString.lowercased().hasSuffix(".svg") {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                    }
                } else {
                    Text("No image available or unsupported format.")
                        .foregroundColor(.gray)
                        .italic()
                }
                
                Text("Description:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.state.tip.description.components(separatedBy: "\n"), id: \.self) { line in
                        if line.starts(with: "- ") {
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")  // nebo ponech emoji z line
                                    .font(.body)
                                Text(line.dropFirst(2)) // odstraní "- " prefix
                                    .font(.body)
                            }
                        } else {
                            Text(line)
                                .font(.body)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle(viewModel.state.tip.title)
        }
    }
}

