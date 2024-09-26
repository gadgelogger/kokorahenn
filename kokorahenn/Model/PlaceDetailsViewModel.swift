import SwiftUI
import Combine

class PlaceDetailsViewModel: ObservableObject {
    @Published private(set) var placeDetails: PlaceDetails?
    private let baseURL = "https://maps.googleapis.com/maps/api/place/details/json?place_id="
    private let apiKey = "AIzaSyDk-Yqp9PXzWSmTtjZBvEEThvE-sXMa6aM"

    func fetchPlaceDetails(for placeId: String) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "maps.googleapis.com"
        urlComponents.path = "/maps/api/place/details/json"
        urlComponents.queryItems = [
            URLQueryItem(name: "place_id", value: placeId),
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "fields", value: "name,formatted_phone_number,website,opening_hours,photos,formatted_address,editorial_summary")
        ]

        guard let url = urlComponents.url else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed with error: \(error)")
            } else if let data = data {
                do {
                    let placeDetailsResponse = try JSONDecoder().decode(PlaceDetailsResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.placeDetails = placeDetailsResponse.placeDetails
                    }
                } catch {
                    print("Failed to decode JSON: \(error)")
                }
            }
        }.resume()
    }
}