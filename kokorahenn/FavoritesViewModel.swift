import SwiftUI
import CoreData

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Place] = []

    private let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchFavorites()
    }

    func addToFavorites(place: Place) {
        let favorite = Place(context: viewContext)
        favorite.id = UUID()
        favorite.name = place.name
        favorite.placeDescription = place.placeDescription
        favorite.imageData = place.imageData

        do {
            try viewContext.save()
            fetchFavorites()
        } catch {
            print("Error saving favorite: \(error)")
        }
    }

    func removeFromFavorites(place: Place) {
        viewContext.delete(place)

        do {
            try viewContext.save()
            fetchFavorites()
        } catch {
            print("Error removing favorite: \(error)")
        }
    }

    private func fetchFavorites() {
        let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()

        do {
            favorites = try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching favorites: \(error)")
        }
    }
}
