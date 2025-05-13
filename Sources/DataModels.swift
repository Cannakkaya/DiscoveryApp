import Foundation

// Data Transfer Objects (DTOs) for API responses
struct RestaurantDTO: Codable, Identifiable {
    let id: String
    let name: String
    let address: String
    let city: String
    let cuisine: String
    let rating: Double
    let latitude: Double
    let longitude: Double
    let imageURLs: [String]
    let openingHours: String
    let phoneNumber: String
    let priceLevel: Int
}

struct TransportOptionDTO: Codable, Identifiable {
    let id: String
    let type: String // "bus", "flight", etc.
    let provider: String
    let departureTime: Date
    let arrivalTime: Date
    let price: Double
    let currency: String
    let from: String
    let to: String
}