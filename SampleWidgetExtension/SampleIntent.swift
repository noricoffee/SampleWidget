//
//  SampleIntent.swift
//  SampleWidget
//
//  Created by Noriyuki Yoshida on 2024/12/03.
//

import AppIntents
import UIKit

struct SampleIntent: AppIntent {
    static var title: LocalizedStringResource = "Intent Name"

    func perform() async throws -> some IntentResult {
        // 実行したい処理
        _ = try? await DoggyFetcher.fetchRandomDoggy()
        return .result()
    }
}

struct Doggy: Decodable {
    let message: URL
    let status: String
}

struct DoggyFetcher {
    
    enum DoggyFetcherError: Error {
        case imageDataCorrupted
    }
    
    /// The path where the cached image located
    private static var cachePath: URL {
        URL.cachesDirectory.appending(path: "doggy.png")
    }

    /// The cached dog image
    static var cachedDoggy: UIImage? {
        guard let imageData = try? Data(contentsOf: cachePath) else {
            return  nil
        }
        return UIImage(data: imageData)
    }

    /// Is cached image currently available
    static var cachedDoggyAvailable: Bool {
        cachedDoggy != nil
    }
    
    /// Call the Dog API and then download and cache the dog image
    static func fetchRandomDoggy() async throws -> UIImage {

        let url = URL(string: "https://dog.ceo/api/breeds/image/random")!

        // Fetch JSON data
        let (data, _) = try await URLSession.shared.data(from: url)

        // Parse the JSON data
        let doggy = try JSONDecoder().decode(Doggy.self, from: data)
        
        // Download image from URL
        let (imageData, _) = try await URLSession.shared.data(from: doggy.message)
        
        guard let image = UIImage(data: imageData) else {
            throw DoggyFetcherError.imageDataCorrupted
        }
        
        // Spawn another task to cache the downloaded image
        Task {
            try? await cache(imageData)
            UserDefaults.standard.set(doggy.message, forKey: "dog_image_url")
        }
        
        return image
    }
    
    /// Save the dog image locally
    private static func cache(_ imageData: Data) async throws {
        try imageData.write(to: cachePath)
    }
}
