import SwiftUI
import CoreData

struct FavoritesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Restaurant.name, ascending: true)],
        predicate: NSPredicate(format: "isFavorite == YES")
    ) private var favoriteRestaurants: FetchedResults<Restaurant>
    
    @State private var searchText = ""
    
    var filteredRestaurants: [Restaurant] {
        if searchText.isEmpty {
            return Array(favoriteRestaurants)
        } else {
            return favoriteRestaurants.filter { restaurant in
                guard let name = restaurant.name, let cuisine = restaurant.cuisine else { return false }
                return name.localizedCaseInsensitiveContains(searchText) || 
                       cuisine.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if favoriteRestaurants.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Favorite Restaurants")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Restaurants you mark as favorites will appear here.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button(action: {
                            // Navigate to restaurant list
                        }) {
                            Text("Discover Restaurants")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(filteredRestaurants, id: \.id) { restaurant in
                            NavigationLink(destination: RestaurantDetailFromCoreData(restaurant: restaurant)) {
                                FavoriteRestaurantRow(restaurant: restaurant)
                            }
                        }
                        .onDelete(perform: removeFromFavorites)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .searchable(text: $searchText, prompt: "Search favorites")
            .navigationTitle("Favorites")
        }
    }
    
    private func removeFromFavorites(at offsets: IndexSet) {
        for index in offsets {
            let restaurant = filteredRestaurants[index]
            restaurant.isFavorite = false
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error removing from favorites: \(error)")
        }
    }
}

struct FavoriteRestaurantRow: View {
    let restaurant: Restaurant
    
    var body: some View {
        HStack {
            // Restaurant image (placeholder or cached)
            if let imageURLs = restaurant.imageURLs, let firstImageURL = imageURLs.first {
                CachedImage(url: firstImageURL, placeholder: Image(systemName: "photo"))
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name ?? "Unknown Restaurant")
                    .font(.headline)
                
                Text(restaurant.cuisine ?? "Various Cuisine")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("\(restaurant.rating, specifier: "%.1f")")
                    ForEach(0..<Int(restaurant.rating.rounded()), id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
            
            // Price level indicators
            HStack(spacing: 2) {
                ForEach(0..<Int(restaurant.priceLevel), id: \.self) { _ in
                    Text("₺")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// Detail view for a restaurant from Core Data
struct RestaurantDetailFromCoreData: View {
    let restaurant: Restaurant
    @State private var region: MKCoordinateRegion
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        
        // Initialize the map region centered on the restaurant
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: restaurant.latitude,
                longitude: restaurant.longitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.01,
                longitudeDelta: 0.01
            )
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Restaurant image
                if let imageURLs = restaurant.imageURLs, let firstImageURL = imageURLs.first {
                    CachedImage(url: firstImageURL, placeholder: Image(systemName: "photo"))
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay(
                            Text("No Image Available")
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // Restaurant name and rating
                    HStack {
                        Text(restaurant.name ?? "Unknown Restaurant")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("\(restaurant.rating, specifier: "%.1f")")
                            .fontWeight(.bold)
                        
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    
                    // Cuisine type and price level
                    HStack {
                        Text(restaurant.cuisine ?? "Various Cuisine")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            ForEach(0..<Int(restaurant.priceLevel), id: \.self) { _ in
                                Text("₺")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Address and contact info
                    VStack(alignment: .leading, spacing: 8) {
                        Label(restaurant.address ?? "Address not available", systemImage: "mappin.and.ellipse")
                        Label(restaurant.phoneNumber ?? "Phone not available", systemImage: "phone")
                        Label(restaurant.openingHours ?? "Hours not available", systemImage: "clock")
                    }
                    
                    Divider()
                    
                    // Map view
                    Text("Location")
                        .font(.headline)
                    
                    Map(coordinateRegion: $region, annotationItems: [restaurant]) { restaurant in
                        MapMarker(
                            coordinate: CLLocationCoordinate2D(
                                latitude: restaurant.latitude,
                                longitude: restaurant.longitude
                            ),
                            tint: .red
                        )
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                    
                    // Transportation options button
                    NavigationLink(destination: TransportationView(restaurant: convertToDTO(restaurant))) {
                        HStack {
                            Image(systemName: "car.fill")
                            Text("View Transportation Options")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Helper function to convert Core Data Restaurant to DTO
    private func convertToDTO(_ restaurant: Restaurant) -> RestaurantDTO {
        return RestaurantDTO(
            id: restaurant.id ?? UUID().uuidString,
            name: restaurant.name ?? "Unknown Restaurant",
            address: restaurant.address ?? "Address not available",
            city: restaurant.city ?? "Unknown City",
            cuisine: restaurant.cuisine ?? "Various Cuisine",
            rating: restaurant.rating,
            latitude: restaurant.latitude,
            longitude: restaurant.longitude,
            imageURLs: restaurant.imageURLs ?? [],
            openingHours: restaurant.openingHours ?? "Hours not available",
            phoneNumber: restaurant.phoneNumber ?? "Phone not available",
            priceLevel: Int(restaurant.priceLevel)
        )
    }
}