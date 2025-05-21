import SwiftUI
import Foundation // Needed for URL
import _PhotosUI_SwiftUI // Required for AsyncImage when using remote URLs (implicitly, if you're not seeing errors for it directly, it might be pulled in by another module or just implicit)
struct Item: Identifiable { // RE-INCLUDED: Used by HomeView.expiringItems
    let id: Int
    let name: String
    let daysLeft: Int
}


struct NutritionalInfo: Codable, Hashable {
    let calories: String
    let protein: String
    let carbs: String
    let fat: String
}

// Recipe Struct
struct Recipe: Decodable, Identifiable{
    let id: Int
    let name: String
    let ingredients: [String]
    let time: String
    var image: RecipeImageSource
    var nutritionalInfo: NutritionalInfo? = nil
    var steps: [String]? = nil
    var tags: [String] = [] // This is a non-optional array with a default value
    enum RecipeImageSource{
        case asset(String)
        case remote(URL)
    }


    // Custom initializer for decoding from JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        ingredients = try container.decode([String].self, forKey: .ingredients)
        time = try container.decode(String.self, forKey: .time)
        steps = try container.decodeIfPresent([String].self, forKey: .steps)
        // FIXED: Safely unwrap 'tags' or provide a default empty array
        tags = (try container.decodeIfPresent([String].self, forKey: .tags)) ?? []
        nutritionalInfo = try container.decodeIfPresent(NutritionalInfo.self, forKey: .nutritionalInfo)

        let imageString = try container.decode(String.self, forKey: .image)
        if let url = URL(string: imageString), url.scheme != nil, url.host != nil {
            self.image = .remote(url)
        } else {
            self.image = .asset(imageString)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, name, ingredients, time, image, steps, tags, nutritionalInfo
    }

    // This initializer is for manually creating Recipe instances (like in your Previews)
    init(id: Int, name: String, ingredients: [String], time: String, image: RecipeImageSource, steps: [String]? = nil, tags: [String]? = nil, nutritionalInfo: NutritionalInfo? = nil) {
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.time = time
        self.image = image
        self.steps = steps
        // FIXED: Ensure tags is non-optional for manual init
        self.tags = tags ?? [] // Provide default empty array if nil is passed
        self.nutritionalInfo = nutritionalInfo
    }
}



// Sample Recipes Data
let sampleRecipes: [Recipe] = [
    Recipe(
        id: 1,
        name: "Spinach & Tomato Pasta",
        ingredients: ["Spinach", "Tomatoes", "Pasta", "Olive Oil", "Garlic"],
        time: "20 min",
        image: .asset("spinach_tomato_pasta"),
        steps: [ // Argument order is now consistent with init
            "Bring a pot of salted water to a boil.",
            "Cook the pasta according to package instructions, until al dente.",
            "Heat a large skillet over medium heat with olive oil.",
            "Sauté minced garlic until fragrant, about 30 seconds.",
            "Add diced tomatoes and cook for 5-7 minutes until they break down.",
            "Stir in the spinach until wilted, about 2 minutes.",
            "Toss the drained pasta into the skillet with the sauce.",
            "Serve immediately, topped with Parmesan cheese and a drizzle of olive oil."
        ],
        tags: ["Vegetarian", "Quick", "Low-Calorie"], // Argument order is now consistent with init
        nutritionalInfo: NutritionalInfo(calories: "350 kcal", protein: "15g", carbs: "40g", fat: "12g")
    ),
    Recipe(
        id: 2,
        name: "Egg & Veggie Breakfast Bowl",
        ingredients: ["Eggs", "Spinach", "Tomatoes", "Bell Pepper", "Onion"],
        time: "15 min",
        image: .asset("egg-veggie"),
        steps: [ // Argument order is now consistent with init
            "Preheat a skillet over medium heat with olive oil.",
            "Sauté diced onion and bell pepper until softened.",
            "Add tomatoes and spinach, cooking until wilted.",
            "Crack the eggs directly into the pan.",
            "Scramble everything together until the eggs are fully set.",
            "Season with salt and pepper to taste.",
            "Serve in a bowl with your favorite hot sauce.",
            "Garnish with fresh herbs if desired."
        ],
        tags: ["Breakfast", "High-Protein", "Low-Carb"], // Argument order is now consistent with init
        nutritionalInfo: nil
    ),
    Recipe(
        id: 3,
        name: "Chicken & Apple Salad",
        ingredients: ["Chicken Breast", "Apples", "Mixed Greens", "Feta Cheese", "Walnuts"],
        time: "25 min",
        image: .asset("IMG_6494"),
        steps: [ // Argument order is now consistent with init
            "Grill the chicken breast until fully cooked, then slice.",
            "Slice the apple into thin wedges.",
            "Combine mixed greens, apple slices, feta, and walnuts in a large bowl.",
            "Add the sliced chicken to the salad.",
            "Drizzle with your favorite vinaigrette.",
            "Toss to combine everything evenly.",
            "Serve immediately or chill for a refreshing cold salad.",
            "Top with extra nuts or cheese if desired."
        ],
        tags: ["High-Protein", "Low-Carb", "Salad"], // Argument order is now consistent with init
        nutritionalInfo: nil
    ),
    Recipe(
        id: 4,
        name: "Veggie Stir-Fry",
        ingredients: ["Bell Peppers", "Broccoli", "Carrots", "Soy Sauce", "Rice"],
        time: "25 min",
        image: .asset("IMG_5737"),
        steps: [ // Argument order is now consistent with init
            "Cook the rice according to package instructions.",
            "Heat a wok or large skillet over high heat.",
            "Add oil and then add sliced vegetables.",
            "Stir-fry for 5-7 minutes until the veggies are crisp-tender.",
            "Add soy sauce and a splash of water.",
            "Toss everything together to coat the veggies in the sauce.",
            "Serve the stir-fried veggies over the cooked rice.",
            "Garnish with sesame seeds or green onions if desired."
        ],
        tags: ["Vegan", "Quick", "High-Fiber"], // Argument order is now consistent with init
        nutritionalInfo: nil
    )
]
// Sample Recipes Data


