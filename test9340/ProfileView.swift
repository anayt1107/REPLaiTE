import SwiftUI

// --- UserProfile and NotificationSettings (Already provided, keeping as is) ---
struct UserProfile {
    var name: String
    var email: String
    var dietaryPreferences: [String]
    var allergies: [String]
    var notifications: NotificationSettings
}

struct NotificationSettings {
    var expiringItems: Bool
    var newRecipes: Bool
    var tips: Bool
    var weeklyReport: Bool
}

// --- CardView2, BadgeView, FlowLayout2, NotificationSettingRow, SettingsItemRow (Already provided, keeping as is) ---
struct CardView2<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct BadgeView: View {
    let text: String
    var style: BadgeStyle = .default

    var body: some View {
        Text(text)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .font(.caption)
            .background(style == .destructive ? Color.red.opacity(0.2) : Color.accentColor.opacity(0.2))
            .foregroundColor(style == .destructive ? .red : .accentColor)
            .cornerRadius(8)
    }

    enum BadgeStyle {
        case `default`, destructive
    }
}

struct FlowLayout2: Layout {
    let alignment: Alignment
    let spacing: CGFloat

    init(alignment: Alignment = .leading, spacing: CGFloat = 0) {
        self.alignment = alignment
        self.spacing = spacing
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var width = CGFloat(0)
        var height = CGFloat(0)
        var currentRowWidth = CGFloat(0)
        var currentRowHeight = CGFloat(0)

        for subview in subviews {
            let size = subview.sizeThatFits(proposal)
            if currentRowWidth + size.width > proposal.width ?? CGFloat.infinity {
                width = max(width, currentRowWidth)
                height += currentRowHeight + spacing
                currentRowWidth = size.width
                currentRowHeight = size.height
            } else {
                currentRowWidth += size.width + spacing
                currentRowHeight = max(currentRowHeight, size.height)
            }
        }
        width = max(width, currentRowWidth)
        height += currentRowHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var currentRowHeight = CGFloat(0)

        for subview in subviews {
            let size = subview.sizeThatFits(proposal)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += currentRowHeight + spacing
                currentRowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: ProposedViewSize(size))
            x += size.width + spacing
            currentRowHeight = max(currentRowHeight, size.height)
        }
    }
}

struct NotificationSettingRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Toggle("", isOn: $isOn)
        }
    }
}

struct SettingsItemRow: View {
    let title: String

