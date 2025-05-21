import SwiftUI
import Foundation // Needed for URL
import _PhotosUI_SwiftUI // Required for AsyncImage when using remote URLs

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.dismiss) var dismiss
    @State private var isFavorite: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header Image with dismiss button
                ZStack(alignment: .topLeading) {
                    // FIXED: Use switch statement for recipe.image to handle asset vs remote
                    switch recipe.image {
                    case .asset(let imageName):
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 192)
                            .clipped()
                    case .remote(let imageURL):
                        AsyncImage(url: imageURL) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 192)
                                    .clipped()
                            } else if phase.error != nil {
                                Color.gray // Placeholder for error
                                    .frame(height: 192)
                                    .overlay(
                                        Image(systemName: "photo.fill")
                                            .foregroundColor(.white)
                                            .font(.largeTitle)
                                    )
                            } else {
                                ProgressView() // Loading indicator
                                    .frame(height: 192)
                                    .frame(maxWidth: .infinity) // Ensure it takes full width
                                    .background(Color.gray.opacity(0.2))
                            }
                        }
                        .clipped() // Clip content if it overflows the frame
                    }

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                            .padding(8)
                    }
                }

                // Recipe Header: name, time, tags, actions
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .foregroundColor(.gray)
                        Text(recipe.time)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    if !recipe.tags.isEmpty {
                        // Using WrappingHStack from HomeView (assuming it's accessible or defined here)
                        // If WrappingHStack is in a separate file, ensure it's imported or defined.
                        WrappingHStack(horizontalSpacing: 8, verticalSpacing: 4) {
                            ForEach(recipe.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.secondary.opacity(0.3))
                                    .foregroundColor(.primary)
                                    .cornerRadius(8)
                            }
                        }
                    }

                    HStack(spacing: 16) {
                        Button {
                            isFavorite.toggle()
                            let feedback = isFavorite ? "Added to favorites" : "Removed from favorites"
                            print(feedback)
                        } label: {
                            HStack {
                                Image(systemName: isFavorite ? "star.fill" : "star")
                                Text(isFavorite ? "Saved" : "Save Recipe")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isFavorite ? Color.accentColor : Color.gray.opacity(0.2))
                            .foregroundColor(isFavorite ? .white : .primary)
                            .cornerRadius(8)
                        }

                        Button {
                            print("Marked as cooked!")
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Mark as Cooked")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)

                // Ingredients
                CardView { // Assuming CardView is defined elsewhere
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .foregroundColor(.accentColor)
                            Text("Ingredients")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .padding(.bottom, 8)

                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            Text("• \(ingredient)")
                                .font(.body)
                                .padding(.bottom, 2)
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)

                // Cooking Steps
                if let steps = recipe.steps, !steps.isEmpty {
                    CardView { // Assuming CardView is defined elsewhere
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "number.circle.fill")
                                    .foregroundColor(.accentColor)
                                Text("Cooking Instructions")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .padding(.bottom, 8)

                            ForEach(steps.indices, id: \.self) { index in
                                VStack(alignment: .leading) {
                                    Text("Step \(index + 1)")
                                        .font(.title3)
                                        .padding(.bottom, 4)
                                    Text(steps[index])
                                        .font(.body)
                                }
                                .padding(.bottom, 8)
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                }

                // Nutritional Info
                if let nutritionalInfo = recipe.nutritionalInfo {
                    CardView { // Assuming CardView is defined elsewhere
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.accentColor)
                                Text("Nutritional Information")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .padding(.bottom, 8)

                            Text("Calories: \(nutritionalInfo.calories)")
                                .font(.body)
                            Text("Protein: \(nutritionalInfo.protein)")
                                .font(.body)
                            Text("Carbs: \(nutritionalInfo.carbs)")
                                .font(.body)
                            Text("Fat: \(nutritionalInfo.fat)")
                                .font(.body)
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
        .navigationBarHidden(true) // Hide the default navigation bar to use custom dismiss button
    }
}

// MARK: - Previews (Add a preview for RecipeDetailView)
struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // You can use one of your sample recipes for the preview
        RecipeDetailView(recipe: sampleRecipes[0])
            .previewDisplayName("Pasta Recipe Detail")
        
        RecipeDetailView(recipe: sampleRecipes[2])
            .previewDisplayName("Remote Image Recipe Detail")

        // Example for dark mode
        RecipeDetailView(recipe: sampleRecipes[0])
            .preferredColorScheme(.dark)
            .previewDisplayName("Pasta Recipe Detail (Dark)")
    }
}

// Ensure you have these structs defined and accessible, either in this file or imported from elsewhere.
// If you're compiling this file alone, you'll need them here.
// Assuming these are from your HomeView.swift or a shared file:

/*
// RE-INCLUDING necessary structs if they are not globally accessible or in a shared framework
// If these are defined in a separate file (e.g., Models.swift) and imported, you can remove them from here.
struct NutritionalInfo: Codable, Hashable {
    let calories: String
    let protein: String
    let carbs: String
    let fat: String
}

struct Recipe: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let ingredients: [String]
    let time: String
    let image: RecipeImageSource
    var nutritionalInfo: NutritionalInfo? = nil
    var steps: [String]? = nil
    var tags: [String] = []

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        ingredients = try container.decode([String].self, forKey: .ingredients)
        time = try container.decode(String.self, forKey: .time)
        steps = try container.decodeIfPresent([String].self, forKey: .steps)
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

    init(id: Int, name: String, ingredients: [String], time: String, image: RecipeImageSource, steps: [String]? = nil, tags: [String]? = nil, nutritionalInfo: NutritionalInfo? = nil) {
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.time = time
        self.image = image
        self.steps = steps
        self.tags = tags ?? []
        self.nutritionalInfo = nutritionalInfo
    }
}

enum RecipeImageSource: Hashable, Codable {
    case asset(String)
    case remote(URL)
}

// Sample Recipes Data (if not in a globally accessible file)
let sampleRecipes: [Recipe] = [
    Recipe(
        id: 1,
        name: "Spinach & Tomato Pasta",
        ingredients: ["Spinach", "Tomatoes", "Pasta", "Olive Oil", "Garlic"],
        time: "20 min",
        image: .asset("spinach_tomato_pasta"),
        steps: [
            "Bring a pot of salted water to a boil.",
            "Cook the pasta according to package instructions, until al dente.",
            "Heat a large skillet over medium heat with olive oil.",
            "Sauté minced garlic until fragrant, about 30 seconds.",
            "Add diced tomatoes and cook for 5-7 minutes until they break down.",
            "Stir in the spinach until wilted, about 2 minutes.",
            "Toss the drained pasta into the skillet with the sauce.",
            "Serve immediately, topped with Parmesan cheese and a drizzle of olive oil."
        ],
        tags: ["Vegetarian", "Quick", "Low-Calorie"],
        nutritionalInfo: NutritionalInfo(calories: "350 kcal", protein: "15g", carbs: "40g", fat: "12g")
    ),
    Recipe(
        id: 2,
        name: "Egg & Veggie Breakfast Bowl",
        ingredients: ["Eggs", "Spinach", "Tomatoes", "Bell Pepper", "Onion"],
        time: "15 min",
        image: .asset("placeholder"),
        steps: [
            "Preheat a skillet over medium heat with olive oil.",
            "Sauté diced onion and bell pepper until softened.",
            "Add tomatoes and spinach, cooking until wilted.",
            "Crack the eggs directly into the pan.",
            "Scramble everything together until the eggs are fully set.",
            "Season with salt and pepper to taste.",
            "Serve in a bowl with your favorite hot sauce.",
            "Garnish with fresh herbs if desired."
        ],
        tags: ["Breakfast", "High-Protein", "Low-Carb"],
        nutritionalInfo: nil
    ),
    Recipe(
        id: 3,
        name: "Chicken & Apple Salad",
        ingredients: ["Chicken Breast", "Apples", "Mixed Greens", "Feta Cheese", "Walnuts"],
        time: "25 min",
        image: .remote(URL(string: "https://images.unsplash.com/photo-1512621776951-a5796248cad4?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")!),
        steps: [
            "Grill the chicken breast until fully cooked, then slice.",
            "Slice the apple into thin wedges.",
            "Combine mixed greens, apple slices, feta, and walnuts in a large bowl.",
            "Add the sliced chicken to the salad.",
            "Drizzle with your favorite vinaigrette.",
            "Toss to combine everything evenly.",
            "Serve immediately or chill for a refreshing cold salad.",
            "Top with extra nuts or cheese if desired."
        ],
        tags: ["High-Protein", "Low-Carb", "Salad"],
        nutritionalInfo: nil
    ),
    Recipe(
        id: 4,
        name: "Veggie Stir-Fry",
        ingredients: ["Bell Peppers", "Broccoli", "Carrots", "Soy Sauce", "Rice"],
        time: "25 min",
        image: .asset("placeholder"),
        steps: [
            "Cook the rice according to package instructions.",
            "Heat a wok or large skillet over high heat.",
            "Add oil and then add sliced vegetables.",
            "Stir-fry for 5-7 minutes until the veggies are crisp-tender.",
            "Add soy sauce and a splash of water.",
            "Toss everything together to coat the veggies in the sauce.",
            "Serve the stir-fried veggies over the cooked rice.",
            "Garnish with sesame seeds or green onions if desired."
        ],
        tags: ["Vegan", "Quick", "High-Fiber"],
        nutritionalInfo: nil
    )
]

// CardView definition (assuming it's used and not defined elsewhere)
struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            content
        }
        .background(Color(.systemBackground)) // Or use a custom card background color
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


// WrappingHStack (If not accessible from HomeView.swift or a separate shared file)
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
*/