struct Tip: Identifiable {
    let id: Int
    let title: String
    let excerpt: String
    let image: String // Assuming Tip images are always asset names for now
}

// MARK: - Recipe Preview View (Fixed)
struct RecipePreviewView: View {
    @Environment(\.colorScheme) var colorScheme
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // FIXED: Use switch statement for recipe.image
            switch recipe.image {
            case .asset(let imageName):
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .cornerRadius(8)
            case .remote(let imageURL):
                AsyncImage(url: imageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .cornerRadius(8)
                    } else if phase.error != nil {
                        Image(systemName: "photo.fill") // Fallback for error
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                            .cornerRadius(8)
                    } else {
                        ProgressView() // Loading indicator
                            .frame(width: 120, height: 120)
                            .cornerRadius(8)
                    }
                }
            }
            Text(recipe.name)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .lineLimit(2)
            Text(recipe.ingredients.prefix(3).joined(separator: ", ") + (recipe.ingredients.count > 3 ? "..." : ""))
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(1)
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(recipe.time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 120)
    }
}

// MARK: - HomeView and its Subviews

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme

    let expiringItems: [Item] = [
           Item(id: 1, name: "Spinach", daysLeft: 2),
           Item(id: 2, name: "Milk", daysLeft: 3),
           Item(id: 3, name: "Tomatoes", daysLeft: 1),
           Item(id: 4, name: "Eggs", daysLeft: 5),
           Item(id: 5, name: "Cheese", daysLeft: 1)
       ]


    let recommendedRecipes: [Recipe] = sampleRecipes

    let wasteTips: [Tip] = [
        Tip(id: 1, title: "Storing Leafy Greens", excerpt: "Keep your spinach and lettuce fresh for longer...", image: "greens"),
        Tip(id: 2, title: "Use Those Leftovers", excerpt: "Creative ways to reinvent yesterday's meal...", image: "leftovers"),
        Tip(id: 3, title: "Freeze Your Bread", excerpt: "Prevent bread from going stale by freezing it...", image: "bread"),
        Tip(id: 4, title: "Herb Storage Tricks", excerpt: "Extend the life of your fresh herbs...", image: "placeholder")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Actions
                    HStack(spacing: 12) {
                        NavigationLink(destination: ScannerView()) {
                            ActionButton(iconName: "camera", title: "Scan Fridge", style: .primary)
                        }
                        NavigationLink(destination: RecipesView(recipes: sampleRecipes)) {
                            ActionButton(iconName: "fork.knife", title: "Find Recipes", style: .secondary)
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)

                    // Expiring Soon
                    CardView2 {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Label(
                                    "Expiring Soon",
                                    systemImage: "clock"
                                )
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                Spacer()
                            }
                            VStack(spacing: 8) {
                                ForEach(expiringItems) { item in
                                    HStack {
                                        Text(item.name)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                        Spacer()
                                        Text("\(item.daysLeft) \(item.daysLeft == 1 ? "day" : "days") left")
                                            .font(.subheadline)
                                            .foregroundColor(item.daysLeft <= 1 ? .red : .orange)
                                    }
                                    .padding(.vertical, 4)
                                    .background(Color(.secondarySystemBackground).opacity(0.5))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(16)
                    }
                    .padding(.horizontal)

                    // Recommended Recipes - Horizontal Scroll
                    CardView2 {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Label(
                                    "Recommended Recipes",
                                    systemImage: "star.fill"
                                )
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                Spacer()
                                NavigationLink(destination: RecipesView(recipes: recommendedRecipes)) {
                                    HStack {
                                        Text("See All")
                                        Image(systemName: "chevron.right")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.accentColor)
                                }
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(recommendedRecipes) { recipe in
                                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                            RecipePreviewView(recipe: recipe)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(16)
                    }
                    .padding(.horizontal)

                    // Food Waste Tips - Horizontal Scroll
                    CardView2 {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Label(
                                    "Food Waste Tips",
                                    systemImage: "book.fill"
                                )
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                Spacer()
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(wasteTips) { tip in
                                        NavigationLink(destination: TipDetailView(tip: tip)) {
                                            VStack(alignment: .leading, spacing: 10) {
                                                Image(tip.image)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 160, height: 90)
                                                    .cornerRadius(8)
                                                Text(tip.title)
                                                    .font(.headline)
                                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                                    .lineLimit(2)
                                                Text(tip.excerpt)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                    .lineLimit(2)
                                            }
                                            .frame(width: 160)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(16)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .navigationTitle("Home")
            .toolbar {
                NavigationLink(destination: NotificationsView()) {
                    Image(systemName: "bell")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Subviews (These are not declared elsewhere in your project, so they remain)

enum ButtonStyleType {
    case primary, secondary
}

struct ActionButton: View {
    @Environment(\.colorScheme) var colorScheme
    let iconName: String
    let title: String
    let style: ButtonStyleType

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.white)
            Text(title)
                .lineLimit(1)
                .foregroundColor(.white)
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(style == .primary ? Color.blue : Color.green)
        .cornerRadius(10)
        .font(.headline)
        .padding(.horizontal, 8)
    }
}

struct NotificationsView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Text("No New Notifications")
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .background(Color(.systemBackground))
    }
}

struct ScannerView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Text("Scanner")
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .background(Color(.systemBackground))
    }
}

struct WrappingHStack: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    init(horizontalSpacing: CGFloat = 8, verticalSpacing: CGFloat = 8) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let idealWidth = proposal.width ?? 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)

            if currentX + subviewSize.width > idealWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + verticalSpacing
                totalHeight = currentY
                lineHeight = 0
            }

            currentX += subviewSize.width
            lineHeight = max(lineHeight, subviewSize.height)

            if subview != subviews.last {
                currentX += horizontalSpacing
            }
        }
        totalHeight += lineHeight
        return CGSize(width: idealWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)

            if currentX + subviewSize.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += lineHeight + verticalSpacing
                lineHeight = 0
            }

            subview.place(at: CGPoint(x: currentX, y: currentY), anchor: .topLeading, proposal: .unspecified)

            currentX += subviewSize.width
            lineHeight = max(lineHeight, subviewSize.height)

            if subview != subviews.last {
                currentX += horizontalSpacing
            }
        }
    }
}

struct TipDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    let tip: Tip

    var body: some View {
        Text("Details for \(tip.title)")
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .background(Color(.systemBackground))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
                .preferredColorScheme(.light)

            HomeView()
                .preferredColorScheme(.dark)
        }
    }
}
