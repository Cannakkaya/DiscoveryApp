import SwiftUI

struct FilterOptions {
    var selectedCuisines: Set<String> = []
    var priceRange: ClosedRange<Double> = 1...4
    var minRating: Double = 0.0
    var sortBy: SortOption = .rating
    var maxDistance: Double = 10.0 // km
}

enum SortOption: String, CaseIterable, Identifiable {
    case rating = "Rating"
    case distance = "Distance"
    case priceAsc = "Price: Low to High"
    case priceDesc = "Price: High to Low"
    
    var id: String { self.rawValue }
}

struct SearchFiltersView: View {
    @Binding var isPresented: Bool
    @Binding var filterOptions: FilterOptions
    
    // Local state for the view
    @State private var tempFilterOptions: FilterOptions
    
    // Sample cuisine types
    let cuisineTypes = ["Turkish", "Mediterranean", "Seafood", "Italian", "Asian", "Fast Food", "Vegetarian", "Dessert"]
    
    init(isPresented: Binding<Bool>, filterOptions: Binding<FilterOptions>) {
        self._isPresented = isPresented
        self._filterOptions = filterOptions
        self._tempFilterOptions = State(initialValue: filterOptions.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Cuisine Types
                Section(header: Text("Cuisine Types")) {
                    ForEach(cuisineTypes, id: \.self) { cuisine in
                        Button(action: {
                            if tempFilterOptions.selectedCuisines.contains(cuisine) {
                                tempFilterOptions.selectedCuisines.remove(cuisine)
                            } else {
                                tempFilterOptions.selectedCuisines.insert(cuisine)
                            }
                        }) {
                            HStack {
                                Text(cuisine)
                                Spacer()
                                if tempFilterOptions.selectedCuisines.contains(cuisine) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                // Price Range
                Section(header: Text("Price Range")) {
                    VStack {
                        HStack {
                            ForEach(1...4, id: \.self) { i in
                                if i >= Int(tempFilterOptions.priceRange.lowerBound) && i <= Int(tempFilterOptions.priceRange.upperBound) {
                                    Text(String(repeating: "₺", count: i))
                                        .foregroundColor(.green)
                                } else {
                                    Text(String(repeating: "₺", count: i))
                                        .foregroundColor(.gray)
                                }
                                if i < 4 {
                                    Spacer()
                                }
                            }
                        }
                        
                        RangeSlider(range: $tempFilterOptions.priceRange, bounds: 1...4, step: 1)
                            .frame(height: 30)
                            .padding(.top, 10)
                    }
                }
                
                // Minimum Rating
                Section(header: Text("Minimum Rating")) {
                    VStack {
                        HStack {
                            ForEach(1...5, id: \.self) { i in
                                Image(systemName: i <= Int(tempFilterOptions.minRating) ? "star.fill" : "star")
                                    .foregroundColor(i <= Int(tempFilterOptions.minRating) ? .yellow : .gray)
                                if i < 5 {
                                    Spacer()
                                }
                            }
                        }
                        
                        Slider(value: $tempFilterOptions.minRating, in: 0...5, step: 0.5)
                    }
                }
                
                // Maximum Distance
                Section(header: Text("Maximum Distance")) {
                    VStack {
                        HStack {
                            Text("0 km")
                            Spacer()
                            Text("\(Int(tempFilterOptions.maxDistance)) km")
                            Spacer()
                            Text("50 km")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        Slider(value: $tempFilterOptions.maxDistance, in: 1...50, step: 1)
                    }
                }
                
                // Sort By
                Section(header: Text("Sort By")) {
                    Picker("Sort", selection: $tempFilterOptions.sortBy) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Reset Button
                Section {
                    Button("Reset Filters") {
                        tempFilterOptions = FilterOptions()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Apply") {
                    filterOptions = tempFilterOptions
                    isPresented = false
                }
                .fontWeight(.bold)
            )
        }
    }
}

// Custom Range Slider for price range
struct RangeSlider: View {
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    let step: Double
    
    @State private var lowHandle: Double
    @State private var highHandle: Double
    
    init(range: Binding<ClosedRange<Double>>, bounds: ClosedRange<Double>, step: Double = 1) {
        self._range = range
        self.bounds = bounds
        self.step = step
        
        self._lowHandle = State(initialValue: range.wrappedValue.lowerBound)
        self._highHandle = State(initialValue: range.wrappedValue.upperBound)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)
                
                // Selected Range
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: CGFloat((highHandle - lowHandle) / (bounds.upperBound - bounds.lowerBound)) * geometry.size.width,
                           height: 6)
                    .offset(x: CGFloat((lowHandle - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)) * geometry.size.width)
                
                // Low Handle
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(radius: 2)
                    .offset(x: CGFloat((lowHandle - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)) * geometry.size.width - 12)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = bounds.lowerBound + (bounds.upperBound - bounds.lowerBound) * Double(value.location.x / geometry.size.width)
                                lowHandle = min(max(round(newValue / step) * step, bounds.lowerBound), highHandle - step)
                                range = lowHandle...range.upperBound
                            }
                    )
                
                // High Handle
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(radius: 2)
                    .offset(x: CGFloat((highHandle - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)) * geometry.size.width - 12)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = bounds.lowerBound + (bounds.upperBound - bounds.lowerBound) * Double(value.location.x / geometry.size.width)
                                highHandle = max(min(round(newValue / step) * step, bounds.upperBound), lowHandle + step)
                                range = range.lowerBound...highHandle
                            }
                    )
            }
        }
    }
}