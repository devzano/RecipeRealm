//
//  Persistence.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 5/15/23.
//

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
            let newRecipe = Recipe(context: viewContext)
            newRecipe.title = "Recipe \(i)"
            newRecipe.imageURL = [
                "https://media.istockphoto.com/id/1421774574/photo/mexican-festive-food-for-independence-day-independencia-chiles-en-nogada-tacos-al-pastor.webp?b=1&s=170667a&w=0&k=20&c=rsIbAl1o9Y9bssRn3-9-QAQCZkJhbGfXz35x8CD7758=",
                "https://www.cook2eatwell.com/wp-content/uploads/2018/08/Vaca-Frita-Image-1.jpg",
                "https://tmbidigitalassetsazure.blob.core.windows.net/rms3-prod/attachments/37/1200x1200/Crispy-Fried-Chicken_EXPS_TOHJJ22_6445_DR%20_02_03_11b.jpg",
                "https://www.allrecipes.com/thmb/iXKYAl17eIEnvhLtb4WxM7wKqTc=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/240376-homemade-pepperoni-pizza-Beauty-3x4-1-6ae54059c23348b3b9a703b6a3067a44.jpg",
                "https://www.jocooks.com/wp-content/uploads/2011/04/braised-pork-with-sweet-soy-sauce-1-11-500x375.jpg",
            ][i]
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

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "RecipeRealm")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: {(storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
