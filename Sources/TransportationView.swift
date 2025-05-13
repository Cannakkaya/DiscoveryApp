import SwiftUI

struct TransportationView: View {
    let restaurant: RestaurantDTO
    @State private var selectedTransportType = "All"
    @State private var transportOptions: [TransportOptionDTO] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var userLocation = "Current Location" // In a real app, get from LocationManager
    
    private let transportTypes = ["All", "Bus", "Flight", "Train", "Taxi"]
    
    var filteredOptions: [TransportOptionDTO] {
        if selectedTransportType == "All" {
            return transportOptions
        } else {
            return transportOptions.filter { $0.type.lowercased() == selectedTransportType.lowercased() }
        }
    }
    
    var body: some View {
        VStack {
            // From-To header
            HStack {
                VStack(alignment: .leading) {
                    Text("From")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(userLocation)
                        .font(.headline)
                }
                
                Image(systemName: "arrow.right")
                    .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("To")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(restaurant.name)
                        .font(.headline)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Transport type filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(transportTypes, id: \.self) { type in
                        Button(action: {
                            selectedTransportType = type
                        }) {
                            Text(type)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedTransportType == type ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedTransportType == type ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            if isLoading {
                Spacer()
                ProgressView("Loading transportation options...")
                Spacer()
            } else if let error = errorMessage {
                Spacer()
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                Spacer()
            } else if filteredOptions.isEmpty {
                Spacer()
                Text("No transportation options available")
                    .foregroundColor(.secondary)
                    .padding()
                Spacer()
            } else {
                // Transport options list
                List(filteredOptions) { option in
                    TransportOptionRow(option: option)
                }
            }
        }
        .navigationTitle("Transportation")
        .onAppear {
            loadTransportOptions()
        }
    }
    
    private func loadTransportOptions() {
        isLoading = true
        errorMessage = nil
        
        // For demo purposes, we'll use sample data
        // In a real app, you would call your API service
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            self.transportOptions = [
                TransportOptionDTO(
                    id: "1",
                    type: "Bus",
                    provider: "Istanbul Metro",
                    departureTime: dateFormatter.date(from: "2023-06-15 10:00")!,
                    arrivalTime: dateFormatter.date(from: "2023-06-15 10:45")!,
                    price: 15.0,
                    currency: "TRY",
                    from: userLocation,
                    to: restaurant.name
                ),
                TransportOptionDTO(
                    id: "2",
                    type: "Taxi",
                    provider: "BiTaksi",
                    departureTime: Date(),
                    arrivalTime: Date().addingTimeInterval(1200), // 20 minutes later
                    price: 85.0,
                    currency: "TRY",
                    from: userLocation,
                    to: restaurant.name
                ),
                TransportOptionDTO(
                    id: "3",
                    type: "Train",
                    provider: "Turkish Railways",
                    departureTime: dateFormatter.date(from: "2023-06-15 11:30")!,
                    arrivalTime: dateFormatter.date(from: "2023-06-15 12:15")!,
                    price: 25.0,
                    currency: "TRY",
                    from: userLocation,
                    to: restaurant.name
                )
            ]
            
            self.isLoading = false
        }
    }
}

struct TransportOptionRow: View {
    let option: TransportOptionDTO
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack {
            // Transport type icon
            Image(systemName: iconForTransportType(option.type))
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                // Provider
                Text(option.provider)
                    .font(.headline)
                
                // Times
                HStack {
                    Text(dateFormatter.string(from: option.departureTime))
                    Image(systemName: "arrow.right")
                        .font(.caption)
                    Text(dateFormatter.string(from: option.arrivalTime))
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                // Duration
                Text("Duration: \(formattedDuration(from: option.departureTime, to: option.arrivalTime))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Price
            VStack(alignment: .trailing) {
                Text("\(option.price, specifier: "%.2f") \(option.currency)")
                    .font(.headline)
                
                Button(action: {
                    // Book action
                }) {
                    Text("Book")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func iconForTransportType(_ type: String) -> String {
        switch type.lowercased() {
        case "bus":
            return "bus"
        case "flight":
            return "airplane"
        case "train":
            return "tram"
        case "taxi":
            return "car"
        default:
            return "location"
        }
    }
    
    private func formattedDuration(from start: Date, to end: Date) -> String {
        let duration = end.timeIntervalSince(start)
        let minutes = Int(duration / 60)
        
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours) h \(remainingMinutes) min"
        }
    }
}