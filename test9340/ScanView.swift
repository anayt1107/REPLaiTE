import SwiftUI
import AVFoundation
import UIKit

import SwiftUI
import AVFoundation
import UIKit

// MARK: - ScanView
struct ScanView: View {
    @StateObject private var camera = CameraModel()
    @State private var isSheetPresented = false

    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()

            VStack {
                Spacer()
                if camera.capturedImage == nil {
                    Button(action: {
                        camera.takePhoto()
                        isSheetPresented = true
                    }) {
                        Circle()
                            .stroke(Color.white, lineWidth: 6)
                        .frame(width: 80, height: 80)
                           
                            
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $isSheetPresented, onDismiss: {
            camera.reset()
        }) {
            Group {
                if let _ = camera.capturedImage {
                    BottomSheet(camera: camera)
                } else {
                    Text("No image captured")
                        .padding()
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            camera.setup()
        }
    }
}

struct BottomSheet: View {
    @ObservedObject var camera: CameraModel

    var body: some View {
        VStack {
            if let dish = camera.detectedDish {
                VStack {
                    Text("Ingredients Detected")
                        .font(.headline)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .center)

                    if dish.ingredients.isEmpty {
                        Text("No ingredients detected.")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(dish.ingredients, id: \.self) { ingredient in
                                    Text(ingredient.capitalizedFirstLetter())
                                        .font(.footnote)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(.primary)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white.opacity(0.8), lineWidth: 1)
                                        )
                                        .cornerRadius(8)
                                }

                                // Add button
                                Button(action: {
                                    // Handle add ingredient action here
                                }) {
                                    Text("+ Add")
                                        .font(.footnote)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(Color.green.opacity(0.8))
                                        .foregroundColor(.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.green, lineWidth: 1)
                                        )
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 40)
                    }

                    if camera.isFetchingRecipe {
                        ProgressView("Fetching Recipes...") // Indicates fetching multiple
                            .padding()
                    } else if let recipes = camera.fullRecipes, !recipes.isEmpty {
                        // Display multiple RecipeCardViews in a scrollable vertical stack
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 15) { // Spacing between each recipe card
                                ForEach(recipes.prefix(5)) { recipe in // Display up to 5 recipes
                                    RecipeCardView(recipe: recipe)
                                        .frame(maxWidth: .infinity) // Makes the card expand horizontally
                                }
                            }
                            .padding(.horizontal) // Padding for the entire collection of cards
                            .padding(.top) // Padding from the detected ingredients section
                        }
                    } else {
                        // This block will execute if no recipes were found after fetching
                        Text("No recipes found based on the detected ingredients.")
                            .foregroundColor(.gray)
                            .padding()
                    }

                    Spacer()
                }
            } else {
                // Initial state when no dish is detected yet
                VStack {
                    Spacer()
                    ProgressView("Analyzing image...")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .onAppear {
                    // Trigger dish detection when the sheet appears and no dish is set
                    if camera.detectedDish == nil, let image = camera.capturedImage {
                        camera.detectDishAndIngredients(image: image)
                    }
                }
            }
        }
    }
}

// MARK: - String Extension for Capitalizing First Letter
fileprivate extension String {
    func capitalizedFirstLetter() -> String {
        prefix(1).capitalized + dropFirst()
    }
}
// MARK: - Camera Model (UPDATED)


// MARK: - Camera Preview


// MARK: - Data Extension
fileprivate extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

// MARK: - Recipe and NutritionalInfo Codable Structs
