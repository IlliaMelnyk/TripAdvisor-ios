
import SwiftUI

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    @State private var selectedTip: TripTip?
    @State private var showTipsOnMap = false
    @State private var showGenerateTips = false
    //@State private var selectedTips: [TripTip] = []

    init(viewModel: DetailViewModel, homeViewModel: HomeViewModel) {
            _viewModel = StateObject(wrappedValue: viewModel)
            self.homeViewModel = homeViewModel
        }

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("From \(formatDate(viewModel.state.trip.startDate)) to \(formatDate(viewModel.state.trip.endDate))")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    if !viewModel.state.selectedTips.isEmpty {
                        Text("Tips:")
                            .font(.headline)
                            .padding(.top, 8)

                        ForEach(viewModel.state.selectedTips) { tip in
                            HStack {
                                Button(action: {
                                    viewModel.toggleTipCompletion(tip: tip)
                                }) {
                                    Image(systemName: tip.isCompleted ? "checkmark.square.fill" : "square")
                                        .foregroundColor(tip.isCompleted ? .green : .primary)
                                }
                                .buttonStyle(.plain)

                                Button(action: {
                                    selectedTip = tip
                                }) {
                                    Text(tip.title)
                                        .foregroundColor(.primary)
                                        .underline()
                                        .lineLimit(2)
                                }
                                .buttonStyle(.plain)

                                Spacer()
                            }
                            .padding(.vertical, 2)
                        }
                    } else {
                        Text("No tips available for this trip.")
                            .italic()
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }

            Spacer()

            VStack(spacing: 12) {
                Button(action: {
                    showTipsOnMap = true
                }) {
                    Text("Show on Map")
                        .frame(width: 150,height: 1)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.black)

                Button(action: {
                    showGenerateTips = true
                }) {
                    Text("Add Further Tips")
                        .frame(width: 150,height: 1)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.bottom)

        }
        .navigationTitle(viewModel.state.trip.name.isEmpty ? "Unnamed Trip" : viewModel.state.trip.name)
        .navigationDestination(item: $selectedTip) { tip in
            TipDetailView(viewModel: TipDetailViewModel(tip: tip))
        }
        .navigationDestination(isPresented: $showTipsOnMap) {
            MapTipsView(tips: $viewModel.state.selectedTips, tripName: viewModel.state.trip.name)
        }
        .sheet(isPresented: $showGenerateTips) {
            GenerateTipsView(
                   viewModel: GenerateTipsViewModel(
                       destination: viewModel.state.trip.locationName,
                       existingTips: viewModel.state.selectedTips
                   ),
                   selectedTips: $viewModel.state.selectedTips,
                   onTipsAdded: {
                       viewModel.refreshTrip()
                       //selectedTips = viewModel.state.trip.tripTips
                   },
                   homeViewModel: homeViewModel,
                   tripId: viewModel.state.trip.id
               )
        }
        .onAppear {
            viewModel.loadSelectedTipsFromTrip()
            //selectedTips = viewModel.state.trip.tripTips
        }
    }



    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct SheetDetailWrapper: View {
    @Environment(\.dismiss) private var dismiss
    let trip: Trip

    var body: some View {
        NavigationStack {
            DetailView(
                viewModel: DetailViewModel(trip: trip),
                homeViewModel: HomeViewModel()
            )
            .navigationBarItems(trailing:
                Button("Close") {
                    dismiss()
                }
            )
        }
    }
}
