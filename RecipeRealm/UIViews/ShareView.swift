//
//  ShareView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 7/29/23.
//

import SwiftUI
import UIKit

// MARK: DeepLink Generation
func generateRecipeDeepLink(recipe: Recipe) -> URL? {
    var components = URLComponents()
    components.scheme = "RecipeRealm"
    components.host = "app"
    components.path = "/recipe"
    
    let nutritionBadgeNames = [
        ("Gluten Free", recipe.glutenFree),
        ("Sugar Free", recipe.sugarFree),
        ("Dairy Free", recipe.dairyFree),
        ("GMO Free", recipe.gmoFree),
        ("Organic", recipe.organic),
        ("Vegetarian", recipe.vegetarian),
        ("Peanut Free", recipe.peanutFree),
        ("Nut Free", recipe.nutFree),
        ("Egg Free", recipe.eggFree),
        ("No Trans Fat", recipe.noTransFat),
        ("Corn Free", recipe.cornFree),
        ("Soy Free", recipe.soyFree)
    ]
    
    var recipeProperties: [String: String] = [
        "Title": recipe.title ?? "",
        "Prep Time": recipe.prepTime ?? "",
        "Cook Time": recipe.cookTime ?? "",
        "Cuisine": recipe.cuisines ?? "",
        "Ingredients": recipe.ingredients ?? "",
        "Steps": recipe.steps ?? "",
        "Notes": recipe.notes ?? "",
        "URL": recipe.recipeURL ?? ""
    ]
    
    if let imageData = recipe.imageData {
        recipeProperties["Image"] = convertDataToBase64String(imageData)
    }
    
    for (nutritionBadgeName, nutritionBadgeSelected) in nutritionBadgeNames {
        let badgeStatus = nutritionBadgeSelected ? "Yes" : "No"
        recipeProperties[nutritionBadgeName] = badgeStatus
    }
    
    components.queryItems = recipeProperties.map {
        URLQueryItem(name: $0.key, value: $0.value)
    }
    
    return components.url
}

func convertDataToBase64String(_ data: Data?) -> String {
    return data?.base64EncodedString() ?? ""
}

func deepShareRecipe(recipe: Recipe) {
    guard let deepLinkURL = generateRecipeDeepLink(recipe: recipe) else { return }
    let activityViewController = UIActivityViewController(activityItems: [deepLinkURL], applicationActivities: nil)
    
    if UIDevice.current.userInterfaceIdiom == .pad {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            activityViewController.popoverPresentationController?.sourceView = rootViewController.view
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: rootViewController.view.bounds.midX, y: rootViewController.view.bounds.midY, width: 0, height: 0)
            activityViewController.popoverPresentationController?.permittedArrowDirections = []
        }
    }
    
    if let keyWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootViewController = keyWindowScene.windows.first?.rootViewController {
        DispatchQueue.main.async {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}

// MARK: Share Recipe
func shareRecipe(recipe: Recipe) {
    let title = recipe.title ?? ""
    let cuisines = recipe.cuisines ?? ""
    let prepTime = recipe.prepTime ?? ""
    let cookTime = recipe.cookTime ?? ""
    let ingredients = recipe.ingredients ?? ""
    let steps = recipe.steps ?? ""
    let notes = recipe.notes ?? ""
    let url = recipe.recipeURL ?? ""
    
    var shareText = """
    Title: \(title)
    Cuisine: \(cuisines)
    Prep Time: \(prepTime)
    Cook Time: \(cookTime)
    
    Ingredients:
    \(ingredients)
    
    Steps:
    \(steps)
    
    Notes:
    \(notes)
    
    URL:
    \(url)
    
    """
    
    let nutritionBadgeNames = [
        ("Gluten-Free", recipe.glutenFree),
        ("Sugar-Free", recipe.sugarFree),
        ("Dairy-Free", recipe.dairyFree),
        ("GMO-Free", recipe.gmoFree),
        ("Organic", recipe.organic),
        ("Vegetarian", recipe.vegetarian),
        ("Peanut Free", recipe.peanutFree),
        ("Nut Free", recipe.nutFree),
        ("Egg Free", recipe.eggFree),
        ("No Trans Fat", recipe.noTransFat),
        ("Corn Free", recipe.cornFree),
        ("Soy Free", recipe.soyFree)
    ]
    
    for (nutritionBadgeName, nutritionBadgeSelected) in nutritionBadgeNames {
        let badgeStatus = nutritionBadgeSelected ? "Yes" : "No"
        shareText += "\n\(nutritionBadgeName): \(badgeStatus)"
    }
    
    var itemsToShare: [Any] = [shareText]
    
    if let image = recipe.imageData, let uiImage = UIImage(data: image) {
        itemsToShare.append(uiImage)
    }
    
    let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
    
    if UIDevice.current.userInterfaceIdiom == .pad {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            activityViewController.popoverPresentationController?.sourceView = rootViewController.view
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: rootViewController.view.bounds.midX, y: rootViewController.view.bounds.midY, width: 0, height: 0)
            activityViewController.popoverPresentationController?.permittedArrowDirections = []
        }
    }
    
    if let keyWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootViewController = keyWindowScene.windows.first?.rootViewController {
        DispatchQueue.main.async {
            rootViewController.present(activityViewController, animated: true, completion: nil)
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

