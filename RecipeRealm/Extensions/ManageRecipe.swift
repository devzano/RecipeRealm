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
