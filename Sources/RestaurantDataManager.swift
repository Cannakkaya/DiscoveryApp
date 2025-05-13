import Foundation
import CoreData
import Combine

class RestaurantDataManager {
    static let shared = RestaurantDataManager()
    
    private let persistenceController = PersistenceController.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // Save restaurant from DTO to Core Data
    func saveRestaurant(_ restaurantDTO: RestaurantDTO) {
        let context = persistenceController.container.viewContext
        
        // Check if restaurant already exists
        let fetchRequest: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", restaurantDTO.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            let restaurant: Restaurant
            
            if let existingRestaurant = results.first {
                // Update existing restaurant
                restaurant = existingRestaurant
            } else {
                // Create new restaurant
                restaurant = Restaurant(context: context)
                restaurant.id = restaurantDTO.id
            }
            
            // Update properties
            restaurant.name = restaurantDTO.name
            restaurant.address = restaurantDTO.address
            restaurant.city = restaurantDTO.city
            restaurant.cuisine = restaurantDTO.cuisine
            restaurant.rating = restaurantDTO.rating
            restaurant.latitude = restaurantDTO.latitude
            restaurant.longitude = restaurantDTO.longitude
            restaurant.imageURLs = restaurantDTO.imageURLs
            restaurant.openingHours = restaurantDTO.openingHours
            restaurant.phoneNumber = restaurantDTO.phoneNumber
            restaurant.priceLevel = Int16(restaurantDTO.priceLevel)
            
            // Save context
            try context.save()
        } catch {
            print("Error saving restaurant: \(error)")
        }
    }
    
    // Fetch all restaurants from Core Data
    func fetchRestaurants() -> [Restaurant] {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching restaurants: \(error)")
            return []
        }
    }
    
    // Fetch restaurants by city
    func fetchRestaurants(city: String) -> [Restaurant] {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "city == %@", city)
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching restaurants by city: \(error)")
            return []
        }
    }
    
    // Toggle favorite status
    func toggleFavorite(restaurantId: String) {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", restaurantId)
        
        do {
            if let restaurant = try context.fetch(fetchRequest).first {
                restaurant.isFavorite = !restaurant.isFavorite
                try context.save()
            }
        } catch {
            print("Error toggling favorite: \(error)")
        }
    }
    
    // Fetch favorite restaurants
    func fetchFavoriteRestaurants() -> [Restaurant] {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isFavorite == YES")
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching favorite restaurants: \(error)")
            return []
        }
    }
    
    // Sync restaurants from API
    func syncRestaurants(city: String) -> AnyPublisher<[Restaurant], Error> {
        return APIService.shared.fetchRestaurants(city: city)
            .map { restaurantDTOs -> [Restaurant] in
                // Save each restaurant to Core Data
                restaurantDTOs.forEach { self.saveRestaurant($0) }
                
                // Return fetched restaurants from Core Data
                return self.fetchRestaurants(city: city)
            }
            .eraseToAnyPublisher()
    }
}