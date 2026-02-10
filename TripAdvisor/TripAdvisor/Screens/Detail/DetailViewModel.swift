
import SwiftUI
import CoreLocation

@Observable
class DetailViewModel: ObservableObject {
    var state: DetailViewState
    private var dataManager: DataManaging
    private let apiManager: APIManaging

    init(trip: Trip) {
        dataManager = DIContainer.shared.resolve()
        apiManager = DIContainer.shared.resolve()
        state = DetailViewState(trip: trip)
        print("🧭 Opening DetailViewModel for trip:", trip.name, trip.tripTips.count)
        for tip in trip.tripTips {
                print(" → Tip: \(tip.title), imageURL: \(tip.imageURL?.absoluteString ?? "nil")")
            }
    }
}
extension DetailViewModel {
    func toggleTipCompletion(tip: TripTip) {
        var updatedTip = tip
            updatedTip.isCompleted.toggle()

            dataManager.updateTip(tip: updatedTip)

            if let tripIndex = state.trip.tripTips.firstIndex(where: { $0.id == tip.id }) {
                state.trip.tripTips[tripIndex] = updatedTip
            }
            if let selectedIndex = state.selectedTips.firstIndex(where: { $0.id == tip.id }) {
                state.selectedTips[selectedIndex] = updatedTip
            }
    }
    
    func refreshTrip() {
        if let tripEntity = dataManager.getTrip(by: state.trip.id) {
            let tips: [TripTip] = (tripEntity.tripTips?.allObjects as? [TripTipEntity])?.map {
                TripTip(
                    id: $0.id ?? UUID(),
                    title: $0.title ?? "No title",
                    description: $0.desc ?? "",
                    imageURL: URL(string: $0.imageURL ?? ""),
                    isCompleted: $0.isCompleted,
                    coordinates: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                )
            } ?? []

            state.trip.tripTips = tips
            loadSelectedTipsFromTrip()
        }
    }
    func loadSelectedTipsFromTrip() {
            state.selectedTips = state.trip.tripTips
    }

}
