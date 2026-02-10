

import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var isViewPresented = false
    @State private var selectedTab: Tab = .home
    @State private var path = NavigationPath()

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationStack(path: $path) {
                List {
                    ForEach(viewModel.state.trips) { trip in
                        TripRow(trip: trip)
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.removeTrip(trip: trip)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("My Trips")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            isViewPresented = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .onAppear {
                    viewModel.fetchTrips()
                }
                .sheet(isPresented: $isViewPresented) {
                        NewTripView(
                                   isViewPresented: $isViewPresented,
                                   viewModel: viewModel,
                                   path: $path
                        )
                }
            }
            .onChange(of: path) { newValue in
                print("🧩 Navigation path changed: \(newValue)")
            }
        }
    }
}


#Preview {
    HomeView(viewModel: HomeViewModel())
}
