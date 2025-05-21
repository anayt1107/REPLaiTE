import SwiftUI

// Placeholder for Recipe struct
// You should define your Recipe struct here if it's not already defined elsewhere


struct RecipesView: View {
    @State private var searchQuery: String = ""
    @State private var filterOpen: Bool = false
    let recipes: [Recipe] // Receive the sampleRecipes array

    var filteredRecipes: [Recipe] {
        if searchQuery.isEmpty {
            return recipes
        } else {
            return recipes.filter { recipe in
                recipe.name.localizedCaseInsensitiveContains(searchQuery) ||
                recipe.ingredients.contains { $0.localizedCaseInsensitiveContains(searchQuery) }
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                AppHeaderView(title: "Recipe Suggestions")

                // Search Bar
                HStack(spacing: 8) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search recipes or ingredients...", text: $searchQuery)
                    }
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                    Button {
                        filterOpen.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title3)
                            .foregroundColor(filterOpen ? .accentColor : .primary)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)

                // Filters
                if filterOpen {
                    CardView {
                        VStack(spacing: 16) {
                            FilterSection(title: "Cook Time", options: ["< 15 min", "< 30 min", "< 60 min"])
                            FilterSection(title: "Diet", options: ["Vegetarian", "Vegan", "Gluten-Free", "Dairy-Free"])
                            FilterSection(title: "Tags", options: ["Quick", "Zero Waste", "Easy", "High Protein", "5 Ingredients"])

                            HStack(spacing: 8) {
                                Button("Clear All") {
                                    // Implement clear all filters logic
                                }
                                .buttonStyle(.bordered)
                                .frame(maxWidth: .infinity)

                                Button("Apply Filters") {
                                    filterOpen = false
                                    // Implement apply filters logic
                                }
                                .buttonStyle(.borderedProminent)
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding() // Padding inside the CardView content
                    }
                    .frame(maxWidth: .infinity) // Ensure CardView takes full width
                    .padding(.horizontal) // Padding for the CardView itself
                }

                // Recipe Cards
                ScrollView {
                    VStack(spacing: 16) {
                        if filteredRecipes.isEmpty {
                            Text("No recipes match your search criteria.")
                                .foregroundColor(.gray)
                                .padding(.vertical, 40)
                        } else {
                            ForEach(filteredRecipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    RecipeCardView(recipe: recipe)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom) // Add some padding at the end of the scroll view
                }
            }
            .navigationBarHidden(true) // Hide the default navigation bar
        }
    }
}

// MARK: - Subviews

struct AppHeaderView: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            // You might add other header elements here in the future
        }
        .padding()
        .padding(.top, 10) // Adjust top padding for status bar
    }
}

struct CardView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(radius: 2)
    }
}

struct FilterSection: View {
    let title: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.bottom, 4)
            FlowLayout(alignment: .leading, spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        // Implement filter selection logic
                        print("Selected: \(option)")
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Ensure FilterSection takes full width
    }
}

struct FlowLayout: Layout {
    let alignment: Alignment
    let spacing: CGFloat

    struct Cache {
        var lineInfo: [(width: CGFloat, height: CGFloat, startIndex: Int, endIndex: Int)] = []
    }

    init(alignment: Alignment = .leading, spacing: CGFloat = 0) {
        self.alignment = alignment
        self.spacing = spacing
    }

    func makeCache(subviews: Subviews) -> Cache {
        Cache()
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        var lineStartIndex = 0

        cache.lineInfo.removeAll() // Clear cache on each pass

        for (index, subview) in subviews.enumerated() {
            let subviewSize = subview.sizeThatFits(proposal)

            // Check if adding this subview exceeds the container width
            // and if it's not the very first subview on a new line
            if currentX + subviewSize.width > containerWidth && currentX > 0 {
                // New line
                cache.lineInfo.append((width: currentX - spacing, height: currentRowHeight, startIndex: lineStartIndex, endIndex: index - 1))
                currentX = 0
                currentY += currentRowHeight + spacing
                currentRowHeight = 0
                lineStartIndex = index
            }

            currentX += subviewSize.width + spacing
            currentRowHeight = max(currentRowHeight, subviewSize.height)
        }

        // Add the last line if there are any subviews
        if !subviews.isEmpty {
            cache.lineInfo.append((width: currentX - spacing, height: currentRowHeight, startIndex: lineStartIndex, endIndex: subviews.count - 1))
            currentY += currentRowHeight // Add height of the last row
        }

        let totalWidth = cache.lineInfo.map { $0.width }.max() ?? 0
        return CGSize(width: totalWidth, height: currentY)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        var currentY = bounds.minY

        for line in cache.lineInfo {
            var currentX = bounds.minX
            // Adjust starting X based on alignment for the current line
            if alignment == .center {
                currentX += (bounds.width - line.width) / 2
            } else if alignment == .trailing {
                currentX += (bounds.width - line.width)
            }

            for index in line.startIndex...line.endIndex {
                let subview = subviews[index]
                let subviewSize = subview.sizeThatFits(proposal)
                subview.place(at: CGPoint(x: currentX, y: currentY), anchor: .topLeading, proposal: proposal)
                currentX += subviewSize.width + spacing
            }
            currentY += line.height + spacing
        }
    }
}

struct RecipeCardView: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) { // Use VStack for sequential layout
            // Image Section
            imageView(for: recipe.image)
                .frame(height: 120) // Consistent height for card images
                .frame(maxWidth: .infinity) // Use .infinity for max width
                .cornerRadius(8)
                .clipped()

            // Content Section
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    Text(recipe.time)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Ingredients:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(recipe.ingredients.joined(separator: ", "))
                        .font(.footnote)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 12) // Add horizontal padding for text content
            .padding(.bottom, 12) // Add bottom padding for text content
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 2)
    }

    @ViewBuilder
    private func imageView(for image: Recipe.RecipeImageSource) -> some View {
        switch image {
        case .asset(let imageName):
            Image(imageName)
                .resizable()
                .scaledToFill()
        case .remote(let imageURL):
            AsyncImage(url: imageURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    Color.gray // Placeholder for error
                        .overlay(
                            Image(systemName: "photo.fill")
                                .foregroundColor(.white)
                                .font(.title)
                        )
                } else {
                    ProgressView() // Loading indicator
                        .background(Color.gray.opacity(0.2))
                }
            }
        }
    }
}


struct RecipesView_Previews: PreviewProvider {
    static var previews: some View {
        // You'll need to provide the sampleRecipes array for the preview
        let sampleRecipes: [Recipe] = [
            Recipe(
                id: 1,
                name: "Spinach & Tomato Pasta with Garlic and Parmesan",
                ingredients: ["Spinach", "Tomatoes", "Pasta", "Garlic", "Parmesan Cheese", "Olive Oil"],
                time: "20 min",
                image: .asset("placeholder")
            ),
            Recipe(
                id: 2,
                name: "Hearty Egg & Veggie Breakfast Bowl",
                ingredients: ["Eggs", "Spinach", "Tomatoes", "Bell Peppers", "Onion", "Avocado"],
                time: "15 min",
                image: .asset("placeholder")
            ),
            Recipe(
                id: 3,
                name: "Chicken Stir-fry with Broccoli and Carrots",
                ingredients: ["Chicken Breast", "Broccoli", "Carrots", "Soy Sauce", "Ginger", "Rice"],
                time: "30 min",
                image: .remote(URL(string: "https://placehold.co/600x400/000000/FFFFFF?text=Chicken+Stir-fry")!) // Example remote image URL
            )
        ]
        return RecipesView(recipes: sampleRecipes)
    }
}
