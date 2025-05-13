import SwiftUI
import MapKit

struct RestaurantDetailView: View {
    let restaurant: RestaurantDTO
    @State private var region: MKCoordinateRegion
    
    init(restaurant: RestaurantDTO) {
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
                // Restaurant image (placeholder)
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        Text("Restaurant Image")
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    // Restaurant name and rating
                    HStack {
                        Text(restaurant.name)
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
                        Text(restaurant.cuisine)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            ForEach(0..<restaurant.priceLevel, id: \.self) { _ in
                                Text("₺")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Address and contact info
                    VStack(alignment: .leading, spacing: 8) {
                        Label(restaurant.address, systemImage: "mappin.and.ellipse")
                        Label(restaurant.phoneNumber, systemImage: "phone")
                        Label(restaurant.openingHours, systemImage: "clock")
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
                    Button(action: {
                        // This would navigate to transportation options
                    }) {
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Add to favorites
                }) {
                    Image(systemName: "heart")
                }
            }
        }
    }
}