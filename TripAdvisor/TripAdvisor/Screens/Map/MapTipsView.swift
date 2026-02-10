//
//  MapTipsView.swift
//  TripAdvisor
//
//  Created by Illia Melnyk on 19.06.2025.
//


import MapKit
import SwiftUI

struct MapTipsView: View {
    @Binding var tips: [TripTip]
    let tripName: String
    @State private var selectedTip: TripTip? = nil
    
    @State private var filter: FilterType = .all
    
    enum FilterType: String, CaseIterable {
        case all = "Show All"
        case completed = "Only Completed"
        case remaining = "Only Remaining"
    }
    
    private var filteredTips: [TripTip] {
        switch filter {
        case .all:
            return tips
        case .completed:
            return tips.filter { $0.isCompleted }
        case .remaining:
            return tips.filter { !$0.isCompleted }
        }
    }

    @State private var region: MKCoordinateRegion = .init(
        center: CLLocationCoordinate2D(latitude: 49.1951, longitude: 16.6068),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )

    var body: some View {
        VStack {
            Picker("Filter", selection: $filter) {
                ForEach(FilterType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            Map(coordinateRegion: $region, annotationItems: filteredTips) { tip in
                MapAnnotation(coordinate: tip.coordinates) {
                    Button(action: {
                        selectedTip = tip
                    }) {
                        VStack {
                            Text(tip.title)
                                .font(.caption)
                                .padding(5)
                                .background(Color.white.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            
                            if let imageURL = tip.imageURL {
                                AsyncImage(url: imageURL) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 30, height: 30)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 30, height: 30)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                    case .failure(_):
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: tip.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(tip.isCompleted ? .green : .gray)
                                    .frame(width: 30, height: 30)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationTitle("Tips for \(tripName)")
        .onAppear {
            if let first = tips.first {
                region.center = first.coordinates
            }
        }
        .navigationDestination(item: $selectedTip) { tip in
            TipDetailView(viewModel: TipDetailViewModel(tip: tip))
        }

    }
}
