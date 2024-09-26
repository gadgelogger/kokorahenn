import Foundation

struct Place: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let address: String
    let lat: Double
    let lng: Double
    let genre: Genre
    let budget: Budget
    let catchCopy: String
    let urls: URLs
    let photo: Photo

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case lat
        case lng
        case genre
        case budget
        case catchCopy = "catch"
        case urls
        case photo
    }

    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Genre: Codable {
    let name: String
    let code: String
}

struct Budget: Codable {
    let code: String
    let name: String
}

struct URLs: Codable {
    let pc: String
}

struct Photo: Codable {
    let pc: PhotoURLs
}

struct PhotoURLs: Codable {
    let l: String
    let m: String
    let s: String
}

struct PlacesResponse: Codable {
    let results: Results
}

struct Results: Codable {
    let shop: [Place]
}