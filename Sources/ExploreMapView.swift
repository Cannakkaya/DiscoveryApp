import SwiftUI
import MapKit

struct ExploreMapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var restaurants: [RestaurantDTO] = []
    @State private var selectedRestaurant: RestaurantDTO?
    @State private var showingDetail = false
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784), // Istanbul
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: restaurants) { restaurant in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)) {
                    Button(action: {
                        selectedRestaurant = restaurant
                        showingDetail = true
                    }) {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 44, height: 44)
                                    .shadow(radius: 2)
                                
                                Image(systemName: "fork.knife")
                                    .foregroundColor(.blue)
                            }
                            
                            Text(restaurant.name)
                                .font(.caption)
                                .padding(4)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(4)
                                .shadow(radius: 1)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            // User location button
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        if let location = locationManager.location {
                            region = MKCoordinateRegion(
                                center: location.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .padding()
                }
                
                Spacer()
            }
            
            // Restaurant quick view
            if let restaurant = selectedRestaurant {
                RestaurantMapCard(restaurant: restaurant, isShowing: $showingDetail)
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: showingDetail)
            }
        }
        .onAppear {
            loadRestaurants()
            
            // Center map on user's location if available
            if let location = locationManager.location {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        }
    }
    
    private func loadRestaurants() {
        // For demo purposes, we'll use sample data
        // In a real app, you would call your API service
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
            ),
            // Add more restaurants as needed
        ]
    }
}

struct RestaurantMapCard: View {
    let restaurant: RestaurantDTO
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle to drag the card
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .cornerRadius(2.5)
                .padding(.top, 10)
                .padding(.bottom, 10)
            
            HStack(spacing: 15) {
                // Restaurant image
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
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
                    
                    Text(restaurant.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            HStack(spacing: 10) {
                Button(action: {
                    // Navigate to detail
                }) {
                    Text("Details")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    // Navigate to transportation options
                }) {
                    Text("Directions")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}