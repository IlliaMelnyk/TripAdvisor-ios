//
//  GenerateTipsView.swift
//  TripAdvisor
//
//  Created by Illia Melnyk on 19.06.2025.
//

import Foundation
import MapKit
import SwiftUI

struct GenerateTipsView: View {
    @ObservedObject var viewModel: GenerateTipsViewModel
    @Binding var selectedTips: [TripTip]
    @Environment(\.dismiss) private var dismiss
    let onTipsAdded: () -> Void

    @State private var selectedGeneratedTips: Set<UUID> = []

    @ObservedObject var homeViewModel: HomeViewModel
    @State private var selectedTip: TripTip? = nil
    let tripId: UUID

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Generating tips...")
                }
                else {
                    List {
                        ForEach(viewModel.generatedTips, id: \.id) { tip in
                            TipRow(
                                tip: tip,
                                isSelected: selectedGeneratedTips.contains(tip.id),
                                onToggleSelection: {
                                    if selectedGeneratedTips.contains(tip.id) {
                                        selectedGeneratedTips.remove(tip.id)
                                    } else {
                                        selectedGeneratedTips.insert(tip.id)
                                    }
                                },
                                onTapTitle: {
                                    selectedTip = tip
                                }
                            )
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Generate Further Tips")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add Selected") {
                        let newTips = viewModel.generatedTips.filter { selectedGeneratedTips.contains($0.id) }
                        selectedTips.append(contentsOf: newTips)

                        homeViewModel.addTipsToTrip(tips: newTips, tripId: tripId)
                        onTipsAdded()
                        dismiss()
                        
                    }
                    .disabled(selectedGeneratedTips.isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.fetchNewTips()
            }
            .navigationDestination(item: $selectedTip) { tip in
                TipDetailView(viewModel: TipDetailViewModel(tip: tip))
            }
        }
    }
}
