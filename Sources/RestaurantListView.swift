import SwiftUI
import Combine

struct RestaurantListView: View {
    @State private var searchText = ""
    @State private var restaurants: [RestaurantDTO] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @EnvironmentObject var locationManager: LocationManager
    
    private var filteredRestaurants: [RestaurantDTO] {
        if searchText.isEmpty {
            return restaurants
        } else {
            return restaurants.filter { $0.name.localizedCaseInsensitiveContains(searchText) || 
                                       $0.cuisine.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading restaurants...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if restaurants.isEmpty {
                    Text("No restaurants found")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(filteredRestaurants) { restaurant in
                        NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                            RestaurantRow(restaurant: restaurant)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .searchable(text: $searchText, prompt: "Search restaurants")
            .navigationTitle("Restaurants")
            .onAppear {
                loadRestaurants()
            }
        }
    }
    
    private func loadRestaurants() {
        isLoading = true
        errorMessage = nil
        
        // For demo purposes, we'll use sample data
        // In a real app, you would call your API service
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.restaurants = [
                RestaurantDTO(
                    id: "1",
                    name: "Kebapçı Mehmet",
                    address: "Istiklal Caddesi 123",
                    city: "Istanbul",
                    cuisine: "Turkish",
                    rating: 4.7,
                    latitude: 41.0082,
                    longitude: 28.9784,
                    imageURLs: ["https://example.com/image1.jpg"],
                    openingHours: "10:00 - 22:00",
                    phoneNumber: "+90 212 123 4567",
                    priceLevel: 2
                ),
                RestaurantDTO(
                    id: "2",
                    name: "Balık Lokantası",
                    address: "Karaköy 456",
                    city: "Istanbul",
                    cuisine: "Seafood",
                    rating: 4.5,
                    latitude: 41.0222,
                    longitude: 28.9744,
                    imageURLs: ["https://example.com/image2.jpg"],
                    openingHours: "12:00 - 23:00",
                    phoneNumber: "+90 212 456 7890",
                    priceLevel: 3
                )
            ]
            self.isLoading = false
        }
    }
}

struct RestaurantRow: View {
    let restaurant: RestaurantDTO
    
    var body: some View {
        HStack {
            // Placeholder for restaurant image
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Text("Image")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                
                Text(restaurant.cuisine)
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
                ForEach(0..<restaurant.priceLevel, id: \.self) { _ in
                    Text("₺")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 8)
    }
}