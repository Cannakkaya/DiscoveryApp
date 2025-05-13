import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RestaurantListView()
                .tabItem {
                    Label("Restaurants", systemImage: "fork.knife")
                }
                .tag(0)
            
            ExploreMapView()
                .tabItem {
                    Label("Explore", systemImage: "map")
                }
                .tag(1)
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(3)
        }
    }
}