    var body: some View {
        Button {
            print("\(title) tapped")
        } label: {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                ChevronRightIcon()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Lucide Icons (Already provided, keeping as is)
struct UserIcon: View { var body: some View { Image(systemName: "person.fill") } }
struct BellIcon: View { var body: some View { Image(systemName: "bell.fill") } }
struct SettingsIcon: View { var body: some View { Image(systemName: "gearshape.fill") } }
struct HeartIcon: View { var body: some View { Image(systemName: "heart.fill") } }
struct FilterIcon: View { var body: some View { Image(systemName: "line.3.horizontal.decrease.circle.fill") } }
struct ChevronRightIcon: View { var body: some View { Image(systemName: "chevron.right") } }

// Custom corner radius for specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// --- Modified ProfileView without ingredient detection ---
struct ProfileView: View {
    // Mock user data (replace with your actual user model)
    @State private var user: UserProfile = UserProfile(
        name: "Jamie Smith",
        email: "jamie@example.com",
        dietaryPreferences: ["Vegetarian", "No Nuts"],
        allergies: ["Peanuts", "Shellfish"],
        notifications: NotificationSettings(
            expiringItems: true,
            newRecipes: true,
            tips: false,
            weeklyReport: true
        )
    )

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // User Info
                    CardView2 {
                        VStack(spacing: 16) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .frame(width: 64, height: 64)
                                        .foregroundColor(Color(.systemGray2))
                                    UserIcon()
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(Color(.systemGray))
                                }
                                .padding(.trailing, 16)

                                VStack(alignment: .leading) {
                                    Text(user.name)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }

                            HStack(spacing: 8) {
                                Button {
                                    print("Edit Profile tapped")
                                } label: {
                                    Text("Edit Profile")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)

                                Button {
                                    print("Account Settings tapped")
                                } label: {
                                    Text("Account Settings")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding()
                    }

                    // Dietary Preferences
                    CardView2 {
                        VStack(alignment: .leading) {
                            HStack {
                                FilterIcon()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color.accentColor)
                                Text("Dietary Preferences")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .padding(.bottom, 8)

                            Text("Diet Type")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.bottom, 2)

                            HStack {
                                FlowLayout2(spacing: 8) {
                                    ForEach(user.dietaryPreferences, id: \.self) { preference in
                                        BadgeView(text: preference)
                                    }
                                    Button {
                                        print("Add dietary preference tapped")
                                    } label: {
                                        Text("+ Add")
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.gray, lineWidth: 1)
                                            )
                                    }
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(.bottom, 8)

                            Text("Allergies & Restrictions")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.bottom, 2)

                            HStack {
                                FlowLayout2(spacing: 8) {
                                    ForEach(user.allergies, id: \.self) { allergy in
                                        BadgeView(text: allergy, style: .destructive)
                                    }
                                    Button {
                                        print("Add allergy tapped")
                                    } label: {
                                        Text("+ Add")
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.gray, lineWidth: 1)
                                            )
                                    }
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(.bottom, 8)
                        }
                        .padding()
                    }

                    // Saved Recipes
                    CardView2 {
                        VStack {
                            HStack {
                                HeartIcon()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color.accentColor)
                                Text("Saved Recipes")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Spacer()
                                Button {
                                    print("View All Saved Recipes tapped")
                                } label: {
                                    HStack {
                                        Text("View All")
                                        ChevronRightIcon()
                                            .frame(width: 16, height: 16)
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.bottom, 8)

                            VStack(alignment: .center, spacing: 8) {
                                Text("You have 3 saved recipes")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 24)
                        }
                        .padding()
                    }

                    // Notification Settings
                    CardView2 {
                        VStack(alignment: .leading) {
                            HStack {
                                BellIcon()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color.accentColor)
                                Text("Notification Settings")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .padding(.bottom, 8)

                            VStack(spacing: 12) {
                                NotificationSettingRow(
                                    title: "Expiring Items Alerts",
                                    description: "Get notified when food is about to expire",
                                    isOn: $user.notifications.expiringItems
                                )
                                NotificationSettingRow(
                                    title: "New Recipe Suggestions",
                                    description: "Personalized recipe ideas based on your inventory",
                                    isOn: $user.notifications.newRecipes
                                )
                                NotificationSettingRow(
                                    title: "Food Waste Tips",
                                    description: "Weekly tips on reducing food waste",
                                    isOn: $user.notifications.tips
                                )
                                NotificationSettingRow(
                                    title: "Weekly Reports",
                                    description: "Summary of your food waste reduction progress",
                                    isOn: $user.notifications.weeklyReport
                                )
                            }
                        }
                        .padding()
                    }

                    // App Settings
                    CardView2 {
                        VStack(alignment: .leading) {
                            HStack {
                                SettingsIcon()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color.secondary)
                                Text("App Settings")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .padding(.bottom, 8)

                            VStack(spacing: 0) {
                                SettingsItemRow(title: "Units (Imperial/Metric)")
                                SettingsItemRow(title: "Language")
                                SettingsItemRow(title: "Theme")
                                SettingsItemRow(title: "Privacy Settings")
                                SettingsItemRow(title: "Help & Support")
                                SettingsItemRow(title: "About Replate")
                            }
                        }
                        .padding()
                    }

                    Button {
                        print("Log Out tapped")
                    } label: {
                        Text("Log Out")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
                .padding()
            }
            .navigationTitle("Your Profile")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
