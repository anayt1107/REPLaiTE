import SwiftUI

struct BadgeItem: Identifiable {
    let id: Int
    let name: String
    let achieved: Bool
}

struct StatsData {
    let foodSavedThisWeek: Double
    let foodSavedTotal: Double
    let co2SavedThisWeek: Double
    let co2SavedTotal: Double
    let moneySavedThisWeek: Double
    let moneySavedTotal: Double
    let completedRecipes: Int
    let weeklyProgress: Double
    let badges: [BadgeItem]
}

struct TrackerView: View {
    let stats = StatsData(
        foodSavedThisWeek: 2.3,
        foodSavedTotal: 15.7,
        co2SavedThisWeek: 4.6,
        co2SavedTotal: 31.4,
        moneySavedThisWeek: 18,
        moneySavedTotal: 124,
        completedRecipes: 12,
        weeklyProgress: 68,
        badges: [
            BadgeItem(id: 1, name: "Zero Waste Champion", achieved: true),
            BadgeItem(id: 2, name: "First Recipe Cooked", achieved: true),
            BadgeItem(id: 3, name: "Inventory Master", achieved: true),
            BadgeItem(id: 4, name: "Food Saver", achieved: false),
            BadgeItem(id: 5, name: "Cooking Streak: 7 Days", achieved: false)
        ]
    )

    var body: some View {
        // MARK: - Add NavigationView here
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Summary Cards
                    HStack(spacing: 16) {
                        summaryCard(icon: "fork.knife", value: String(format: "%.1fkg", stats.foodSavedThisWeek), label: "Food Saved This Week", bgColor: .green)
                        summaryCard(icon: "dollarsign.circle", value: "$\(Int(stats.moneySavedThisWeek))", label: "Money Saved This Week", bgColor: .blue)
                    }

                    // Weekly Progress
                    card(title: "Weekly Goal Progress") {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Current Progress")
                                Spacer()
                                Text("\(Int(stats.weeklyProgress))%")
                                    .bold()
                            }
                            ProgressView(value: stats.weeklyProgress, total: 100)
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            Text("You're on track to meet your weekly food waste reduction goal!")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    // Total Impact
                    card(title: "Your Total Impact") {
                        VStack(spacing: 16) {
                            HStack {
                                totalStat(value: String(format: "%.1fkg", stats.foodSavedTotal), label: "Food Saved")
                                totalStat(value: String(format: "%.1fkg", stats.co2SavedTotal), label: "CO₂ Prevented")
                                totalStat(value: "$\(Int(stats.moneySavedTotal))", label: "Money Saved")
                            }

                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Recipes Completed")
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                    Text("\(stats.completedRecipes)")
                                        .font(.subheadline)
                                }
                                ProgressView(value: Double(stats.completedRecipes), total: 20)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
                                    .scaleEffect(x: 1, y: 1.2, anchor: .center)
                            }
                        }
                    }

                    // Achievements
                    card(title: "Your Achievements", icon: "leaf.fill", iconColor: .green) {
                        VStack(spacing: 8) {
                            ForEach(stats.badges) { badge in
                                HStack {
                                    Text(badge.name)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(badge.achieved ? "Achieved" : "In Progress")
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(badge.achieved ? Color.green : Color.gray.opacity(0.3))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }

                            Button(action: {}) {
                                Text("View All Achievements")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    // Monthly Stats Placeholder
                    card(title: "Monthly Stats", icon: "chart.bar.fill", iconColor: .purple) {
                        VStack {
                            Spacer()
                            Text("Chart visualization placeholder")
                                .foregroundColor(.gray)
                                .font(.caption)
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color.black) // Set the overall background to black
            }
            // MARK: - Add navigationTitle here
            .navigationTitle("Food Waste Tracker")
        }
        .background(Color.black.edgesIgnoringSafeArea(.all)) // Ensure full background coverage
    }

    // MARK: - Components

    func summaryCard(icon: String, value: String, label: String, bgColor: Color) -> some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .padding(.bottom, 4)
            Text(value)
                .font(.title2)
                .bold()
            Text(label)
                .font(.caption)
                .opacity(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(bgColor)
        .foregroundColor(.white)
        .cornerRadius(12)
    }

    func card<Content: View>(title: String, icon: String? = nil, iconColor: Color = .primary, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                }
                Text(title)
                    .font(.headline)
            }
            content()
        }
        .padding()
        .background(Color.gray.opacity(0.2)) // Changed from Color.white to dark gray
        .foregroundColor(.white) // Added to make text visible on dark background
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2) // Adjusted shadow for dark mode
    }

    func totalStat(value: String, label: String) -> some View {
        VStack {
            Text(value)
                .font(.headline)
                .bold()
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TrackerView_Previews: PreviewProvider {
    static var previews: some View {
        TrackerView()
    }
}
