import SwiftUI
import SDWebImageSwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var favoritesViewModel: FavoritesViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(favoritesViewModel.favorites) { place in
                    NavigationLink(destination: PlaceDetailsView(place: place)) {
                        VStack(alignment: .leading) {
                            Text(place.name)
                                .font(.headline)
                            Text(place.description)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("お気に入り")
        }
    }
}


struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environmentObject(FavoritesViewModel())
    }
}
