//
//  SerpAPIService.swift
//  test9340
//
//  Created by Anay Thakkar on 5/20/25.
//

import Foundation
import UIKit // For UIImage

// MARK: - SerpAPIError
enum SerpAPIError: Error, LocalizedError {
    case invalidURL
    case noData
    case apiError(String)
    case jsonParsingError
    case noImageLinkFound
    case imageDownloadFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The constructed URL for SerpAPI image search is invalid."
        case .noData:
            return "No data was returned from the SerpAPI."
        case .apiError(let message):
            return "SerpAPI Error: \(message)"
        case .jsonParsingError:
            return "Failed to parse JSON response from SerpAPI."
        case .noImageLinkFound:
            return "No suitable image link found in the SerpAPI response for the query."
        case .imageDownloadFailed:
            return "Failed to download the image from the provided URL."
        }
    }
}

// MARK: - SerpAPIService
class SerpAPIService {
    // SerpAPI Key provided by the user
    private let apiKey = "7beb00ad3f46eee85b2bee66cfe8fbf3a33607cdaedc1c806b555a9b2638bc98"

    /// Searches Google Images via SerpAPI for a given query and returns the URL of the first image found.
    /// - Parameter query: The search term (e.g., "Spaghetti Carbonara recipe").
    /// - Returns: An optional String containing the URL of the first image, or nil if not found.
    func searchFirstImageUrl(query: String) async throws -> String? {
        // Ensure the API key is not empty, though it's hardcoded here
        guard !apiKey.isEmpty else {
            print("ERROR: SerpAPI Key is not set. Please ensure the API key is correctly embedded.")
            return nil
        }

        // Encode the query for URL safety and append "recipe" for better relevance
        guard let encodedQuery = (query + " recipe").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw SerpAPIError.invalidURL
        }

        // Construct the URL for the SerpAPI Google Images endpoint
        // We request the 'original' image link for higher quality.
        // 'num=1' is implicitly handled by taking the first result from 'images_results'.
        let urlString = "https://serpapi.com/search?engine=google_images&q=\(encodedQuery)&api_key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            throw SerpAPIError.invalidURL
        }

        do {
            // Perform the network request using URLSession's async/await
            let (data, response) = try await URLSession.shared.data(from: url)

            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SerpAPIError.apiError("Invalid HTTP response from SerpAPI.")
            }

            // Check for successful HTTP status code
            guard httpResponse.statusCode == 200 else {
                let errorString = String(data: data, encoding: .utf8) ?? "Unknown API error"
                throw SerpAPIError.apiError("SerpAPI returned status \(httpResponse.statusCode): \(errorString)")
            }

            // Parse the JSON response
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let imageResults = json["images_results"] as? [[String: Any]],
               let firstImageResult = imageResults.first,
               let originalImageUrl = firstImageResult["original"] as? String { // Extract the 'original' image URL
                return originalImageUrl
            } else {
                // Log if no image results or parsing failed
                print("SerpAPI: No image results found or failed to parse response for query: \(query). Raw data: \(String(data: data, encoding: .utf8) ?? "N/A")")
                return nil // No image found for this query
            }
        } catch let decodingError as DecodingError {
            // Handle JSON decoding errors
            print("SerpAPI JSON Decoding Error for query '\(query)': \(decodingError.localizedDescription)")
            throw SerpAPIError.jsonParsingError
        } catch {
            // Handle general network or other errors
            print("SerpAPI Request Error for query '\(query)': \(error.localizedDescription)")
            throw error // Re-throw any other errors
        }
    }

    /// Downloads an image from a given URL.
    /// - Parameter urlString: The URL of the image to download.
    /// - Returns: A UIImage object.
    func downloadImage(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw SerpAPIError.invalidURL
        }

        do {
            // Download image data
            let (data, _) = try await URLSession.shared.data(from: url)

            // Create UIImage from data
            guard let image = UIImage(data: data) else {
                throw SerpAPIError.imageDownloadFailed
            }
            return image
        } catch {
            // Log and re-throw any download errors
            print("Image download error for URL \(urlString): \(error.localizedDescription)")
            throw error
        }
    }
}
