//
//  FolderDropDelegate.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 9/30/23.
//

import SwiftUI
import CoreData
import UniformTypeIdentifiers
import Foundation
import SwiftMessages

struct FolderDrop: DropDelegate {
    var folder: Folder
    var viewContext: NSManagedObjectContext

    func performDrop(info: DropInfo) -> Bool {
        if let item = info.itemProviders(for: [UTType.plainText.identifier]).first {
            item.loadObject(ofClass: NSString.self) { (object, error) in
                DispatchQueue.main.async {
                    if let recipeID = object as? String, !recipeID.isEmpty {
                        if let recipe = self.fetchRecipe(with: recipeID) {
                            recipe.folder = self.folder
                            do {
                                try self.viewContext.save()
                                self.showSuccessMessage()
                            } catch {
                                self.showErrorSavingMessage()
                            }
                        } else {
                            self.showErrorMessage(title: "Error", body: "Failed to fetch the recipe.")
                        }
                    } else {
                        self.showErrorMessage(title: "Error", body: "Failed to load the dragged item.")
                    }
                }
            }
            return true
        }
        self.showErrorMessage(title: "Error", body: "No matching item found for drop operation.")
        return false
    }

    func showSuccessMessage() {
        let successMessage = MessageView.viewFromNib(layout: .cardView)
        successMessage.configureTheme(.success)
        successMessage.configureDropShadow()
        successMessage.button?.isHidden = true
        successMessage.configureContent(title: "Success", body: "Recipe added to folder successfully!")
        SwiftMessages.show(view: successMessage)
    }

    func showErrorSavingMessage() {
        let errorMessage = MessageView.viewFromNib(layout: .cardView)
        errorMessage.configureTheme(.error)
        errorMessage.configureDropShadow()
        errorMessage.button?.isHidden = true
        errorMessage.configureContent(title: "Error", body: "Error saving the recipe to the folder.")
        SwiftMessages.show(view: errorMessage)
    }

    func showErrorMessage(title: String, body: String) {
        let errorMessage = MessageView.viewFromNib(layout: .cardView)
        errorMessage.configureTheme(.error)
        errorMessage.configureDropShadow()
        errorMessage.button?.isHidden = true
        errorMessage.configureContent(title: title, body: body)
        SwiftMessages.show(view: errorMessage)
    }

    func fetchRecipe(with id: String) -> Recipe? {
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let results = try viewContext.fetch(fetchRequest)
            return results.first
        } catch {
            return nil
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .copy)
    }

    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [String(UTType.plainText.identifier)])
    }
}
