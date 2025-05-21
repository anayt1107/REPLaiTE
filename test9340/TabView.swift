import SwiftUI

enum Tab {
    case home
    case tracker
    case scan
    case profile
    case recipes
}

struct ContentView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        VStack(spacing: 0) {
            // Main content
            ZStack {
                switch selectedTab {
                case .home:
                    HomeView()
                case .scan:
                    ScanView()
                case .tracker:
                    TrackerView()
                case .profile:
                    ProfileView()
                case .recipes:
                    RecipesView(recipes: sampleRecipes)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            HStack {
                tabBarItem(icon: "house", label: "Home", tab: .home)
                tabBarItem(icon: "fork.knife", label: "Recipes", tab: .recipes)
                
                tabBarItem(icon: "camera", label: "Scan", tab: .scan)
                tabBarItem(icon: "chart.line.uptrend.xyaxis", label: "Tracker", tab: .tracker)
                tabBarItem(icon: "person.fill", label: "User", tab: .profile)
            }
            .padding(.vertical, 20)
            .background(Color.black)
        }
        .edgesIgnoringSafeArea(.bottom)
    }

    @ViewBuilder
    func tabBarItem(icon: String, label: String, tab: Tab) -> some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(selectedTab == tab ? .white : .gray)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
