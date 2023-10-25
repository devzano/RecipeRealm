//
//  ImportRecipe.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 9/28/23.
//

import Foundation
import SwiftUI
import UIKit
import SwiftMessages

extension NewRecipeView {
    // MARK: Import Recipe
    var dataButtonDisabled: Bool {
        return !title.isEmpty || !prepTime.isEmpty || !cookTime.isEmpty || nutritionBadges.glutenFree || nutritionBadges.sugarFree || nutritionBadges.dairyFree || nutritionBadges.gmoFree || nutritionBadges.organic || nutritionBadges.vegetarian || selectedCuisineIndex != -1 || !ingredients.isEmpty || !steps.isEmpty || !notes.isEmpty || !recipeURL.isEmpty
    }
    var photoButtonDisabled: Bool {
        return selectedImage != nil
    }
    
    // MARK: Copied Imported Recipe
    func importData() {
        if let clipboardContent = UIPasteboard.general.string {
            var recipeFound = false
            
            var importedTitle = ""
            var importedPrepTime = ""
            var importedCookTime = ""
            var importedGlutenFree = false
            var importedSugarFree = false
            var importedDairyFree = false
            var importedGMOFree = false
            var importedOrganic = false
            var importedVegetarian = false
            var importedPeanutFree = false
            var importedNutFree = false
            var importedEggFree = false
            var importedNoTransFat = false
            var importedCornFree = false
            var importedSoyFree = false
            var importedCuisine = ""
            var importedIngredients = ""
            var importedSteps = ""
            var importedNotes = ""
            var importedURL = ""
            
            var currentSection: String?
            for line in clipboardContent.components(separatedBy: .newlines) {
                if line.starts(with: "Title:") {
                    importedTitle = line.replacingOccurrences(of: "Title:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    currentSection = nil
                } else if line.starts(with: "Prep Time:") {
                    importedPrepTime = line.replacingOccurrences(of: "Prep Time:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else if line.starts(with: "Cook Time:") {
                    importedCookTime = line.replacingOccurrences(of: "Cook Time:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else if line.starts(with: "GlutenFree:") {
                    importedGlutenFree = line.replacingOccurrences(of: "Gluten Free:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "SugarFree:") {
                    importedSugarFree = line.replacingOccurrences(of: "Sugar Free:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "DairyFree:") {
                    importedDairyFree = line.replacingOccurrences(of: "Dairy Free:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "GMOFree:") {
                    importedGMOFree = line.replacingOccurrences(of: "GMO Free:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "Organic:") {
                    importedOrganic = line.replacingOccurrences(of: "Organic:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "Vegetarian:") {
                    importedVegetarian = line.replacingOccurrences(of: "Vegetarian:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "Peanut Free:") {
                    importedPeanutFree = line.replacingOccurrences(of: "Peanut Free:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "Nut Free:") {
                    importedNutFree = line.replacingOccurrences(of: "Nut Free:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "Egg Free:") {
                    importedEggFree = line.replacingOccurrences(of: "Egg Free:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "No Trans Fat:") {
                    importedNoTransFat = line.replacingOccurrences(of: "No Trans Fat:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "Corn Free:") {
                    importedCornFree = line.replacingOccurrences(of: "Corn Free:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "Soy Free:") {
                    importedSoyFree = line.replacingOccurrences(of: "Soy Free:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "Cuisine:") {
                    importedCuisine = line.replacingOccurrences(of: "Cuisine:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else if line.starts(with: "Ingredients:") {
                    currentSection = "ingredients"
                } else if line.starts(with: "Steps:") {
                    currentSection = "steps"
                } else if line.starts(with: "Notes:") {
                    currentSection = "notes"
                } else if line.starts(with: "URL:") {
                    currentSection = "url"
                } else if let section = currentSection {
                    if !line.isEmpty {
                        switch section {
                        case "ingredients":
                            importedIngredients += "\(line)\n"
                        case "steps":
                            importedSteps += "\(line)\n"
                        case "notes":
                            importedNotes += "\(line)\n"
                        case "url":
                            importedURL += "\(line)"
                        default:
                            break
                        }
                    }
                }
            }
            
            if !importedTitle.isEmpty && !importedIngredients.isEmpty && !importedSteps.isEmpty {
                recipeFound = true
            }
            
            self.importedTitle = importedTitle
            self.importedPrepTime = importedPrepTime
            self.importedCookTime = importedCookTime
            self.importedCuisine = importedCuisine
            self.importedGlutenFree = importedGlutenFree
            self.importedSugarFree = importedSugarFree
            self.importedDairyFree = importedDairyFree
            self.importedGMOFree = importedGMOFree
            self.importedOrganic = importedOrganic
            self.importedVegetarian = importedVegetarian
            self.importedPeanutFree = importedPeanutFree
            self.importedNutFree = importedNutFree
            self.importedEggFree = importedEggFree
            self.importedNoTransFat = importedNoTransFat
            self.importedCornFree = importedCornFree
            self.importedSoyFree = importedSoyFree
            self.importedIngredients = importedIngredients
            self.importedSteps = importedSteps
            self.importedNotes = importedNotes
            self.importedURL = importedURL
            
            isImportingData = true
            
            if recipeFound {
                let successMessage = MessageView.viewFromNib(layout: .cardView)
                successMessage.configureTheme(.success)
                successMessage.configureDropShadow()
                successMessage.button?.isHidden = true
                successMessage.configureContent(title: "Recipe Imported", body: "A recipe was successfully imported from the clipboard.")
                SwiftMessages.defaultConfig.duration = .seconds(seconds: 1)
                SwiftMessages.show(view: successMessage)
            } else {
                let noRecipeMessage = MessageView.viewFromNib(layout: .cardView)
                noRecipeMessage.configureTheme(.warning)
                noRecipeMessage.configureDropShadow()
                noRecipeMessage.button?.isHidden = true
                noRecipeMessage.configureContent(title: "No Recipe Found", body: "No recipe data was found in the clipboard.")
                SwiftMessages.defaultConfig.duration = .seconds(seconds: 1)
                SwiftMessages.show(view: noRecipeMessage)
            }
        }
    }
    
    // MARK: Copied Imported Image
    func importPic() {
        self.importImageFromClipboard()
    }
    func importImageFromClipboard() {
        var imageFound = false
        
        for item in UIPasteboard.general.items {
            if let uiImage = item["public.jpeg"] as? UIImage {
                print("Image found using key: public.jpeg")
                selectedImage = uiImage
                imageFound = true
                break
            } else if let uiImage = item["public.png"] as? UIImage {
                print("Image found using key: public.png")
                selectedImage = uiImage
                imageFound = true
                break
            } else if let uiImage = item["com.apple.uikit.image"] as? UIImage {
                print("Image found using key: com.apple.uikit.image")
                selectedImage = uiImage
                imageFound = true
                break
            } else if let uiImage = item["public.gif"] as? UIImage {
                print("Image found using key: public.gif")
                selectedImage = uiImage
                imageFound = true
                break
            } else if let uiImage = item["public.tiff"] as? UIImage {
                print("Image found using key: public.tiff")
                selectedImage = uiImage
                imageFound = true
                break
            } else if let uiImage = item["public.bmp"] as? UIImage {
                print("Image found using key: public.bmp")
                selectedImage = uiImage
                imageFound = true
                break
            }
        }
        
        if imageFound {
            let successMessage = MessageView.viewFromNib(layout: .cardView)
            successMessage.configureTheme(.success)
            successMessage.configureDropShadow()
            successMessage.button?.isHidden = true
            successMessage.configureContent(title: "Image Imported", body: "An image was successfully imported from the clipboard.")
            SwiftMessages.defaultConfig.duration = .seconds(seconds: 1)
            SwiftMessages.show(view: successMessage)
        } else {
            let noImageMessage = MessageView.viewFromNib(layout: .cardView)
            noImageMessage.configureTheme(.warning)
            noImageMessage.configureDropShadow()
            noImageMessage.button?.isHidden = true
            noImageMessage.configureContent(title: "No Image Found", body: "No image was found in the clipboard.")
            SwiftMessages.defaultConfig.duration = .seconds(seconds: 1)
            SwiftMessages.show(view: noImageMessage)
        }
    }
}
