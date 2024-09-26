import SwiftUI
import CoreLocation
import Combine
import WaterfallGrid
import SDWebImageSwiftUI

struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var placesViewModel = PlacesViewModel()

    let searchRadii = [1, 2, 3, 4, 5]
    let searchRadiusLabels = ["300m", "500m", "1000m", "2000m", "3000m"]

    private var selectedSearchRadiusLabel: String {
        if let index = searchRadii.firstIndex(of: placesViewModel.searchRadius) {
            return searchRadiusLabels[index]
        } else {
            return "検索範囲"
        }
    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    VStack {
                        HStack {
                            Button(action: {
                                placesViewModel.sortOption = placesViewModel.sortOption == .nearest ? .farthest : .nearest
                                if let userLocation = locationManager.userLocation {
                                    placesViewModel.sortPlaces(userLocation: userLocation)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.up.arrow.down")
                                    Text(placesViewModel.sortOption == .nearest ? "近い順" : "遠い順")
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                            }
                            .padding(.leading, 17)

                            Menu {
                                ForEach(searchRadii.indices, id: \.self) { index in
                                    Button(action: {
                                        placesViewModel.searchRadius = searchRadii[index]
                                        if let userLocation = locationManager.userLocation {
                                            placesViewModel.fetchPlaces(lat: userLocation.coordinate.latitude, lng: userLocation.coordinate.longitude)
                                        }
                                    }) {
                                        Text(searchRadiusLabels[index])
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "location.circle")
                                    Text(selectedSearchRadiusLabel)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                            }

                            Spacer()
                        }

                        ScrollView {
                            WaterfallGrid(placesViewModel.places, id: \.id) { place in
                                VStack {
                                    ZStack(alignment: .topTrailing) {
                                        NavigationLink(destination: PlaceDetailsView(place: place)) {
                                            if let photoURL = URL(string: place.photo.pc.l) {
                                                WebImage(url: photoURL)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .cornerRadius(10)
                                                    .padding(5)
                                            }
                                        }
                                        if let userLocation = locationManager.userLocation {
                                            let placeLocation = CLLocation(latitude: place.lat, longitude: place.lng)
                                            let distance = Int(userLocation.distance(from: placeLocation))
                                            Text("\(distance) m")
                                                .font(.footnote)
                                                .padding(5)
                                                .background(Color.yellow)
                                                .cornerRadius(5)
                                                .padding([.top, .trailing], 5)
                                                .foregroundColor(.black)
                                        }
                                    }
                                }
                                .onAppear {
                                    if place == placesViewModel.places.last && placesViewModel.hasMorePages {
                                        if let userLocation = locationManager.userLocation {
                                            placesViewModel.fetchPlaces(lat: userLocation.coordinate.latitude, lng: userLocation.coordinate.longitude, page: placesViewModel.currentPage + 1)
                                        }
                                    }
                                }
                            }

                            if placesViewModel.isLoading {
                                ProgressView()
                                    .padding()
                            }
                        }

                        if placesViewModel.places.isEmpty {
                            VStack {
                                Image("found")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                Text("周りに何もありません\nカテゴリーや検索範囲などを\n変えてみてください")
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 16)
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
                }
                .navigationBarTitle("周辺の施設", displayMode: .automatic)
                .onAppear {
                    if let userLocation = locationManager.userLocation {
                        placesViewModel.fetchPlaces(lat: userLocation.coordinate.latitude, lng: userLocation.coordinate.longitude)
                    }
                }
                .onChange(of: locationManager.userLocation) { newLocation in
                    if let userLocation = newLocation {
                        placesViewModel.fetchPlaces(lat: userLocation.coordinate.latitude, lng: userLocation.coordinate.longitude)
                    }
                }
            }
        }.navigationViewStyle(.stack)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(LocationManager())
    }
}