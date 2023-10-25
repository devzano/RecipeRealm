//
//  AddRecipe.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 9/28/23.
//

import Foundation
import SwiftUI
import SwiftMessages

extension NewRecipeView {
    // MARK: Add Recipe; Missing Fields
    func addRecipe() {
        var missingFields: [String] = []
        
        let finalTitle = !importedTitle.isEmpty ? importedTitle : title
        let finalPrepTime = !importedPrepTime.isEmpty ? importedPrepTime : prepTime
        let finalCookTime = !importedCookTime.isEmpty ? importedCookTime : cookTime
        let finalGlutenFree = importedGlutenFree ? true : nutritionBadges.glutenFree
        let finalSugarFree = importedSugarFree ? true : nutritionBadges.sugarFree
        let finalDairyFree = importedDairyFree ? true : nutritionBadges.dairyFree
        let finalGMOFree = importedGMOFree ? true : nutritionBadges.gmoFree
        let finalOrganic = importedOrganic ? true : nutritionBadges.organic
        let finalVegetarian = importedVegetarian ? true : nutritionBadges.vegetarian
        let finalPeanutFree = importedPeanutFree ? true : nutritionBadges.peanutFree
        let finalNutFree = importedNutFree ? true : nutritionBadges.nutFree
        let finalEggFree = importedEggFree ? true : nutritionBadges.eggFree
        let finalNoTransFat = importedNoTransFat ? true : nutritionBadges.noTransFat
        let finalCornFree = importedCornFree ? true : nutritionBadges.cornFree
        let finalSoyFree = importedSoyFree ? true : nutritionBadges.soyFree
        let finalCuisine = (selectedCuisineIndex >= 0 && selectedCuisineIndex < cuisineOptions.count) ? cuisineOptions[selectedCuisineIndex] : ""
        let finalIngredients = !importedIngredients.isEmpty ? importedIngredients : ingredients
        let finalSteps = !importedSteps.isEmpty ? importedSteps : steps
        let finalNotes = !importedNotes.isEmpty ? importedNotes : notes
        let finalURL = !importedURL.isEmpty ? importedURL : recipeURL
        
        if finalTitle.isEmpty { missingFields.append("Title") }
        if selectedCuisineIndex == -1 { missingFields.append("Cuisine") }
        if finalIngredients.isEmpty { missingFields.append("Ingredients") }
        if finalSteps.isEmpty { missingFields.append("Steps") }
        
        guard missingFields.isEmpty && selectedCuisineIndex != -1 else {
            appStates.showAlert = true
            
            if !missingFields.isEmpty {
                if missingFields.count == 1 {
                    errorMessage = "Please fill in \(missingFields[0])."
                } else {
                    let lastField = missingFields.removeLast()
                    let joinedFields = missingFields.joined(separator: ", ")
                    errorMessage = "Please fill in \(joinedFields) and \(lastField)."
                }
            } else if selectedCuisineIndex == -1 {
                errorMessage = "Please select a cuisine."
            }
            
            return
        }
        
        let recipeID = UUID().uuidString
        let newRecipe = Recipe(context: viewContext)
        newRecipe.id = recipeID
        newRecipe.title = finalTitle
        if let image = selectedImage {
            newRecipe.imageData = image.jpegData(compressionQuality: 1.0)
        }
        newRecipe.prepTime = finalPrepTime
        newRecipe.cookTime = finalCookTime
        newRecipe.glutenFree = finalGlutenFree
        newRecipe.sugarFree = finalSugarFree
        newRecipe.dairyFree = finalDairyFree
        newRecipe.gmoFree = finalGMOFree
        newRecipe.organic = finalOrganic
        newRecipe.vegetarian = finalVegetarian
        newRecipe.peanutFree = finalPeanutFree
        newRecipe.nutFree = finalNutFree
        newRecipe.eggFree = finalEggFree
        newRecipe.noTransFat = finalNoTransFat
        newRecipe.cornFree = finalCornFree
        newRecipe.soyFree = finalSoyFree
        newRecipe.cuisines = finalCuisine
        newRecipe.ingredients = finalIngredients
        newRecipe.steps = finalSteps
        newRecipe.notes = finalNotes
        newRecipe.recipeURL = finalURL

        do {
            try viewContext.save()
            clearAllFields()
            presentationMode.wrappedValue.dismiss()
            let successMessage = MessageView.viewFromNib(layout: .cardView)
            successMessage.configureTheme(.success)
            successMessage.configureDropShadow()
            successMessage.button?.isHidden = true
            successMessage.configureContent(title: "Success", body: "Recipe added successfully!")
            SwiftMessages.defaultConfig.duration = .seconds(seconds: 1)
            SwiftMessages.show(view: successMessage)
        } catch {
            print("Unresolved error \(error)")
            let errorMessage = MessageView.viewFromNib(layout: .cardView)
            errorMessage.configureTheme(.error)
            errorMessage.configureDropShadow()
            errorMessage.button?.isHidden = true
            errorMessage.configureContent(title: "Error", body: "An error occurred while updating the recipe.")
            SwiftMessages.defaultConfig.duration = .seconds(seconds: 1)
            SwiftMessages.show(view: errorMessage)
        }
    }
    
    func clearAllFields() {
        title = ""
        importedTitle = ""
        prepTime = ""
        importedPrepTime = ""
        cookTime = ""
        importedCookTime = ""
        nutritionBadges = NutritionBadges(glutenFree: false, sugarFree: false, dairyFree: false, gmoFree: false, organic: false, vegetarian: false, peanutFree: false, nutFree: false, eggFree: false, noTransFat: false, cornFree: false, soyFree: false)
        importedGlutenFree = false
        importedSugarFree = false
        importedDairyFree = false
        importedGMOFree = false
        importedOrganic = false
        importedVegetarian = false
        importedPeanutFree = false
        importedNutFree = false
        importedEggFree = false
        importedNoTransFat = false
        importedCornFree = false
        importedSoyFree = false
        selectedCuisineIndex = -1
        importedCuisine = ""
        ingredients = ""
        importedIngredients = ""
        steps = ""
        importedSteps = ""
        notes = ""
        importedNotes = ""
        recipeURL = ""
        importedURL = ""
        selectedImage = nil
    }
}
