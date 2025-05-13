import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
}

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    func fetch<T: Decodable>(url: URL) -> AnyPublisher<T, APIError> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                if let error = error as? DecodingError {
                    return .decodingError(error)
                } else {
                    return .networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchRestaurants(city: String) -> AnyPublisher<[RestaurantDTO], APIError> {
        // In a real app, you would construct a proper URL with your API endpoint
        guard let url = URL(string: "https://api.example.com/restaurants?city=\(city)") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return fetch(url: url)
    }
    
    func fetchTransportOptions(from: String, to: String) -> AnyPublisher<[TransportOptionDTO], APIError> {
        // In a real app, you would construct a proper URL with your API endpoint
        guard let url = URL(string: "https://api.example.com/transport?from=\(from)&to=\(to)") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return fetch(url: url)
    }
}