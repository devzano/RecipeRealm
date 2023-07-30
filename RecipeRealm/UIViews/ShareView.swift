//
//  ShareView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 7/29/23.
//

import SwiftUI
import CoreData
import UIKit
import SafariServices

func shareRecipe(recipe: Recipe) {
    let title = (recipe.title?.isEmpty ?? true) ? "Untitled Recipe" : recipe.title
    let cuisines = (recipe.cuisines?.isEmpty ?? true) ? "N/A" : recipe.cuisines
    let prepTime = (recipe.prepTime?.isEmpty ?? true) ? "N/A" : recipe.prepTime
    let cookTime = (recipe.cookTime?.isEmpty ?? true) ? "N/A" : recipe.cookTime
    let ingredients = (recipe.ingredients?.isEmpty ?? true) ? "No ingredients provided" : recipe.ingredients
    let steps = (recipe.steps?.isEmpty ?? true) ? "No steps provided" : recipe.steps
    let notes = (recipe.notes?.isEmpty ?? true) ? "No notes available" : recipe.notes
    var shareText = """
    Recipe: \(title ?? "")
    Cuisine: \(cuisines ?? "")
    Prep Time: \(prepTime ?? "")
    Cook Time: \(cookTime ?? "")
    
    Ingredients:
    \(ingredients ?? "")
    
    Steps:
    \(steps ?? "")
    
    Notes:
    \(notes ?? "")
    
    """
    
    let nutritionBadgeNames = [
        ("Gluten-Free", recipe.glutenFree),
        ("Sugar-Free", recipe.sugarFree),
        ("Dairy-Free", recipe.dairyFree),
        ("GMO-Free", recipe.gmoFree),
        ("Organic", recipe.organic),
        ("Vegetarian", recipe.vegetarian)
    ]
    for (nutritionBadgeName, nutritionBadgeSelected) in nutritionBadgeNames {
        shareText += "\n\(nutritionBadgeName): \(nutritionBadgeSelected ? "Yes" : "No")"
    }
    
    if let imageURL = recipe.imageURL, let url = URL(string: imageURL) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            let imageFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(recipe.title ?? "recipe").jpg")
            do {
                try data.write(to: imageFile)
                let imageItem = ShareItem(file: imageFile)
                let av = UIActivityViewController(activityItems: [imageItem, shareText], applicationActivities: nil)
                DispatchQueue.main.async {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        rootViewController.present(av, animated: true, completion: nil)
                    }
                }
            } catch {
                print("Error writing image to temporary directory: \(error)")
            }
        }
        task.resume()
    } else if let imageData = recipe.imageData, let image = UIImage(data: imageData) {
        if let data = image.jpegData(compressionQuality: 1.0) {
            let imageFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(recipe.title ?? "recipe").jpg")
            do {
                try data.write(to: imageFile)
                let imageItem = ShareItem(file: imageFile)
                let av = UIActivityViewController(activityItems: [imageItem, shareText], applicationActivities: nil)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(av, animated: true, completion: nil)
                }
            } catch {
                print("Error writing image to temporary directory: \(error)")
            }
        }
    } else {
        let av = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(av, animated: true, completion: nil)
        }
    }
}

class ShareItem: NSObject, UIActivityItemSource {
    var file: URL
    
    init(file: URL) {
        self.file = file
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return file
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return file
    }
}
