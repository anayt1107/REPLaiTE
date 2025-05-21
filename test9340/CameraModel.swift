import SwiftUI
import AVFoundation
import UIKit



final class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()

    @Published var capturedImage: UIImage?
    @Published var detectedDish: DetectedDish?
    @Published var generatedRecipeNames: [String]?
    @Published var fullRecipes: [Recipe]?
    @Published var isFetchingRecipe: Bool = false

    private let logMealApiToken = "eaecd40e9797351f898e680fc45adc571725fc78"
    private let geminiApiKey = "AIzaSyBbhukx8tmzSg1QJ5UvVlek_MqqjIXvMq4"
    private let imageSearchService = SerpAPIService()

    func setup() {
        print("Setting up camera session...")
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("Failed to get camera input.")
            return
        }

        session.beginConfiguration()
        session.addInput(input)
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        session.commitConfiguration()
        session.startRunning()
        print("Camera session started.")
    }

    func takePhoto() {
        print("Taking photo...")
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            print("Failed to get image data from photo.")
            return
        }

        DispatchQueue.main.async {
            self.capturedImage = image
            self.session.stopRunning()
            print("Photo captured and session stopped.")
        }
    }

    func detectDishAndIngredients(image: UIImage) {
        print("Starting dish and ingredient detection...")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert UIImage to JPEG data.")
            return
        }

        let url = URL(string: "https://api.logmeal.com/v2/image/segmentation/complete")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(logMealApiToken)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"photo.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("LogMeal API error: \(error)")
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    self.detectedDish = DetectedDish(name: nil, ingredients: ["No response from LogMeal"])
                    print("No data received from LogMeal.")
                }
                return
            }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let results = jsonObject?["segmentation_results"] as? [[String: Any]] else {
                    DispatchQueue.main.async {
                        self.detectedDish = DetectedDish(name: nil, ingredients: ["Invalid LogMeal response"])
                        print("Invalid LogMeal response format.")
                    }
                    return
                }

                var ingredients: [String] = []
                for segment in results {
                    let recogResults = segment["recognition_results"] as? [[String: Any]] ?? []
                    for result in recogResults {
                        let foodType = (result["foodType"] as? [String: Any])?["name"] as? String
                        let name = result["name"] as? String
                        if foodType == "ingredients", let name = name {
                            ingredients.append(name)
                        }
                    }
                }

                let uniqueIngredients = Array(Set(ingredients))
                DispatchQueue.main.async {
                    self.detectedDish = DetectedDish(name: nil, ingredients: uniqueIngredients)
                    print("Detected ingredients: \(uniqueIngredients)")
                    if !uniqueIngredients.isEmpty {
                        self.fetchFullRecipes(from: uniqueIngredients)
                    } else {
                        self.generatedRecipeNames = ["No ingredients to suggest recipes."]
                        print("No ingredients found for recipe generation.")
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    self.detectedDish = DetectedDish(name: nil, ingredients: ["JSON parse error"])
                    print("JSON parsing error: \(error)")
                }
            }
        }.resume()
    }

    func fetchFullRecipes(from ingredients: [String]) {
        print("Fetching multiple full recipes for ingredients: \(ingredients)")
        guard !ingredients.isEmpty else {
            DispatchQueue.main.async {
                self.fullRecipes = []
                self.isFetchingRecipe = false
                print("No ingredients provided for fetching full recipes.")
            }
            return
        }

        DispatchQueue.main.async {
            self.isFetchingRecipe = true
            self.fullRecipes = nil
            print("Started fetching recipe content...")
        }

        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(geminiApiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let prompt = """
        Create 5 detailed recipes using only the following ingredients: \(ingredients.joined(separator: ", ")).
        Each recipe should be a JSON object, and all 5 recipes should be contained within a single JSON array.
        Each JSON recipe object must strictly adhere to the following structure:

        {
            "id": 0,
            "name": "Recipe Name",
            "ingredients": ["ingredient1", "ingredient2", ...],
            "time": "e.g., 30 min",
            "image": "placeholder",
            "steps": ["step 1", "step 2", ...],
            "tags": ["tag1", "tag2", ...],
            "nutritionalInfo": {"calories": "200kcal", "protein": "10g", "carbs": "20g", "fat": "5g"}
        }

        Ensure the entire output is a valid JSON array of these recipe objects. Do not include any additional text, markdown formatting (like ```json), or statements outside of the JSON array.
        """

        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error fetching full recipes from Gemini: \(error)")
                DispatchQueue.main.async {
                    self.fullRecipes = nil
                    self.isFetchingRecipe = false
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    self.fullRecipes = nil
                    self.isFetchingRecipe = false
                    print("No data received for full recipes from Gemini.")
                }
                return
            }

            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let text = (((jsonResponse?["candidates"] as? [[String: Any]])?.first)?["content"] as? [String: Any])?["parts"] as? [[String: Any]]

                if let recipeJSONString = text?.first?["text"] as? String {
                     if let range = recipeJSONString.range(of: "[", options: .literal),
                        let endRange = recipeJSONString.range(of: "]", options: .backwards) {
                         let cleanJSONString = String(recipeJSONString[range.lowerBound..<endRange.upperBound])

                         if let recipesData = cleanJSONString.data(using: .utf8) {
                             let decoder = JSONDecoder()
                             if var recipes = try? decoder.decode([Recipe].self, from: recipesData) {
                                 Task {
                                     await self.fetchImagesForRecipes(&recipes)
                                     DispatchQueue.main.async {
                                         self.fullRecipes = recipes
                                         self.isFetchingRecipe = false
                                         print("Successfully fetched and parsed \(recipes.count) recipes from Gemini and fetched images via SerpAPI.")
                                     }
                                 }
                                 return
                             }
                         }
                     }
                 }

                DispatchQueue.main.async {
                    self.fullRecipes = nil
                    self.isFetchingRecipe = false
                    print("Failed to decode recipes or extract valid JSON array from Gemini response.")
                }

            } catch {
                DispatchQueue.main.async {
                    self.fullRecipes = nil
                    self.isFetchingRecipe = false
                    print("Error parsing Gemini API response JSON for multiple recipes: \(error)")
                }
            }
        }.resume()
    }

    private func fetchImagesForRecipes(_ recipes: inout [Recipe]) async {
        await withTaskGroup(of: (Int, URL?).self) { group in
            for index in recipes.indices {
                let recipeName = recipes[index].name
                group.addTask {
                    do {
                        if let imageUrlString = try await self.imageSearchService.searchFirstImageUrl(query: recipeName),
                           let imageUrl = URL(string: imageUrlString) {
                            return (index, imageUrl)
                        } else {
                            print("SerpAPI: No image URL found for recipe: \(recipeName)")
                        }
                    } catch {
                        print("Error fetching image URL for recipe '\(recipeName)' via SerpAPI: \(error.localizedDescription)")
                    }
                    return (index, nil)
                }
            }

            for await (index, imageUrl) in group {
                if index < recipes.count {
                    if let imageUrl = imageUrl {
                        recipes[index].image = .remote(imageUrl)
                    } else {
                        recipes[index].image = .asset("placeholder")
                    }
                }
            }
        }
    }


    func reset() {
        print("Resetting CameraModel state.")
        self.capturedImage = nil
        self.detectedDish = nil
        self.generatedRecipeNames = nil
        self.fullRecipes = nil
        self.isFetchingRecipe = false
        self.session.startRunning()
    }
}

struct DetectedDish: Equatable {
    let name: String?
    let ingredients: [String]
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

fileprivate extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
