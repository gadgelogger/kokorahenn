import SwiftUI
import MapKit

struct DetailButtons: View {
    let latitude: Double
    let longitude: Double
    let websiteUrl: String
    let shopName: String

    var body: some View {
        HStack {
            Button(action: {
                openMapApp()
            }) {
                Image(systemName: "map")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }

            if !websiteUrl.isEmpty {
                Button(action: {
                    openWebsite()
                }) {
                    Image(systemName: "safari")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }

            Button(action: {
                searchGoogle()
            }) {
                Image(systemName: "magnifyingglass")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
        }
    }

    private func openMapApp() {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = shopName
        mapItem.openInMaps()
    }

    private func openWebsite() {
        if let url = URL(string: websiteUrl) {
            UIApplication.shared.open(url)
        }
    }

    private func searchGoogle() {
        let query = shopName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.google.com/search?q=\(query)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}