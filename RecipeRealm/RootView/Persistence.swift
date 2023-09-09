//
//  Persistence.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 5/15/23.
//

// MARK: Example Details Shuffled For Preview
extension Array {
    func shuffled() -> Array {
        var array = self
        for i in stride(from: array.count - 1, through: 1, by: -1) {
            let j = Int.random(in: 0...i)
            if i != j {
                array.swapAt(i, j)
            }
        }
        return array
    }
}

import CoreData
import SwiftUI

// MARK: CoreData Persistence
struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let properties = [
            (glutenFree: true, sugarFree: true, dairyFree: true, gmoFree: true, organic: true, vegetarian: true),
            (glutenFree: false, sugarFree: false, dairyFree: false, gmoFree: false, organic: false, vegetarian: false),
            (glutenFree: true, sugarFree: false, dairyFree: true, gmoFree: false, organic: false, vegetarian: true),
            (glutenFree: false, sugarFree: true, dairyFree: false, gmoFree: true, organic: true, vegetarian: false),
            (glutenFree: true, sugarFree: true, dairyFree: false, gmoFree: false, organic: true, vegetarian: true)
        ]
        
        let shuffledProperties = properties.shuffled()

        for i in 0..<5 {
            let recipeID = UUID().uuidString
            let newRecipe = Recipe(context: viewContext)
            newRecipe.id = recipeID
            newRecipe.title = "Recipe \(i)"
            newRecipe.prepTime = "\(25 + i)m"
            newRecipe.cookTime = "\(50 + i)m"
            newRecipe.glutenFree = shuffledProperties[i].glutenFree
            newRecipe.sugarFree = shuffledProperties[i].sugarFree
            newRecipe.dairyFree = shuffledProperties[i].dairyFree
            newRecipe.gmoFree = shuffledProperties[i].gmoFree
            newRecipe.organic = shuffledProperties[i].organic
            newRecipe.vegetarian = shuffledProperties[i].vegetarian
            newRecipe.cuisines = ["Mexican", "Cuban", "American", "Italian", "Chinese"][i]
            newRecipe.ingredients = "Ingredients"
            newRecipe.steps = "Steps"
            newRecipe.notes = "Notes"
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    private func loadPersistentStoresAndAddDefaultRecipeIfNeeded(inMemory: Bool) {
        container.loadPersistentStores(completionHandler: { [self] storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            if !inMemory {
                self.addPresetRecipe()
            }
        })
    }
    
    // MARK: Preseted Recipe
    func addPresetRecipe() {
        let viewContext = container.viewContext
        
        guard let image = UIImage(named: "CarnitasTacos"),
              let imageData = image.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        let recipeID = UUID().uuidString
        let presetRecipe = Recipe(context: viewContext)
        presetRecipe.id = recipeID
        presetRecipe.title = "Carnitas Tacos (Slow Cooker)"
        presetRecipe.imageData = imageData
        presetRecipe.prepTime = "25m"
        presetRecipe.cookTime = "4hrs"
        presetRecipe.cuisines = "Mexican"
        presetRecipe.ingredients = "4-5lb pork butt shoulder boneless\n2 medium white onion (chopped or diced)\n6 cloves of garlic or 3tbsp of minced garlic\n1/2 cup of chopped cilanto\n6-10(depends on spice level) chipotle peppers in adobo sauce\n1 cup of chicken broth\n1tsp of chili powder\n2tsp of ground cumin\n1tsp of black pepper\n1 1/2tsp of salt\n2 limes"
        presetRecipe.steps = "1. Cut pork into chunks & place into slow cooker\n2. Pour cup of chicken broth\n3. Slice 1 medium white onion, then add it to the pot along with minced garlic or garlic cloves\n4. Then add all other spices to pork & mix together\n5. Put slow cooker on high to cook for 4hrs\n6. Once pork is cooked, shred to your liking then place on baking sheet\n7. Broil on high for 5-6 minutes on each side\n8. Warm up tortillas & serve w/ lime, chopped onion & cilantro"
        presetRecipe.dairyFree = true
        presetRecipe.glutenFree = true
        presetRecipe.sugarFree = true
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "RecipeRealm")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        let hasAddedPresetRecipe = UserDefaults.standard.bool(forKey: "hasAddedPresetRecipe")
        
        if !hasAddedPresetRecipe && !inMemory {
            loadPersistentStoresAndAddDefaultRecipeIfNeeded(inMemory: inMemory)
            UserDefaults.standard.set(true, forKey: "hasAddedPresetRecipe")
        } else {
            container.loadPersistentStores(completionHandler: { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
