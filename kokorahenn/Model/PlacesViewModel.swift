import SwiftUI
import Combine
import CoreLocation

class PlacesViewModel: ObservableObject {
    @Published var places = [Place]()
    @Published var sortOption: SortOption = .none
    @Published var searchRadius: Int = UserDefaults.standard.integer(forKey: "searchRadius") {
        didSet {
            UserDefaults.standard.set(searchRadius, forKey: "searchRadius")
        }
    }
    @Published var currentPage = 1
    @Published var isLoading = false
    @Published var hasMorePages = true

    private var cancellationToken: AnyCancellable?
    private let baseURL = "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/"
    private let apiKey = "acbe7482004ecb97"

    enum SortOption {
        case none
        case nearest
        case farthest
    }

    func fetchPlaces(lat: Double, lng: Double, page: Int = 1) {
        guard !isLoading else { return }
        isLoading = true

        let start = (page - 1) * 50 + 1
        let count = 50

        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lng", value: "\(lng)"),
            URLQueryItem(name: "range", value: "\(searchRadius)"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "start", value: "\(start)"),
            URLQueryItem(name: "count", value: "\(count)")
        ]

        guard let url = urlComponents.url else {
            print("Invalid URL")
            isLoading = false
            return
        }

        cancellationToken = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PlacesResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Failed with error: \(error)")
                }
                self.isLoading = false
            }, receiveValue: { [weak self] (response: PlacesResponse) in
                if page == 1 {
                    self?.places = response.results.shop
                } else {
                    self?.places.append(contentsOf: response.results.shop)
                }
                self?.currentPage = page
                self?.hasMorePages = response.results.shop.count == count

                // ログに取得したデータを表示
                print("Fetched \(response.results.shop.count) places")
                response.results.shop.forEach { place in
                    print("Place: \(place.name), Address: \(place.address)")
                }
            })
    }

    func sortPlaces(userLocation: CLLocation) {
        switch sortOption {
        case .nearest:
            places.sort { place1, place2 in
                let location1 = CLLocation(latitude: place1.lat ?? 0, longitude: place1.lng ?? 0)
                let location2 = CLLocation(latitude: place2.lat ?? 0, longitude: place2.lng ?? 0)
                return userLocation.distance(from: location1) < userLocation.distance(from: location2)
            }
        case .farthest:
            places.sort { place1, place2 in
                let location1 = CLLocation(latitude: place1.lat ?? 0, longitude: place1.lng ?? 0)
                let location2 = CLLocation(latitude: place2.lat ?? 0, longitude: place2.lng ?? 0)
                return userLocation.distance(from: location1) > userLocation.distance(from: location2)
            }
        case .none:
            break
        }
    }
}