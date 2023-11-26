//
//  ManageRecipe.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 9/28/23.
//

import Foundation
import SwiftUI
import SwiftMessages

extension RecipeHomeView {
    // MARK: Filter Recipes On List
    var filteredRecipes: [Recipe] {
        return recipes.filter {
            searchText.isEmpty ||
            $0.title?.localizedCaseInsensitiveContains(searchText) == true ||
            $0.cuisines?.localizedCaseInsensitiveContains(searchText) == true ||
            $0.prepTime?.localizedCaseInsensitiveContains(searchText) == true ||
            $0.cookTime?.localizedCaseInsensitiveContains(searchText) == true
        }
    }
    
    var combinedFilteredRecipes: [Recipe] {
        return filteredRecipes + filteredRecipesInFolder.flatMap { $0.recipes?.allObjects as? [Recipe] ?? [] }
    }
    
    var filteredRecipesInFolder: [Folder] {
        if searchText.isEmpty {
            return Array(folders)
        } else {
            let searchTextLowercased = searchText.lowercased()
            
            let filteredFoldersByName = folders.filter { folder in
                if let folderName = folder.name?.lowercased(), folderName.contains(searchTextLowercased) {
                    return true
                }
                return false
            }
            
            let filteredFoldersByRecipe = folders.filter { folder in
                if let recipes = folder.recipes as? Set<Recipe> {
                    let matchingRecipes = recipes.filter { recipe in
                        if let title = recipe.title?.lowercased(), title.contains(searchTextLowercased) {
                            return true
                        }
                        if let cuisines = recipe.cuisines?.lowercased(), cuisines.contains(searchTextLowercased) {
                            return true
                        }
                        if let prepTime = recipe.prepTime?.lowercased(), prepTime.contains(searchTextLowercased) {
                            return true
                        }
                        if let cookTime = recipe.cookTime?.lowercased(), cookTime.contains(searchTextLowercased) {
                            return true
                        }
                        return false
                    }
                    return !matchingRecipes.isEmpty
                }
                return false
            }
            
            return Array(Set(filteredFoldersByName + filteredFoldersByRecipe))
        }
    }
    
    // MARK: Delete Recipe From List
    func deleteRecipes(offsets: IndexSet) {
        let confirmAlert = MessageView.viewFromNib(layout: .cardView)
        confirmAlert.configureTheme(.error)
        confirmAlert.configureDropShadow()
        confirmAlert.button?.setTitle("Confirm", for: .normal)
        confirmAlert.buttonTapHandler = { _ in
            self.performRecipeDeletion(offsets: offsets)
        }
        confirmAlert.configureContent(title: "Delete Recipe", body: "Are you sure you want to delete this recipe?")
        SwiftMessages.show(view: confirmAlert)
    }
    
    func performRecipeDeletion(offsets: IndexSet) {
        withAnimation {
            offsets.map {
                recipes[$0]
            }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
                showRecipeDeletedConfirmation()
            } catch {
                print("Unresolved error \(error)")
            }
        }
    }
    
    func showRecipeDeletedConfirmation() {
        let successMessage = MessageView.viewFromNib(layout: .cardView)
        successMessage.configureTheme(.success)
        successMessage.configureDropShadow()
        successMessage.button?.isHidden = true
        successMessage.configureContent(title: "Success", body: "Recipe deleted successfully!")
        SwiftMessages.hideAll()
        SwiftMessages.show(view: successMessage)
    }
}

struct FolderPickerView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: Folder.entity(), sortDescriptors: []) var folders: FetchedResults<Folder>
    @ObservedObject var recipe: Recipe
    var completion: () -> Void

    var body: some View {
        List(folders, id: \.self) { folder in
            Button(action: {
                moveTo(folder: folder)
            }) {
                Text(folder.name ?? "Unnamed Folder")
            }
        }
    }

    func moveTo(folder: Folder) {
        recipe.folder = folder
        do {
            try viewContext.save()
        } catch {
            print("Error moving recipe to folder: \(error)")
        }
        completion()
    }
}
