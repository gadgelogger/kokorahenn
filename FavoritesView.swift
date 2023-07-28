import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favorites: Favorites
    @StateObject private var placesViewModel = PlacesViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(Array(favorites.placeIds), id: \.self) { placeId in
                    if let place = placesViewModel.places.first(where: { $0.id == placeId }) {
                        NavigationLink(destination: PlaceDetailsView(place: place)) {
                            Text(place.name)
                        }
                    }
                }
                .onDelete(perform: { indexSet in
                    for index in indexSet {
                        favorites.remove(Array(favorites.placeIds)[index])
                    }
                })
            }
            .navigationBarTitle("お気に入り", displayMode: .inline)
            .navigationBarItems(trailing: EditButton())
            .onAppear {
                if let userLocation = locationManager.userLocation {
                    placesViewModel.fetchPlaces(for: userLocation)
                }
            }
        }
    }
}
