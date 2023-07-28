import SwiftUI
import CoreLocation
import Combine
import WaterfallGrid
import SDWebImageSwiftUI
import MapKit
import Foundation

// 場所情報の構造体
struct Place: Codable, Identifiable {
    let id: String
    let name: String
    let photos: [Photo]?
    let vicinity: String
    let rating: Double?
    let openingHours: OpeningHours?
    let geometry: Geometry
    let businessStatus: String?
    let formattedPhoneNumber: String?
    let website: String?
    let url: String?
    let userRatingsTotal: Int?

    enum CodingKeys: String, CodingKey {
        case id = "place_id"
        case name
        case photos
        case vicinity
        case rating
        case openingHours = "opening_hours"
        case geometry
        case businessStatus = "business_status"
        case formattedPhoneNumber = "formatted_phone_number"
        case website
        case url
        case userRatingsTotal = "user_ratings_total"
    }
}

// 緯度・経度情報の構造体
struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}


// 営業時間情報の構造体
struct OpeningHours: Codable {
    let openNow: Bool?

    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
    }
}

// 写真情報の構造体
struct PhotoInfo: Codable {
    let photoReference: String

    enum CodingKeys: String, CodingKey {
        case photoReference = "photo_reference"
    }
}

struct Photo: Codable {
    let photoReference: String

    enum CodingKeys: String, CodingKey {
        case photoReference = "photo_reference"
    }
}

// 場所情報を取得・管理するViewModel
class PlacesViewModel: ObservableObject {
    //距離を近い順・遠い順にするためのソート
    @Published var sortOption: SortOption = .none

      enum SortOption {
          case none
          case nearest
          case farthest
      }
    @AppStorage("selectedCategory") private var selectedCategory = "restaurant"

    @Published var searchRadius: Double = UserDefaults.standard.double(forKey: "searchRadius") {
          didSet {
              UserDefaults.standard.set(searchRadius, forKey: "searchRadius")
          }
      }

    @Published private(set) var places = [Place]()
    private var cancellationToken: AnyCancellable?

    private let baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location="
    private let apiKey = "AIzaSyDk-Yqp9PXzWSmTtjZBvEEThvE-sXMa6aM" // ここに有効なAPIキーを設定

    //距離を近い順・遠い順にするメゾット
    func sortPlaces(userLocation: CLLocation) {
          switch sortOption {
          case .nearest:
              places.sort { place1, place2 in
                  let location1 = CLLocation(latitude: place1.geometry.location.lat, longitude: place1.geometry.location.lng)
                  let location2 = CLLocation(latitude: place2.geometry.location.lat, longitude: place2.geometry.location.lng)
                  return userLocation.distance(from: location1) < userLocation.distance(from: location2)
              }
          case .farthest:
              places.sort { place1, place2 in
                  let location1 = CLLocation(latitude: place1.geometry.location.lat, longitude: place1.geometry.location.lng)
                  let location2 = CLLocation(latitude: place2.geometry.location.lat, longitude: place2.geometry.location.lng)
                  return userLocation.distance(from: location1) > userLocation.distance(from: location2)
              }
          case .none:
              break
          }
      }

    
    
    // 指定された位置周辺の場所情報を取得
    func fetchPlaces(for location: CLLocation) {
           var urlComponents = URLComponents()
           urlComponents.scheme = "https"
           urlComponents.host = "maps.googleapis.com"
           urlComponents.path = "/maps/api/place/nearbysearch/json"
           urlComponents.queryItems = [
               URLQueryItem(name: "location", value: "\(location.coordinate.latitude),\(location.coordinate.longitude)"),
               URLQueryItem(name: "radius", value: "\(searchRadius)"),
               URLQueryItem(name: "type", value: selectedCategory),
               URLQueryItem(name: "key", value: apiKey)
           ]
        
        guard let url = urlComponents.url else {
            print("Invalid URL")
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
            }, receiveValue: { [weak self] response in
                self?.places = response.places
                print(response.places)
                print(url)
            })
    }
}

// 場所情報のレスポンス構造体
struct PlacesResponse: Codable {
    let places: [Place]

    enum CodingKeys: String, CodingKey {
        case places = "results"
    }
}

// 位置情報を取得・管理するLocationManager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocation?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
    }
}

// ホーム画面
struct home: View {
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var placesViewModel = PlacesViewModel()
    
    // 追加: 選択されたカテゴリーを監視する
    @AppStorage("selectedCategory") private var selectedCategory = "restaurant" {
        didSet {
            if let userLocation = locationManager.userLocation {
                placesViewModel.fetchPlaces(for: userLocation)
            }
        }
    }
    // カテゴリー関連の変数を追加
    let categories = [
        "restaurant",
        "cafe",
        "bar",
        "park",
        "tourist_attraction"
    ]
    
