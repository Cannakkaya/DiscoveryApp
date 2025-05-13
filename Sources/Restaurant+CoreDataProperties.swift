import Foundation
import CoreData

extension Restaurant {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Restaurant> {
        return NSFetchRequest<Restaurant>(entityName: "Restaurant")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var address: String?
    @NSManaged public var city: String?
    @NSManaged public var cuisine: String?
    @NSManaged public var rating: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var imageURLs: [String]?
    @NSManaged public var openingHours: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var priceLevel: Int16
    @NSManaged public var isFavorite: Bool
}