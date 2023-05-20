import Foundation

class Favorites: ObservableObject {
    @Published private(set) var placeIds: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(placeIds), forKey: "favorites")
        }
    }

    init() {
        let ids = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
        placeIds = Set(ids)
    }

    func add(_ placeId: String) {
        placeIds.insert(placeId)
    }

    func remove(_ placeId: String) {
        placeIds.remove(placeId)
    }

    func isFavorite(_ placeId: String) -> Bool {
        return placeIds.contains(placeId)
    }
}