    let categoryLabels = [
        "レストラン",
        "カフェ",
        "居酒屋",
        "公園",
        "観光名所"
    ]
    
    
    //検索範囲
    // 追加: 検索範囲とそのラベル
    let searchRadii = [
        500.0,
        1000.0,
        2000.0,
        5000.0
    ]
    
    let searchRadiusLabels = [
        "500m",
        "1km",
        "2km",
        "5km"
    ]
    
    //押した範囲に応じてボタンのTextを変更
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
                        // 並べ替えボタンと検索範囲の選択ボタンを配置するHStack
                        
                        HStack {
                            // 並べ替えボタン
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
                            .padding(EdgeInsets(
                                top: 0,
                                leading: 17, //左の余白
                                bottom: 0,
                                trailing: 0 //右の余白
                            ))
                            
                            
                            // 検索範囲の選択ボタン
                            Menu {
                                ForEach(searchRadii.indices, id: \.self) { index in
                                    Button(action: {
                                        placesViewModel.searchRadius = searchRadii[index]
                                        if let userLocation = locationManager.userLocation {
                                            placesViewModel.fetchPlaces(for: userLocation)
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
                        
                        // カテゴリー選択UIを追加
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(categories.indices, id: \.self) { index in
                                    Button(action: {
                                        selectedCategory = categories[index]
                                        if let userLocation = locationManager.userLocation {
                                            placesViewModel.fetchPlaces(for: userLocation)
                                        }
                                    }) {
                                        Text(categoryLabels[index])
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .background(selectedCategory == categories[index] ? Color.orange : Color.gray)
                                            .foregroundColor(.white)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 8)
                        ScrollView {
                            // WaterfallGridで場所を表示
                            WaterfallGrid(placesViewModel.places, id: \.id) { place in
                                Group {
                                    if let photos = place.photos, let photoReference = photos.first?.photoReference {
                                        VStack {
                                            ZStack(alignment: .topTrailing) {
                                                let imageURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=AIzaSyDk-Yqp9PXzWSmTtjZBvEEThvE-sXMa6aM"
                                                
                                                // 場所の詳細画面へのナビゲーションリンク
                                                NavigationLink(destination: PlaceDetailsView(place: place)) {
                                                    WebImage(url: URL(string: imageURL))
                                                        .resizable()
                                                        .scaledToFit()
                                                        .cornerRadius(10)
                                                        .padding(5)
                                                }
                                                
                                                // 現在地からの距離を表示
                                                if let currentLocation = $locationManager.userLocation.wrappedValue {
                                                    let placeLocation = CLLocation(latitude: place.geometry.location.lat, longitude: place.geometry.location.lng)
                                                    let distance = Int(currentLocation.distance(from: placeLocation))
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
                                    }
                                }
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
                    // 画面が表示されたときに、現在地周辺の施設を取得する
                    if let userLocation = locationManager.userLocation {
                        placesViewModel.fetchPlaces(for: userLocation)
                    }
                }
            }
        }.navigationViewStyle(.stack)
    }
    
    struct home_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
                .environmentObject(LocationManager())
        }
    }
    
    
    
    
    
    struct PlaceDetailsView: View {
        let place: Place
        @StateObject private var placeDetailsViewModel = PlaceDetailsViewModel()
        @State private var showActionSheet = false
        @State private var showAlert = false
        @State private var alertMessage = ""
        
        //PlaceAPIから座標を取得してマップアプリを開くリンクを生成する
        var googleMapsURL: URL {
            let lat = place.geometry.location.lat
            let lng = place.geometry.location.lng
            return URL(string: "https://www.google.com/maps?q=\(lat),\(lng)")!
        }
        
        var appleMapsURL: URL {
            let lat = place.geometry.location.lat
            let lng = place.geometry.location.lng
            return URL(string: "http://maps.apple.com/?q=\(lat),\(lng)")!
        }
        
        var body: some View {
            ScrollView {
                VStack {
                    // 画像スライダー
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(placeDetailsViewModel.placeDetails?.photos ?? [], id: \.photoReference) { photo in
                                let imageURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photo.photoReference)&key=AIzaSyDk-Yqp9PXzWSmTtjZBvEEThvE-sXMa6aM"
                                
                                AsyncImage(url: URL(string: imageURL)) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .scaledToFit()
                                .frame( height: 200) // ここで画像のサイズを指定
                                .cornerRadius(10)
                                .padding(5)
                            }
                        }
                    }
                    Divider()
                    //ボタン関連
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            if let phoneNumber = placeDetailsViewModel.placeDetails?.formattedPhoneNumber,
                               let url = URL(string: "tel://\(phoneNumber)") {
                                UIApplication.shared.open(url)
                            } else {
                                print("Invalid phone number")
                            }
                        }) {
                            Image(systemName: "phone")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(Color.orange)
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                        Button(action: {
                            showActionSheet = true
                        }) {
                            Image(systemName: "map")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(Color.orange)
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                        .actionSheet(isPresented: $showActionSheet) {
                            ActionSheet(title: Text("マップアプリを選択"), buttons: [
                                .default(Text("Google Maps"), action: {
                                    UIApplication.shared.open(googleMapsURL)
                                }),
                                .default(Text("Apple Maps"), action: {
                                    UIApplication.shared.open(appleMapsURL)
                                }),
                                .cancel()
                            ])
                        }
                        Button(action: {
                            if let websiteUrl = placeDetailsViewModel.placeDetails?.websiteUrl,
                               let url = URL(string: websiteUrl) {
                                UIApplication.shared.open(url)
                            } else {
                                alertMessage = "この店舗にはwebサイトはありません"
                                showAlert = true
                            }
                        }) {
                            Image(systemName: "globe")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(Color.orange)
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("お知らせ"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
                        
                        Button(action: {
                            if let url = URL(string: "https://www.google.com/search?q=\(place.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(Color.orange)
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top)
                    .padding(.bottom)
                    // 施設の情報
                    VStack(alignment: .leading, spacing: 10) {
                        // 電話番号、営業時間、ウェブサイトのURL、クチコミ、レビュー数を入力
                        // この部分は placeDetailsViewModel.placeDetails を使って表示
                        
                        Divider()
                        
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.orange)
                            Text(placeDetailsViewModel.placeDetails?.formatted_address ?? "住所情報がありません")
                                .font(.subheadline)
                                .padding(.vertical)
                        }.padding(.horizontal)
                        Divider()
                        HStack {
                            Image(systemName: "phone")
                                .foregroundColor(.orange)
                            Text(placeDetailsViewModel.placeDetails?.formattedPhoneNumber ?? "電話番号情報がありません")
                                .font(.subheadline)
                                .padding(.vertical)
                            
                            
                        }.padding(.horizontal)
                        Divider()
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.orange)
                            Text("営業時間：")
                                .font(.subheadline)
                            
                            if let weekdayText = placeDetailsViewModel.placeDetails?.openingHours?.weekdayText {
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(weekdayText, id: \.self) { day in
                                        Text(day)
                                            .font(.subheadline)
                                    }
                                }
                            } else {
                                Text("営業時間情報がありません")
                                    .font(.subheadline)
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    
                    
                    
                    
                    
                    
                    
                }
            }
            .navigationBarTitle(place.name, displayMode: .inline)
            .onAppear {
                placeDetailsViewModel.fetchPlaceDetails(for: place.id)
            }
        }
        
        
        
        class PlaceDetailsViewModel: ObservableObject {
            // PlaceDetailsを保持するプロパティ
            @Published private(set) var placeDetails: PlaceDetails?
            // APIのベースURLとAPIキー
            private let baseURL = "https://maps.googleapis.com/maps/api/place/details/json?place_id="
            private let apiKey = "AIzaSyDk-Yqp9PXzWSmTtjZBvEEThvE-sXMa6aM"
            // placeIdを指定してPlaceDetailsを取得する関数

            
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
                
                // URLの作成に失敗した場合はエラーを表示して処理を終了

                guard let url = urlComponents.url else {
                    print("Invalid URL")
                    return
                }
                // 取得したURLをコンソールに出力
                print("URL: \(url)")
                  
                  // URLSessionでAPIリクエストを実行
                  URLSession.shared.dataTask(with: url) { data, response, error in
                      if let error = error {
                          print("Failed with error: \(error)")
                      } else if let data = data {
                          do {
                              // JSONデータをデコード
                              let placeDetailsResponse = try JSONDecoder().decode(PlaceDetailsResponse.self, from: data)
                              DispatchQueue.main.async {
                                  // デコードされたデータをplaceDetailsプロパティに格納
                                  self.placeDetails = placeDetailsResponse.placeDetails
                              }
                          } catch {
                              print("Failed to decode JSON: \(error)")
                          }
                      }
                  }.resume()
            }
        }
        // PlaceDetailsResponse構造体

        struct PlaceDetailsResponse: Codable {
            let placeDetails: PlaceDetails
            
            enum CodingKeys: String, CodingKey {
                case placeDetails = "result"
            }
        }
        // PlaceDetails構造体

        struct PlaceDetails: Codable {
            let photos: [Photo]?
            let formattedPhoneNumber: String?
            let businessStatus: String?
            let websiteUrl: String?
            let openingHours: OpeningHours?
            let formatted_address: String?
            let editorial_summary: [String: String]?
            
            enum CodingKeys: String, CodingKey {
                case photos
                case formattedPhoneNumber = "formatted_phone_number"
                case businessStatus = "business_status"
                case websiteUrl = "website"
                case openingHours = "opening_hours"
                case formatted_address = "formatted_address"
                case editorial_summary = "editorial_summary"
            }
        }
        // OpeningHours構造体

        struct OpeningHours: Codable {
            let openNow: Bool?
            let weekdayText: [String]?
            
            enum CodingKeys: String, CodingKey {
                case openNow = "open_now"
                case weekdayText = "weekday_text"
            }
        }
    }
}
